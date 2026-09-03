//
//  LocationPickerView.swift
//  iGarden
//

import SwiftUI

/// Velger for plassering: viser brukerens egne plasseringer hvis de finnes,
/// ellers den forhåndsutfylte listen. Egne plasseringer kan legges til og slettes.
struct LocationPickerView: View {
    @Environment(GardenStore.self) private var gardenStore
    @Environment(\.dismiss) private var dismiss

    @Binding var selection: String

    @State private var newName = ""

    private var customLocations: [CustomLocation] { gardenStore.customLocations }

    private var usesCustomLocations: Bool { !customLocations.isEmpty }

    var body: some View {
        List {
            Section {
                if usesCustomLocations {
                    ForEach(customLocations) { location in
                        optionRow(location.name)
                    }
                    .onDelete(perform: deleteCustomLocations)
                } else {
                    ForEach(PlantLocation.allCases) { location in
                        optionRow(location.rawValue)
                    }
                }
            } footer: {
                if usesCustomLocations {
                    Text("Du ser dine egne plasseringer. Slett alle for å få tilbake standardlisten.")
                }
            }

            Section("Egen plassering") {
                HStack {
                    TextField("Navn på plassering", text: $newName)
                        .onSubmit(addCustomLocation)
                    Button("Legg til", action: addCustomLocation)
                        .disabled(trimmedNewName.isEmpty)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.canvas)
        .navigationTitle("Plassering")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func optionRow(_ storedName: String) -> some View {
        Button {
            selection = storedName
            dismiss()
        } label: {
            HStack {
                Text(PlantLocation.displayName(for: storedName))
                    .foregroundStyle(.primary)
                Spacer()
                if storedName == selection {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.tint)
                }
            }
        }
    }

    private var trimmedNewName: String {
        newName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func addCustomLocation() {
        let name = trimmedNewName
        guard !name.isEmpty else { return }
        // Finnes navnet fra før, velger vi det i stedet for å lage duplikat.
        if let existing = customLocations.first(where: { $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame }) {
            selection = existing.name
        } else {
            gardenStore.addCustomLocation(named: name)
            selection = name
        }
        newName = ""
        dismiss()
    }

    private func deleteCustomLocations(offsets: IndexSet) {
        for index in offsets {
            gardenStore.deleteCustomLocation(customLocations[index])
        }
    }
}

#Preview {
    NavigationStack {
        LocationPickerView(selection: .constant(PlantLocation.livingRoom.rawValue))
    }
    .environment(GardenStore())
}
