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
    @State private var showDeleteConfirmation = false

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
    }

    private var isEditing: Bool { plant != nil }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Om planten") {
                    TextField("Navn", text: $name)
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
                    } else if let match = SoilDatabase.match(name: name, species: species) {
                        Button {
                            phLow = match.low
                            phHigh = match.high
                        } label: {
                            Label(
                                String(localized: "Bruk \(match.name): pH \(match.low.formatted(.number.precision(.fractionLength(1))))–\(match.high.formatted(.number.precision(.fractionLength(1))))"),
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
        let match = SoilDatabase.match(name: trimmedName, species: trimmedSpecies)
        let effectivePHLow = phLow ?? match?.low
        let effectivePHHigh = phHigh ?? match?.high
        if var updated = plant {
            updated.name = trimmedName
            updated.species = trimmedSpecies.isEmpty ? nil : trimmedSpecies
            updated.location = location
            updated.dateAcquired = dateAcquired
            updated.notes = notes
            updated.wateringIntervalDays = hasWateringSchedule ? wateringIntervalDays : nil
            updated.preferredPHLow = effectivePHLow
            updated.preferredPHHigh = effectivePHHigh
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
                preferredPHHigh: effectivePHHigh
            ))
        }
        dismiss()
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
