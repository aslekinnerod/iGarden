//
//  PlantDetailView.swift
//  iGarden
//

import SwiftUI
import SwiftData
import PhotosUI

// Bilde (APP-12) og stell-historikk (APP-11) legges til her senere.
struct PlantDetailView: View {
    @Environment(\.modelContext) private var modelContext

    let plant: Plant

    @State private var showEditSheet = false
    @State private var showCareEventSheet = false
    @State private var showCamera = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoToView: PlantPhoto?

    private var photoTimeline: [PlantPhoto] {
        plant.photos.sorted { $0.date < $1.date }
    }

    private var careHistory: [CareEvent] {
        plant.careEvents.sorted { $0.date > $1.date }
    }

    var body: some View {
        List {
            Section {
                photoHeader
                    .listRowInsets(EdgeInsets())
            }

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
                LabeledContent("Plassering", value: plant.locationDisplayName)
                LabeledContent("Anskaffet", value: plant.dateAcquired.formatted(date: .long, time: .omitted))
                LabeledContent("Vanningsintervall", value: String(localized: "Hver \(plant.wateringIntervalDays). dag"))
            }

            if !plant.notes.isEmpty {
                Section("Notater") {
                    Text(plant.notes)
                }
            }

            if photoTimeline.count > 1 {
                Section("Veksttidslinje") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 12) {
                            ForEach(photoTimeline) { photo in
                                timelineCell(photo)
                            }
                        }
                        .padding(.vertical, 4)
                    }
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
        .sheet(item: $photoToView) { photo in
            PhotoViewer(photo: photo)
        }
    }

    private var photoHeader: some View {
        ZStack(alignment: .bottomTrailing) {
            if let image = plant.latestPhoto?.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                    .clipped()
            } else {
                ZStack {
                    Rectangle()
                        .fill(.green.opacity(0.12))
                    Image(systemName: "leaf")
                        .font(.system(size: 56))
                        .foregroundStyle(.green.opacity(0.5))
                }
                .frame(height: 220)
            }

            Menu {
                if CameraPicker.isAvailable {
                    Button {
                        showCamera = true
                    } label: {
                        Label("Ta bilde", systemImage: "camera")
                    }
                }
                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    Label("Velg fra biblioteket", systemImage: "photo.on.rectangle")
                }
            } label: {
                Label("Legg til bilde", systemImage: "camera.fill")
                    .labelStyle(.iconOnly)
                    .padding(10)
                    .background(.thinMaterial, in: Circle())
                    .padding(10)
            }
        }
        .onChange(of: selectedPhotoItem) {
            Task { await importSelectedPhoto() }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicker { image in
                addPhoto(image)
            }
            .ignoresSafeArea()
        }
    }

    private func timelineCell(_ photo: PlantPhoto) -> some View {
        VStack(spacing: 4) {
            if let image = photo.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 96, height: 96)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            Text(photo.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .onTapGesture { photoToView = photo }
        .contextMenu {
            Button(role: .destructive) {
                withAnimation { modelContext.delete(photo) }
            } label: {
                Label("Slett bilde", systemImage: "trash")
            }
        }
    }

    private func importSelectedPhoto() async {
        guard let item = selectedPhotoItem else { return }
        selectedPhotoItem = nil
        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }
        addPhoto(image)
    }

    private func addPhoto(_ image: UIImage) {
        guard let jpeg = image.downscaledJPEGData() else { return }
        withAnimation {
            plant.photos.append(PlantPhoto(imageData: jpeg))
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
            String(localized: "Ikke vannet ennå")
        case .overdue:
            String(localized: "Trenger vann – forfalt")
        case .dueToday:
            String(localized: "Vannes i dag")
        case .ok:
            String(localized: "Vannes \(plant.nextWateringDate!.formatted(.relative(presentation: .named)))")
        }
    }

    private func waterNow() {
        withAnimation {
            plant.markWatered()
        }
        NotificationManager.reschedule(for: plant)
    }
}

/// Enkel fullvisning av ett bilde med dato.
struct PhotoViewer: View {
    @Environment(\.dismiss) private var dismiss

    let photo: PlantPhoto

    var body: some View {
        NavigationStack {
            Group {
                if let image = photo.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .navigationTitle(photo.date.formatted(date: .long, time: .omitted))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ferdig") { dismiss() }
                }
            }
        }
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
                Text(event.type.displayName)
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
