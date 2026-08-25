//
//  PlantFormView.swift
//  iGarden
//

import SwiftUI
import SwiftData

/// Skjema for å registrere en ny plante eller redigere en eksisterende.
/// Feltene holdes i lokal state slik at Avbryt ikke endrer noe.
struct PlantFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// Planten som redigeres, eller nil for ny plante.
    let plant: Plant?

    @State private var name: String
    @State private var species: String
    @State private var location: PlantLocation
    @State private var dateAcquired: Date
    @State private var notes: String
    @State private var wateringIntervalDays: Int
    @State private var showDeleteConfirmation = false

    init(plant: Plant? = nil) {
        self.plant = plant
        _name = State(initialValue: plant?.name ?? "")
        _species = State(initialValue: plant?.species ?? "")
        _location = State(initialValue: plant?.location ?? .livingRoom)
        _dateAcquired = State(initialValue: plant?.dateAcquired ?? .now)
        _notes = State(initialValue: plant?.notes ?? "")
        _wateringIntervalDays = State(initialValue: plant?.wateringIntervalDays ?? 7)
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
                    Picker("Plassering", selection: $location) {
                        ForEach(PlantLocation.allCases) { location in
                            Text(location.rawValue).tag(location)
                        }
                    }
                    DatePicker("Anskaffet", selection: $dateAcquired, in: ...Date.now, displayedComponents: .date)
                }

                Section("Vanning") {
                    Stepper(value: $wateringIntervalDays, in: 1...60) {
                        Text("Hver \(wateringIntervalDays). dag")
                    }
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
            .navigationTitle(isEditing ? "Rediger plante" : "Ny plante")
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
                "Slette \(trimmedName.isEmpty ? "planten" : trimmedName)?",
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
        if let plant {
            plant.name = trimmedName
            plant.species = trimmedSpecies.isEmpty ? nil : trimmedSpecies
            plant.location = location
            plant.dateAcquired = dateAcquired
            plant.notes = notes
            plant.wateringIntervalDays = wateringIntervalDays
            // Endret intervall eller navn påvirker varselet.
            NotificationManager.reschedule(for: plant)
        } else {
            let newPlant = Plant(
                name: trimmedName,
                species: trimmedSpecies.isEmpty ? nil : trimmedSpecies,
                location: location,
                dateAcquired: dateAcquired,
                notes: notes,
                wateringIntervalDays: wateringIntervalDays
            )
            modelContext.insert(newPlant)
        }
        dismiss()
    }

    private func deletePlant() {
        if let plant {
            NotificationManager.cancel(for: plant)
            modelContext.delete(plant)
        }
        dismiss()
    }
}

#Preview("Ny plante") {
    PlantFormView()
        .modelContainer(for: Plant.self, inMemory: true)
}
