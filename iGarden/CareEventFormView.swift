//
//  CareEventFormView.swift
//  iGarden
//

import SwiftUI
import SwiftData

/// Sheet for å registrere en stell-hendelse på en plante.
struct CareEventFormView: View {
    @Environment(\.dismiss) private var dismiss

    let plant: Plant

    @State private var type: CareEventType = .watering
    @State private var date: Date = .now
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Picker("Type", selection: $type) {
                    ForEach(CareEventType.allCases) { type in
                        Label(type.displayName, systemImage: type.icon).tag(type)
                    }
                }
                DatePicker("Dato", selection: $date, in: ...Date.now)
                TextField("Notat (valgfritt)", text: $note, axis: .vertical)
                    .lineLimit(2...4)
            }
            .navigationTitle("Registrer stell")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Avbryt") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lagre") { save() }
                }
            }
        }
    }

    private func save() {
        let event = CareEvent(type: type, date: date, note: note.trimmingCharacters(in: .whitespacesAndNewlines))
        plant.careEvents.append(event)
        // En vanning bakover i tid skal ikke overskrive en nyere registrering.
        if type == .watering, date > (plant.lastWatered ?? .distantPast) {
            plant.lastWatered = date
            NotificationManager.reschedule(for: plant)
        }
        dismiss()
    }
}

#Preview {
    CareEventFormView(plant: Plant(name: "Monstera"))
        .modelContainer(for: Plant.self, inMemory: true)
}
