//
//  ContentView.swift
//  iGarden
//

import SwiftUI
import SwiftData

// Midlertidig enkel liste – erstattes av planteliste med søk/sortering (APP-7).
// Detaljvisningen her er også en plassholder frem til APP-8.
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Plant.name) private var plants: [Plant]

    @State private var showAddPlant = false
    @State private var plantToEdit: Plant?

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(plants) { plant in
                    NavigationLink {
                        plantDetail(plant)
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
            .sheet(item: $plantToEdit) { plant in
                PlantFormView(plant: plant)
            }
        } detail: {
            Text("Velg en plante")
        }
    }

    private func plantDetail(_ plant: Plant) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(plant.name).font(.title2.bold())
            if let species = plant.species {
                Text(species).italic().foregroundStyle(.secondary)
            }
            Text(plant.location.rawValue)
            Text("Vannes hver \(plant.wateringIntervalDays). dag")
            if !plant.notes.isEmpty {
                Text(plant.notes).padding(.top, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Rediger") { plantToEdit = plant }
            }
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
