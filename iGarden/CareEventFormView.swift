//
//  CareEventFormView.swift
//  iGarden
//

import SwiftUI

/// Sheet for å registrere en stell-hendelse på en plante.
struct CareEventFormView: View {
    @Environment(GardenStore.self) private var gardenStore
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
            .scrollContentBackground(.hidden)
            .background(Color.canvas)
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
        gardenStore.addCareEvent(event, to: plant)
        dismiss()
    }
}

#Preview {
    CareEventFormView(plant: Plant(id: "preview", name: "Monstera"))
        .environment(GardenStore())
}
