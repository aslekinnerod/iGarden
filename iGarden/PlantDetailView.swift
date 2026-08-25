//
//  PlantDetailView.swift
//  iGarden
//

import SwiftUI
import SwiftData

// Bilde (APP-12) og stell-historikk (APP-11) legges til her senere.
struct PlantDetailView: View {
    @Environment(\.modelContext) private var modelContext

    let plant: Plant

    @State private var showEditSheet = false
    @State private var showCareEventSheet = false

    private var careHistory: [CareEvent] {
        plant.careEvents.sorted { $0.date > $1.date }
    }

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

            Section {
                if careHistory.isEmpty {
                    Text("Ingen stell registrert ennå")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(careHistory) { event in
                        CareEventRow(event: event)
                    }
                    .onDelete(perform: deleteCareEvents)
                }
            } header: {
                HStack {
                    Text("Stell-historikk")
                    Spacer()
                    Button {
                        showCareEventSheet = true
                    } label: {
                        Label("Registrer stell", systemImage: "plus.circle")
                            .labelStyle(.iconOnly)
                    }
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
        .sheet(isPresented: $showCareEventSheet) {
            CareEventFormView(plant: plant)
        }
    }

    private func deleteCareEvents(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(careHistory[index])
            }
        }
    }

    private var statusColor: Color {
        switch plant.wateringStatus {
        case .overdue: .red
        case .dueToday, .neverWatered: .orange
        case .ok: .green
        }
    }

    private var wateringStatus: some View {
        HStack(spacing: 12) {
            Image(systemName: plant.needsWater ? "drop.triangle.fill" : "checkmark.circle.fill")
                .font(.title2)
                .foregroundStyle(statusColor)
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
        switch plant.wateringStatus {
        case .neverWatered:
            "Ikke vannet ennå"
        case .overdue:
            "Trenger vann – forfalt"
        case .dueToday:
            "Vannes i dag"
        case .ok:
            "Vannes \(plant.nextWateringDate!.formatted(.relative(presentation: .named)))"
        }
    }

    private func waterNow() {
        withAnimation {
            plant.markWatered()
        }
        NotificationManager.reschedule(for: plant)
    }
}

struct CareEventRow: View {
    let event: CareEvent

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: event.type.icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(event.type.rawValue)
                HStack(spacing: 4) {
                    Text(event.date.formatted(date: .abbreviated, time: .omitted))
                    if !event.note.isEmpty {
                        Text("·")
                        Text(event.note)
                            .lineLimit(1)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        PlantDetailView(plant: Plant(name: "Monstera", species: "Monstera deliciosa", wateringIntervalDays: 7))
    }
    .modelContainer(for: Plant.self, inMemory: true)
}
