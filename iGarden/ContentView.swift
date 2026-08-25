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

// Detaljvisningen er en plassholder frem til APP-8.
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Plant.name) private var plants: [Plant]

    @State private var searchText = ""
    @State private var sortOrder: PlantSortOrder = .name
    @State private var showAddPlant = false

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

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(filteredPlants) { plant in
                    NavigationLink {
                        PlantDetailView(plant: plant)
                    } label: {
                        PlantRowView(plant: plant)
                    }
                }
                .onDelete(perform: deletePlants)
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
        } detail: {
            Text("Velg en plante")
        }
    }

    private func deletePlants(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredPlants[index])
            }
        }
    }
}

struct PlantRowView: View {
    let plant: Plant

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(plant.name)
            HStack(spacing: 4) {
                Text(plant.location.rawValue)
                Text("·")
                Text(nextWateringText)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    private var nextWateringText: String {
        guard let next = plant.nextWateringDate else {
            return "Ikke vannet ennå"
        }
        if next <= .now {
            return "Trenger vann"
        }
        return "Vannes \(next.formatted(.relative(presentation: .named)))"
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Plant.self, inMemory: true)
}
