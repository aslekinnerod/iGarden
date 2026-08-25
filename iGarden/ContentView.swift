//
//  ContentView.swift
//  iGarden
//

import SwiftUI
import SwiftData

// Midlertidig enkel liste – erstattes av planteliste med søk/sortering (APP-7)
// og skjema for ny plante (APP-6).
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Plant.name) private var plants: [Plant]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(plants) { plant in
                    NavigationLink {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(plant.name).font(.title2.bold())
                            if let species = plant.species {
                                Text(species).italic().foregroundStyle(.secondary)
                            }
                            Text(plant.location.rawValue)
                            Text("Vannes hver \(plant.wateringIntervalDays). dag")
                        }
                        .padding()
                    } label: {
                        VStack(alignment: .leading) {
                            Text(plant.name)
                            Text(plant.location.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: deletePlants)
            }
            .navigationTitle("Mine planter")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addPlant) {
                        Label("Legg til plante", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Velg en plante")
        }
    }

    private func addPlant() {
        withAnimation {
            modelContext.insert(Plant(name: "Ny plante \(plants.count + 1)"))
        }
    }

    private func deletePlants(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(plants[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Plant.self, inMemory: true)
}
