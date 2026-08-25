//
//  PlantDetailView.swift
//  iGarden
//

import SwiftUI
import SwiftData

// Bilde (APP-12) og stell-historikk (APP-11) legges til her senere.
struct PlantDetailView: View {
    let plant: Plant

    @State private var showEditSheet = false

    var body: some View {
        List {
            Section {
                wateringStatus
                Button {
                    waterNow()
                } label: {
                    Label("Vannet nå", systemImage: "drop.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            } header: {
                Text("Vanning")
            }

            Section("Om planten") {
                if let species = plant.species {
                    LabeledContent("Art", value: species)
                }
                LabeledContent("Plassering", value: plant.location.rawValue)
                LabeledContent("Anskaffet", value: plant.dateAcquired.formatted(date: .long, time: .omitted))
                LabeledContent("Vanningsintervall", value: "Hver \(plant.wateringIntervalDays). dag")
            }

            if !plant.notes.isEmpty {
                Section("Notater") {
                    Text(plant.notes)
                }
            }
        }
        .navigationTitle(plant.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Rediger") { showEditSheet = true }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            PlantFormView(plant: plant)
        }
    }

    private var wateringStatus: some View {
        HStack(spacing: 12) {
            Image(systemName: plant.needsWater ? "drop.triangle.fill" : "checkmark.circle.fill")
                .font(.title2)
                .foregroundStyle(plant.needsWater ? .orange : .green)
            VStack(alignment: .leading, spacing: 2) {
                Text(statusTitle)
                    .font(.headline)
                if let lastWatered = plant.lastWatered {
                    Text("Sist vannet \(lastWatered.formatted(.relative(presentation: .named)))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var statusTitle: String {
        guard let next = plant.nextWateringDate else {
            return "Ikke vannet ennå"
        }
        if plant.needsWater {
            return "Trenger vann"
        }
        return "Vannes \(next.formatted(.relative(presentation: .named)))"
    }

    private func waterNow() {
        withAnimation {
            plant.lastWatered = .now
        }
        // APP-11: opprett også en CareEvent her når stell-loggen finnes.
    }
}

#Preview {
    NavigationStack {
        PlantDetailView(plant: Plant(name: "Monstera", species: "Monstera deliciosa", wateringIntervalDays: 7))
    }
    .modelContainer(for: Plant.self, inMemory: true)
}
