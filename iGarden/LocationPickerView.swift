//
//  LocationPickerView.swift
//  iGarden
//

import SwiftUI
import SwiftData

/// Velger for plassering: viser brukerens egne plasseringer hvis de finnes,
/// ellers den forhåndsutfylte listen. Egne plasseringer kan legges til og slettes.
struct LocationPickerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CustomLocation.name) private var customLocations: [CustomLocation]

    @Binding var selection: String

    @State private var newName = ""

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
            modelContext.insert(CustomLocation(name: name))
            selection = name
        }
        newName = ""
        dismiss()
    }

    private func deleteCustomLocations(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(customLocations[index])
            }
        }
    }
}

#Preview {
    NavigationStack {
        LocationPickerView(selection: .constant(PlantLocation.livingRoom.rawValue))
    }
    .modelContainer(for: CustomLocation.self, inMemory: true)
}
