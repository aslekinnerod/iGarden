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

enum PlantGrouping: String, CaseIterable, Identifiable {
    case location = "Plassering"
    case wateringStatus = "Vanningsstatus"

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
    @AppStorage("plantGrouping") private var groupingRaw = PlantGrouping.location.rawValue

    private var grouping: PlantGrouping {
        PlantGrouping(rawValue: groupingRaw) ?? .location
    }
    @State private var showAddPlant = false
    @State private var showReminderSettings = false
    @State private var showAccount = false
    @State private var showSharing = false
    @State private var showSmartGarden = false

    /// Ventende bed-handling (vann/gjødsle/kalk alle) som skal bekreftes.
    struct BedAction: Identifiable {
        enum Kind { case water, fertilize, lime }
        let kind: Kind
        let location: String
        let plantCount: Int
        var id: String { location + String(describing: kind) }
    }

    @State private var pendingBedAction: BedAction?
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

    private var bedActionTitle: String {
        guard let action = pendingBedAction else { return "" }
        let bed = PlantLocation.displayName(for: action.location)
        switch action.kind {
        case .water:
            return String(localized: "Vanne alle \(action.plantCount) plantene i \(bed)?")
        case .fertilize:
            return String(localized: "Gjødsle alle \(action.plantCount) plantene i \(bed)?")
        case .lime:
            return String(localized: "Kalke \(bed)? Kalking hever pH-en over tid – mål på nytt etter noen uker.")
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

    /// Én seksjon per rom/bed, sortert på lokalisert visningsnavn.
    private var locationGroups: [(location: String, plants: [Plant])] {
        Dictionary(grouping: filteredPlants, by: \.location)
            .map { (location: $0.key, plants: $0.value) }
            .sorted {
                PlantLocation.displayName(for: $0.location)
                    .localizedCaseInsensitiveCompare(PlantLocation.displayName(for: $1.location)) == .orderedAscending
            }
    }

    var body: some View {
        NavigationSplitView {
            List {
                if !gardenStore.plants.isEmpty {
                    Section {
                        heroBand
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                }
                switch grouping {
                case .location:
                    ForEach(locationGroups, id: \.location) { group in
                        Section {
                            plantRows(group.plants)
                        } header: {
                            HStack {
                                Text(PlantLocation.displayName(for: group.location))
                                Spacer()
                                Text("\(group.plants.count)")
                                    .foregroundStyle(.secondary)
                                bedMenu(for: group)
                            }
                        }
                    }
                case .wateringStatus:
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
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.canvas)
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
                            showSmartGarden = true
                        } label: {
                            Label("Smart hage", systemImage: "sparkles")
                        }
                    }
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
                        Picker("Gruppering", selection: $groupingRaw) {
                            ForEach(PlantGrouping.allCases) { grouping in
                                Text(grouping.displayName).tag(grouping.rawValue)
                            }
                        }
                        Divider()
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
            .sheet(isPresented: $showSmartGarden) {
                SmartGardenView()
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
            .confirmationDialog(
                bedActionTitle,
                isPresented: Binding(
                    get: { pendingBedAction != nil },
                    set: { if !$0 { pendingBedAction = nil } }
                ),
                titleVisibility: .visible
            ) {
                if let action = pendingBedAction {
                    switch action.kind {
                    case .water:
                        Button("Vann") {
                            gardenStore.waterAll(in: action.location)
                            pendingBedAction = nil
                        }
                    case .fertilize:
                        // Gjødseltypen lagres som notat på hendelsene.
                        ForEach(Fertilizers.options, id: \.self) { fertilizer in
                            Button(fertilizer) {
                                gardenStore.fertilizeAll(in: action.location, fertilizer: fertilizer)
                                pendingBedAction = nil
                            }
                        }
                        Button("Gjødsle uten type") {
                            gardenStore.fertilizeAll(in: action.location)
                            pendingBedAction = nil
                        }
                    case .lime:
                        Button("Kalk") {
                            gardenStore.limeAll(in: action.location)
                            pendingBedAction = nil
                        }
                    }
                    Button("Avbryt", role: .cancel) { pendingBedAction = nil }
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
            ContentUnavailableView {
                Label("Velg en plante", systemImage: "leaf")
            } description: {
                Text("Velg en plante i listen for å se stell, bilder og jord.")
            }
        }
    }

    private var plantsNeedingWaterCount: Int {
        gardenStore.plants.filter(\.needsWater).count
    }

    private var heroSubtitle: String {
        let count = plantsNeedingWaterCount
        switch count {
        case 0: return String(localized: "Alt er vannet. Ingenting haster i dag.")
        case 1: return String(localized: "1 plante trenger vann")
        default: return String(localized: "\(count) planter trenger vann")
        }
    }

    /// Bilde-bånd øverst i listen, i samme språk som velkomstskjermen:
    /// foto, grønn toning og hvit tekst som sier hva som haster.
    private var heroBand: some View {
        ZStack(alignment: .bottomLeading) {
            Image("OnboardingGarden")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: DS.Spacing.heroBand)
                .clipped()

            Color.heroScrim
                .frame(height: DS.Spacing.heroBand)

            VStack(alignment: .leading, spacing: DS.Spacing.s1) {
                Text(gardenStore.garden?.name ?? String(localized: "Min hage"))
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                HStack(spacing: DS.Spacing.s1 + 2) {
                    Image(systemName: plantsNeedingWaterCount == 0 ? "checkmark.circle.fill" : "drop.fill")
                    Text(heroSubtitle)
                }
                .font(.footnote.weight(.medium))
                .foregroundStyle(.white.opacity(0.9))
            }
            .padding(DS.Spacing.s4)
        }
        .frame(height: DS.Spacing.heroBand)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.hero))
        .padding(.horizontal, DS.Spacing.listInset)
        .padding(.bottom, DS.Spacing.s2)
        .accessibilityElement(children: .combine)
    }

    /// Meny på bed-seksjonen: vann/gjødsle hele bedet, og pH-snarvei.
    private func bedMenu(for group: (location: String, plants: [Plant])) -> some View {
        Menu {
            Button {
                pendingBedAction = BedAction(kind: .water, location: group.location, plantCount: group.plants.count)
            } label: {
                Label("Vann alle", systemImage: "drop.fill")
            }
            Button {
                pendingBedAction = BedAction(kind: .fertilize, location: group.location, plantCount: group.plants.count)
            } label: {
                Label("Gjødsle alle", systemImage: "leaf.fill")
            }
            if gardenStore.customLocations.contains(where: { $0.name == group.location }) {
                Button {
                    pendingBedAction = BedAction(kind: .lime, location: group.location, plantCount: group.plants.count)
                } label: {
                    Label("Kalk bedet", systemImage: "circle.dotted")
                }
                Divider()
                Button {
                    showSmartGarden = true
                } label: {
                    Label("Mål jord-pH", systemImage: "gauge.with.needle")
                }
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.footnote)
        }
        .textCase(nil)
    }

    /// Sann når planten står i et bed med målt pH utenfor sitt område.
    private func hasSoilWarning(_ plant: Plant) -> Bool {
        guard let bed = gardenStore.customLocations.first(where: { $0.name == plant.location }) else {
            return false
        }
        let fit = SoilFit.evaluate(plant: plant, bedPH: bed.soilPH)
        return fit == .tooAcidic || fit == .tooAlkaline
    }

    private func plantRows(_ plants: [Plant]) -> some View {
        ForEach(plants) { plant in
            NavigationLink {
                PlantDetailView(plant: plant)
            } label: {
                PlantRowView(plant: plant, soilWarning: hasSoilWarning(plant))
            }
            .swipeActions(edge: .leading) {
                Button {
                    gardenStore.markWatered(plant)
                } label: {
                    Label("Vannet", systemImage: "drop.fill")
                }
                .tint(.actionWater)
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
    /// Viser trekantvarsel på raden når jord-pH ikke passer planten (APP-40).
    var soilWarning: Bool = false

    private var hasSchedule: Bool { plant.wateringStatus != .noSchedule }

    var body: some View {
        HStack(spacing: DS.Spacing.s3) {
            thumbnail
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: DS.Spacing.s1) {
                    Text(plant.name)
                        .font(.headline)
                    if soilWarning {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(Color.statusDue)
                            .font(.caption)
                    }
                }
                HStack(spacing: DS.Spacing.s1) {
                    if hasSchedule {
                        Image(systemName: "drop.fill")
                            .foregroundStyle(statusColor)
                            .font(.caption2)
                    }
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
        .padding(.vertical, DS.Spacing.s1)
    }

    private var thumbnail: some View {
        PlantPhotoView(path: plant.photoPath) {
            RoundedRectangle(cornerRadius: DS.Radius.thumb)
                .fill(Color.fillLeaf)
                .overlay {
                    Image(systemName: "leaf")
                        .foregroundStyle(Color.fillLeafForeground)
                }
        }
        .frame(width: DS.Spacing.thumb, height: DS.Spacing.thumb)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.photo))
    }

    private var statusColor: Color {
        switch plant.wateringStatus {
        case .overdue: .statusOverdue
        case .dueToday, .neverWatered: .statusDue
        case .ok: .statusOK
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
        .environment(PlantCatalog())
}
