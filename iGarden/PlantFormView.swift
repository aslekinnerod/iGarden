//
//  PlantFormView.swift
//  iGarden
//

import SwiftUI

/// Skjema for å registrere en ny plante eller redigere en eksisterende.
/// Feltene holdes i lokal state slik at Avbryt ikke endrer noe.
struct PlantFormView: View {
    @Environment(GardenStore.self) private var gardenStore
    @Environment(\.dismiss) private var dismiss

    /// Planten som redigeres, eller nil for ny plante.
    let plant: Plant?

    @State private var name: String
    @State private var species: String
    @State private var location: String
    @State private var dateAcquired: Date
    @State private var notes: String
    @State private var hasWateringSchedule: Bool
    @State private var wateringIntervalDays: Int
    @State private var phLow: Double?
    @State private var phHigh: Double?
    @State private var waterNeed: WaterNeed?
    @State private var lightNeed: LightNeed?
    @State private var showDeleteConfirmation = false
    /// Navnet fra sist valgte databaseforslag – skjuler trefflisten
    /// til brukeren skriver noe annet.
    @State private var appliedSuggestionName: String?
    @State private var isLookingUp = false
    @State private var lookupError: String?

    private var nameSuggestions: [PlantInfo] {
        let query = name.trimmingCharacters(in: .whitespaces)
        guard query.count >= 2, query != appliedSuggestionName else { return [] }
        let results = PlantDatabase.search(query)
        // Ikke mas når eneste treff allerede står i feltet.
        if results.count == 1, results[0].name.folded == query.folded { return [] }
        return Array(results.prefix(6))
    }

    init(plant: Plant? = nil) {
        self.plant = plant
        _name = State(initialValue: plant?.name ?? "")
        _species = State(initialValue: plant?.species ?? "")
        _location = State(initialValue: plant?.location ?? PlantLocation.livingRoom.rawValue)
        _dateAcquired = State(initialValue: plant?.dateAcquired ?? .now)
        _notes = State(initialValue: plant?.notes ?? "")
        _hasWateringSchedule = State(initialValue: plant.map { $0.wateringIntervalDays != nil } ?? true)
        _wateringIntervalDays = State(initialValue: plant?.wateringIntervalDays ?? 7)
        _phLow = State(initialValue: plant?.preferredPHLow)
        _phHigh = State(initialValue: plant?.preferredPHHigh)
        _waterNeed = State(initialValue: plant?.waterNeed)
        _lightNeed = State(initialValue: plant?.lightNeed)
    }

    private var isEditing: Bool { plant != nil }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// KI-oppslag tilbys når navnet er ukjent for den lokale databasen.
    private var canOfferLookup: Bool {
        trimmedName.count >= 3
            && trimmedName != appliedSuggestionName
            && nameSuggestions.isEmpty
            && PlantDatabase.match(name: trimmedName, species: species) == nil
    }

    private func lookUpWithAI() {
        isLookingUp = true
        Task {
            defer { isLookingUp = false }
            do {
                let result = try await PlantLookupService.lookup(name: trimmedName)
                name = result.norskNavn
                if species.trimmingCharacters(in: .whitespaces).isEmpty {
                    species = result.latinskNavn
                }
                phLow = result.phLav
                phHigh = result.phHoey
                waterNeed = result.waterNeed
                lightNeed = result.lightNeed
                if !isEditing, hasWateringSchedule {
                    wateringIntervalDays = result.vanningsintervallDager
                }
                appliedSuggestionName = result.norskNavn
            } catch {
                lookupError = error.localizedDescription
            }
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Om planten") {
                    TextField("Navn", text: $name)
                        .autocorrectionDisabled()
                    ForEach(nameSuggestions, id: \.name) { info in
                        Button {
                            applySuggestion(info)
                        } label: {
                            HStack {
                                Image(systemName: "leaf.circle")
                                    .foregroundStyle(Color.accentColor)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(info.name)
                                        .foregroundStyle(.primary)
                                    if let latin = info.latinName {
                                        Text(latin)
                                            .font(.caption)
                                            .italic()
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                Text("pH \(info.phRangeText)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    if canOfferLookup {
                        Button {
                            lookUpWithAI()
                        } label: {
                            HStack {
                                if isLookingUp {
                                    ProgressView()
                                    Text("Slår opp «\(trimmedName)»…")
                                        .foregroundStyle(.secondary)
                                } else {
                                    Label("Slå opp «\(trimmedName)» med KI", systemImage: "sparkle.magnifyingglass")
                                }
                            }
                        }
                        .disabled(isLookingUp)
                    }
                    TextField("Art / latinsk navn", text: $species)
                    NavigationLink {
                        LocationPickerView(selection: $location)
                    } label: {
                        LabeledContent("Plassering", value: PlantLocation.displayName(for: location))
                    }
                    DatePicker("Anskaffet", selection: $dateAcquired, in: ...Date.now, displayedComponents: .date)
                }

                Section {
                    Toggle("Vanningsplan", isOn: $hasWateringSchedule.animation())
                    if hasWateringSchedule {
                        Stepper(value: $wateringIntervalDays, in: 1...60) {
                            Text("Hver \(wateringIntervalDays). dag")
                        }
                    }
                } header: {
                    Text("Vanning")
                } footer: {
                    if !hasWateringSchedule {
                        Text("Uten vanningsplan får planten ingen påminnelser og vises ikke under «Trenger vann». Passer for uteplanter som klarer seg selv.")
                    }
                }

                Section {
                    Picker("Vannbehov", selection: $waterNeed) {
                        Text("Ikke satt").tag(WaterNeed?.none)
                        ForEach(WaterNeed.allCases) { need in
                            Text(need.displayName).tag(WaterNeed?.some(need))
                        }
                    }
                    Picker("Lysbehov", selection: $lightNeed) {
                        Text("Ikke satt").tag(LightNeed?.none)
                        ForEach(LightNeed.allCases) { need in
                            Text(need.displayName).tag(LightNeed?.some(need))
                        }
                    }
                } header: {
                    Text("Vann og lys")
                } footer: {
                    Text("Fylles inn automatisk for kjente planter når du lagrer.")
                }

                Section {
                    if let low = phLow, let high = phHigh {
                        Stepper(
                            "Fra pH \(low.formatted(.number.precision(.fractionLength(1))))",
                            value: Binding(
                                get: { phLow ?? 6.0 },
                                set: { phLow = $0; if $0 > (phHigh ?? $0) { phHigh = $0 } }
                            ),
                            in: 3.5...9.0,
                            step: 0.1
                        )
                        Stepper(
                            "Til pH \(high.formatted(.number.precision(.fractionLength(1))))",
                            value: Binding(
                                get: { phHigh ?? 7.0 },
                                set: { phHigh = $0; if $0 < (phLow ?? $0) { phLow = $0 } }
                            ),
                            in: 3.5...9.0,
                            step: 0.1
                        )
                        Button("Fjern pH-preferanse", role: .destructive) {
                            phLow = nil
                            phHigh = nil
                        }
                    } else if let match = PlantDatabase.match(name: name, species: species) {
                        Button {
                            phLow = match.phLow
                            phHigh = match.phHigh
                        } label: {
                            Label(
                                String(localized: "Bruk \(match.name): pH \(match.phLow.formatted(.number.precision(.fractionLength(1))))–\(match.phHigh.formatted(.number.precision(.fractionLength(1))))"),
                                systemImage: "sparkles"
                            )
                        }
                    } else {
                        Button("Angi pH-preferanse manuelt") {
                            phLow = 6.0
                            phHigh = 7.0
                        }
                    }
                } header: {
                    Text("Jord (pH)")
                } footer: {
                    Text("Brukes av Smart hage til å foreslå riktig bed. Fylles inn automatisk for kjente planter når du lagrer.")
                }

                Section("Notater") {
                    TextField("Notater", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                if isEditing {
                    Section {
                        Button("Slett plante", role: .destructive) {
                            showDeleteConfirmation = true
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle(isEditing ? String(localized: "Rediger plante") : String(localized: "Ny plante"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Avbryt") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lagre") { save() }
                        .disabled(trimmedName.isEmpty)
                }
            }
            .alert(
                "Noe gikk galt",
                isPresented: Binding(
                    get: { lookupError != nil },
                    set: { if !$0 { lookupError = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(lookupError ?? "")
            }
            .confirmationDialog(
                "Slette \(trimmedName.isEmpty ? String(localized: "planten") : trimmedName)?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Slett", role: .destructive) { deletePlant() }
                Button("Avbryt", role: .cancel) {}
            } message: {
                Text("Dette kan ikke angres.")
            }
        }
    }

    private func save() {
        let trimmedSpecies = species.trimmingCharacters(in: .whitespacesAndNewlines)
        // Er pH-preferansen ikke satt, hentes den automatisk fra plantedatabasen.
        let match = PlantDatabase.match(name: trimmedName, species: trimmedSpecies)
        let effectivePHLow = phLow ?? match?.phLow
        let effectivePHHigh = phHigh ?? match?.phHigh
        let effectiveWater = waterNeed ?? match?.water
        let effectiveLight = lightNeed ?? match?.light
        if var updated = plant {
            updated.name = trimmedName
            updated.species = trimmedSpecies.isEmpty ? nil : trimmedSpecies
            updated.location = location
            updated.dateAcquired = dateAcquired
            updated.notes = notes
            updated.wateringIntervalDays = hasWateringSchedule ? wateringIntervalDays : nil
            updated.preferredPHLow = effectivePHLow
            updated.preferredPHHigh = effectivePHHigh
            updated.waterNeed = effectiveWater
            updated.lightNeed = effectiveLight
            gardenStore.updatePlant(updated)
        } else {
            gardenStore.addPlant(Plant(
                name: trimmedName,
                species: trimmedSpecies.isEmpty ? nil : trimmedSpecies,
                location: location,
                dateAcquired: dateAcquired,
                notes: notes,
                wateringIntervalDays: hasWateringSchedule ? wateringIntervalDays : nil,
                preferredPHLow: effectivePHLow,
                preferredPHHigh: effectivePHHigh,
                waterNeed: effectiveWater,
                lightNeed: effectiveLight
            ))
        }
        dismiss()
    }

    private func applySuggestion(_ info: PlantInfo) {
        name = info.name
        if species.trimmingCharacters(in: .whitespaces).isEmpty, let latin = info.latinName {
            species = latin
        }
        phLow = info.phLow
        phHigh = info.phHigh
        waterNeed = info.water
        lightNeed = info.light
        // For nye planter foreslås vanningsintervall fra vannbehovet.
        if !isEditing, hasWateringSchedule {
            wateringIntervalDays = info.water.suggestedIntervalDays
        }
        appliedSuggestionName = info.name
    }

    private func deletePlant() {
        if let plant {
            gardenStore.deletePlant(plant)
        }
        dismiss()
    }
}

#Preview("Ny plante") {
    PlantFormView()
        .environment(GardenStore())
}
