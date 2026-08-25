//
//  ContentView.swift
//  iGarden
//

import SwiftUI
import SwiftData

enum PlantSortOrder: String, CaseIterable, Identifiable {
    case name = "Navn"
    case lastWatered = "Sist vannet"
    case nextWatering = "Neste vanning"

    var id: String { rawValue }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Plant.name) private var plants: [Plant]

    @State private var searchText = ""
    @State private var sortOrder: PlantSortOrder = .name
    @State private var showAddPlant = false
    @State private var showReminderSettings = false

    private var filteredPlants: [Plant] {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        let matching = query.isEmpty ? plants : plants.filter { plant in
            plant.name.localizedCaseInsensitiveContains(query)
                || plant.species?.localizedCaseInsensitiveContains(query) == true
        }
        switch sortOrder {
        case .name:
            return matching.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        case .lastWatered:
            // Aldri vannet først – de har ventet lengst.
            return matching.sorted {
                ($0.lastWatered ?? .distantPast) < ($1.lastWatered ?? .distantPast)
            }
        case .nextWatering:
            return matching.sorted {
                ($0.nextWateringDate ?? .distantPast) < ($1.nextWateringDate ?? .distantPast)
            }
        }
    }

    private var plantsNeedingWater: [Plant] {
        filteredPlants.filter(\.needsWater)
    }

    private var plantsNotNeedingWater: [Plant] {
        filteredPlants.filter { !$0.needsWater }
    }

    var body: some View {
        NavigationSplitView {
            List {
                if !plantsNeedingWater.isEmpty {
                    Section("Trenger vann") {
                        plantRows(plantsNeedingWater)
                    }
                }
                if !plantsNotNeedingWater.isEmpty {
                    Section(plantsNeedingWater.isEmpty ? "Alle planter" : "Øvrige planter") {
                        plantRows(plantsNotNeedingWater)
                    }
                }
            }
            .navigationTitle("Mine planter")
            .searchable(text: $searchText, prompt: "Søk på navn eller art")
            .overlay {
                if filteredPlants.isEmpty && !searchText.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showReminderSettings = true
                    } label: {
                        Label("Varsler", systemImage: "bell")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Sortering", selection: $sortOrder) {
                            ForEach(PlantSortOrder.allCases) { order in
                                Text(order.rawValue).tag(order)
                            }
                        }
                    } label: {
                        Label("Sortering", systemImage: "arrow.up.arrow.down")
                    }
                }
                ToolbarItem {
                    Button {
                        showAddPlant = true
                    } label: {
                        Label("Legg til plante", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddPlant) {
                PlantFormView()
            }
            .sheet(isPresented: $showReminderSettings) {
                ReminderSettingsView()
            }
        } detail: {
            Text("Velg en plante")
        }
    }

    private func plantRows(_ plants: [Plant]) -> some View {
        ForEach(plants) { plant in
            NavigationLink {
                PlantDetailView(plant: plant)
            } label: {
                PlantRowView(plant: plant)
            }
            .swipeActions(edge: .leading) {
                Button {
                    withAnimation { plant.markWatered() }
                    NotificationManager.reschedule(for: plant)
                } label: {
                    Label("Vannet", systemImage: "drop.fill")
                }
                .tint(.blue)
            }
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    NotificationManager.cancel(for: plant)
                    withAnimation { modelContext.delete(plant) }
                } label: {
                    Label("Slett", systemImage: "trash")
                }
            }
        }
    }
}

struct PlantRowView: View {
    let plant: Plant

    var body: some View {
        HStack(spacing: 10) {
            thumbnail
            Image(systemName: "drop.fill")
                .foregroundStyle(statusColor)
                .font(.footnote)
            VStack(alignment: .leading, spacing: 2) {
                Text(plant.name)
                HStack(spacing: 4) {
                    Text(plant.location.rawValue)
                        .foregroundStyle(.secondary)
                    Text("·")
                        .foregroundStyle(.secondary)
                    Text(statusText)
                        .foregroundStyle(plant.needsWater ? statusColor : .secondary)
                }
                .font(.caption)
            }
        }
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let image = plant.latestPhoto?.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(.green.opacity(0.12))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: "leaf")
                        .foregroundStyle(.green.opacity(0.5))
                }
        }
    }

    private var statusColor: Color {
        switch plant.wateringStatus {
        case .overdue: .red
        case .dueToday, .neverWatered: .orange
        case .ok: .green
        }
    }

    private var statusText: String {
        switch plant.wateringStatus {
        case .neverWatered:
            "Ikke vannet ennå"
        case .overdue:
            "Forfalt – skulle vannes \(plant.nextWateringDate!.formatted(.relative(presentation: .named)))"
        case .dueToday:
            "Vannes i dag"
        case .ok:
            "Vannes \(plant.nextWateringDate!.formatted(.relative(presentation: .named)))"
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Plant.self, inMemory: true)
}
