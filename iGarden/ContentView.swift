//
//  ContentView.swift
//  iGarden
//

import SwiftUI

enum PlantSortOrder: String, CaseIterable, Identifiable {
    case name = "Navn"
    case lastWatered = "Sist vannet"
    case nextWatering = "Neste vanning"

    var id: String { rawValue }

    var displayName: String {
        String(localized: String.LocalizationValue(rawValue))
    }
}

struct ContentView: View {
    @Environment(AuthStore.self) private var authStore
    @Environment(GardenStore.self) private var gardenStore

    @State private var searchText = ""
    @State private var sortOrder: PlantSortOrder = .name
    @State private var showAddPlant = false
    @State private var showReminderSettings = false
    @State private var showAccount = false
    @State private var showSharing = false
    @State private var sharingPrefilledCode = ""
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showOnboarding = false

    private var filteredPlants: [Plant] {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        let matching = query.isEmpty ? gardenStore.plants : gardenStore.plants.filter { plant in
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
            // Aldri vannet først (venter lengst), uten vanningsplan sist.
            return matching.sorted {
                nextWateringSortKey($0) < nextWateringSortKey($1)
            }
        }
    }

    private func nextWateringSortKey(_ plant: Plant) -> Date {
        guard plant.wateringStatus != .noSchedule else { return .distantFuture }
        return plant.nextWateringDate ?? .distantPast
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
                    Section(plantsNeedingWater.isEmpty ? String(localized: "Alle planter") : String(localized: "Øvrige planter")) {
                        plantRows(plantsNotNeedingWater)
                    }
                }
            }
            .navigationTitle("Mine planter")
            .searchable(text: $searchText, prompt: "Søk på navn eller art")
            .overlay {
                if !gardenStore.isConfigured {
                    ContentUnavailableView(
                        "Skyen er ikke satt opp",
                        systemImage: "icloud.slash",
                        description: Text("GoogleService-Info.plist mangler i prosjektet.")
                    )
                } else if !gardenStore.isReady {
                    ProgressView()
                } else if gardenStore.plants.isEmpty {
                    ContentUnavailableView {
                        Label("Ingen planter ennå", systemImage: "leaf")
                    } description: {
                        Text("Legg til plantene dine, så hjelper iGarden deg å holde dem i live.")
                    } actions: {
                        Button("Legg til din første plante") {
                            showAddPlant = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else if filteredPlants.isEmpty && !searchText.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
            .toolbar {
                if gardenStore.isConfigured {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            sharingPrefilledCode = ""
                            showSharing = true
                        } label: {
                            Label("Del hagen", systemImage: "person.2")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showAccount = true
                        } label: {
                            Label("Konto", systemImage: authStore.hasAccount ? "person.crop.circle.badge.checkmark" : "person.crop.circle")
                        }
                    }
                }
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
                                Text(order.displayName).tag(order)
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
            .sheet(isPresented: $showAccount) {
                AccountView()
            }
            .sheet(isPresented: $showSharing) {
                GardenSharingView(prefilledCode: sharingPrefilledCode)
            }
            .onChange(of: gardenStore.pendingInviteCode) {
                // Invitasjonslenke åpnet: vis delingssiden med koden utfylt.
                if let code = gardenStore.pendingInviteCode {
                    gardenStore.pendingInviteCode = nil
                    sharingPrefilledCode = code
                    showSharing = true
                }
            }
            .sheet(isPresented: $showOnboarding) {
                OnboardingView()
            }
            .onAppear {
                if !hasSeenOnboarding {
                    hasSeenOnboarding = true
                    showOnboarding = true
                }
            }
            .alert(
                "Noe gikk galt",
                isPresented: Binding(
                    get: { gardenStore.errorMessage != nil },
                    set: { if !$0 { gardenStore.errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(gardenStore.errorMessage ?? "")
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
                    gardenStore.markWatered(plant)
                } label: {
                    Label("Vannet", systemImage: "drop.fill")
                }
                .tint(.blue)
            }
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    gardenStore.deletePlant(plant)
                } label: {
                    Label("Slett", systemImage: "trash")
                }
            }
        }
    }
}

struct PlantRowView: View {
    let plant: Plant

    private var hasSchedule: Bool { plant.wateringStatus != .noSchedule }

    var body: some View {
        HStack(spacing: 10) {
            thumbnail
            if hasSchedule {
                Image(systemName: "drop.fill")
                    .foregroundStyle(statusColor)
                    .font(.footnote)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(plant.name)
                HStack(spacing: 4) {
                    Text(plant.locationDisplayName)
                        .foregroundStyle(.secondary)
                    if hasSchedule {
                        Text("·")
                            .foregroundStyle(.secondary)
                        Text(statusText)
                            .foregroundStyle(plant.needsWater ? statusColor : .secondary)
                    }
                }
                .font(.caption)
            }
        }
    }

    private var thumbnail: some View {
        PlantPhotoView(path: plant.photoPath) {
            RoundedRectangle(cornerRadius: 8)
                .fill(.green.opacity(0.12))
                .overlay {
                    Image(systemName: "leaf")
                        .foregroundStyle(.green.opacity(0.5))
                }
        }
        .frame(width: 44, height: 44)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var statusColor: Color {
        switch plant.wateringStatus {
        case .overdue: .red
        case .dueToday, .neverWatered: .orange
        case .ok: .green
        case .noSchedule: .secondary
        }
    }

    private var statusText: String {
        switch plant.wateringStatus {
        case .neverWatered:
            String(localized: "Ikke vannet ennå")
        case .overdue:
            String(localized: "Forfalt – skulle vannes \(plant.nextWateringDate!.formatted(.relative(presentation: .named)))")
        case .dueToday:
            String(localized: "Vannes i dag")
        case .ok:
            String(localized: "Vannes \(plant.nextWateringDate!.formatted(.relative(presentation: .named)))")
        case .noSchedule:
            ""
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthStore())
        .environment(GardenStore())
}
