//
//  PlantDetailView.swift
//  iGarden
//

import SwiftUI
import PhotosUI

struct PlantDetailView: View {
    @Environment(GardenStore.self) private var gardenStore
    @Environment(\.dismiss) private var dismiss

    /// Øyeblikksbilde fra navigasjonen; den levende varianten hentes fra storen.
    let plant: Plant

    @State private var detailStore = PlantDetailStore()
    @State private var showEditSheet = false
    @State private var showCareEventSheet = false
    @State private var showCamera = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoToView: PlantPhoto?
    @State private var showSlideshow = false

    /// Sanntidsversjonen av planten – oppdateres når andre medlemmer endrer den.
    private var livePlant: Plant {
        gardenStore.plants.first { $0.id == plant.id } ?? plant
    }

    private var careHistory: [CareEvent] { detailStore.careEvents }

    private var photoTimeline: [PlantPhoto] { detailStore.photos }

    var body: some View {
        List {
            Section {
                photoHeader
                    .listRowInsets(EdgeInsets())
            }

            Section {
                wateringStatus
                HStack(spacing: DS.Spacing.rowGap) {
                    Button {
                        gardenStore.markWatered(livePlant)
                    } label: {
                        Label("Vannet nå", systemImage: "drop.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    Menu {
                        // Gjødseltypen lagres som notat på hendelsen.
                        ForEach(Fertilizers.options, id: \.self) { fertilizer in
                            Button(fertilizer) {
                                gardenStore.addCareEvent(CareEvent(type: .fertilizing, note: fertilizer), to: livePlant)
                            }
                        }
                        Button("Gjødsle uten type") {
                            gardenStore.addCareEvent(CareEvent(type: .fertilizing), to: livePlant)
                        }
                    } label: {
                        Label("Gjødsle", systemImage: "leaf.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            } header: {
                Text("Vanning og stell")
            }

            Section("Om planten") {
                if let species = livePlant.species {
                    LabeledContent("Art", value: species)
                }
                LabeledContent("Plassering", value: livePlant.locationDisplayName)
                LabeledContent("Anskaffet", value: livePlant.dateAcquired.formatted(date: .long, time: .omitted))
                if let intervalDays = livePlant.wateringIntervalDays {
                    LabeledContent("Vanningsintervall", value: String(localized: "Hver \(intervalDays). dag"))
                }
                if let water = livePlant.waterNeed {
                    LabeledContent {
                        Text(water.displayName)
                    } label: {
                        Label("Vannbehov", systemImage: "drop")
                    }
                }
                if let light = livePlant.lightNeed {
                    LabeledContent {
                        Text(light.displayName)
                    } label: {
                        Label("Lysbehov", systemImage: light.icon)
                    }
                }
                if let phText = livePlant.preferredPHText {
                    LabeledContent("Jord (pH)", value: phText)
                }
                soilFitRow
            }

            if !livePlant.notes.isEmpty {
                Section("Notater") {
                    Text(livePlant.notes)
                }
            }

            if photoTimeline.count > 1 {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: DS.Spacing.s3) {
                            ForEach(photoTimeline) { photo in
                                timelineCell(photo)
                            }
                        }
                        .padding(.vertical, DS.Spacing.s1)
                    }
                } header: {
                    HStack {
                        Text("Veksttidslinje")
                        Spacer()
                        Button {
                            showSlideshow = true
                        } label: {
                            Label("Spill av", systemImage: "play.circle.fill")
                                .labelStyle(.iconOnly)
                        }
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
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.canvas)
        .navigationTitle(livePlant.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Rediger") { showEditSheet = true }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            PlantFormView(plant: livePlant)
        }
        .sheet(isPresented: $showCareEventSheet) {
            CareEventFormView(plant: livePlant)
        }
        .sheet(item: $photoToView) { photo in
            PhotoViewer(photo: photo)
        }
        .fullScreenCover(isPresented: $showSlideshow) {
            SlideshowView(photos: photoTimeline)
        }
        .task {
            guard let gardenId = gardenStore.garden?.id, let plantId = plant.id else { return }
            detailStore.start(gardenId: gardenId, plantId: plantId)
        }
        .onDisappear {
            detailStore.stop()
        }
        .onChange(of: gardenStore.plants) {
            // Slettes planten av et annet medlem, lukkes detaljsiden.
            if gardenStore.isReady, !gardenStore.plants.contains(where: { $0.id == plant.id }) {
                dismiss()
            }
        }
    }

    /// Trivselsvurdering mot bedets målte pH, når begge deler finnes.
    @ViewBuilder
    private var soilFitRow: some View {
        if let bed = gardenStore.customLocations.first(where: { $0.name == livePlant.location }),
           let bedPH = bed.soilPH {
            let fit = SoilFit.evaluate(plant: livePlant, bedPH: bedPH)
            switch fit {
            case .good:
                Label {
                    Text("Trives i jorden her (pH \(bedPH.formatted(.number.precision(.fractionLength(1)))))")
                } icon: {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(Color.statusOK)
                }
            case .tooAcidic:
                Label {
                    Text("Jorden her er for sur (pH \(bedPH.formatted(.number.precision(.fractionLength(1))))) – se Smart hage")
                } icon: {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(Color.statusDue)
                }
            case .tooAlkaline:
                Label {
                    Text("Jorden her er for kalkrik (pH \(bedPH.formatted(.number.precision(.fractionLength(1))))) – se Smart hage")
                } icon: {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(Color.statusDue)
                }
            case .unknown:
                EmptyView()
            }
        }
    }

    private var statusColor: Color {
        switch livePlant.wateringStatus {
        case .overdue: .statusOverdue
        case .dueToday, .neverWatered: .statusDue
        case .ok: .statusOK
        case .noSchedule: .secondary
        }
    }

    private var statusIcon: String {
        switch livePlant.wateringStatus {
        case .noSchedule: "minus.circle.fill"
        case .ok: "checkmark.circle.fill"
        case .overdue, .dueToday, .neverWatered: "drop.triangle.fill"
        }
    }

    private var wateringStatus: some View {
        HStack(spacing: DS.Spacing.s3) {
            Image(systemName: statusIcon)
                .font(.title2)
                .foregroundStyle(statusColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(statusTitle)
                    .font(.headline)
                if let lastWatered = livePlant.lastWatered {
                    Text("Sist vannet \(lastWatered.formatted(.relative(presentation: .named)))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var statusTitle: String {
        switch livePlant.wateringStatus {
        case .neverWatered:
            String(localized: "Ikke vannet ennå")
        case .overdue:
            String(localized: "Trenger vann – forfalt")
        case .dueToday:
            String(localized: "Vannes i dag")
        case .ok:
            String(localized: "Vannes \(livePlant.nextWateringDate!.formatted(.relative(presentation: .named)))")
        case .noSchedule:
            String(localized: "Ingen vanningsplan")
        }
    }

    /// Hero-foto med plantens navn over en grønn toning, i samme
    /// språk som velkomstskjermen og plantelisten.
    private var photoHeader: some View {
        ZStack(alignment: .bottomTrailing) {
            PlantPhotoView(path: livePlant.photoPath) {
                ZStack {
                    Rectangle()
                        .fill(Color.fillLeaf)
                    Image(systemName: "leaf")
                        .font(.system(size: 56))
                        .foregroundStyle(Color.fillLeafForeground)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: DS.Spacing.heroPhoto)
            .clipped()
            .overlay {
                Color.heroScrim
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(livePlant.name)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    if let species = livePlant.species, !species.isEmpty {
                        Text(species)
                            .font(.subheadline)
                            .italic()
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }
                .padding(DS.Spacing.s4)
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
                    .padding(DS.Spacing.rowGap)
                    .background(.thinMaterial, in: Circle())
                    .padding(DS.Spacing.rowGap)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.hero))
        .padding(.horizontal, DS.Spacing.listInset)
        .padding(.bottom, DS.Spacing.s2)
        .onChange(of: selectedPhotoItem) {
            Task { await importSelectedPhoto() }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraPicker { image in
                Task { await gardenStore.addPhoto(image, to: livePlant) }
            }
            .ignoresSafeArea()
        }
    }

    private func timelineCell(_ photo: PlantPhoto) -> some View {
        VStack(spacing: 4) {
            PlantPhotoView(path: photo.storagePath) {
                RoundedRectangle(cornerRadius: DS.Radius.photo)
                    .fill(Color.fillLeaf)
            }
            .frame(width: 96, height: 96)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.photo))
            Text(photo.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .onTapGesture { photoToView = photo }
        .contextMenu {
            Button(role: .destructive) {
                Task { await gardenStore.deletePhoto(photo, from: livePlant) }
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
        await gardenStore.addPhoto(image, to: livePlant)
    }

    private func deleteCareEvents(offsets: IndexSet) {
        for index in offsets {
            gardenStore.deleteCareEvent(careHistory[index], from: livePlant)
        }
    }
}

/// Enkel fullvisning av ett bilde med dato.
struct PhotoViewer: View {
    @Environment(\.dismiss) private var dismiss

    let photo: PlantPhoto

    var body: some View {
        NavigationStack {
            PlantPhotoView(path: photo.storagePath) {
                ProgressView()
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
        HStack(spacing: DS.Spacing.rowGap) {
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
        PlantDetailView(plant: Plant(id: "preview", name: "Monstera", species: "Monstera deliciosa"))
    }
    .environment(GardenStore())
    .environment(PlantCatalog())
}
