//
//  PlantDetailStore.swift
//  iGarden
//
//  Sanntidslyttere for én plantes stell-logg og bilder.
//

import Foundation
import FirebaseFirestore

@Observable
final class PlantDetailStore {
    private(set) var careEvents: [CareEvent] = []
    private(set) var photos: [PlantPhoto] = []

    private var careEventsListener: ListenerRegistration?
    private var photosListener: ListenerRegistration?

    func start(gardenId: String, plantId: String) {
        stop()
        let plantRef = Firestore.firestore()
            .collection("gardens").document(gardenId)
            .collection("plants").document(plantId)

        careEventsListener = plantRef.collection("careEvents").order(by: "date", descending: true)
            .addSnapshotListener { [weak self] snapshot, _ in
                let events = snapshot?.documents.compactMap { try? $0.data(as: CareEvent.self) } ?? []
                Task { @MainActor in
                    self?.careEvents = events
                }
            }

        photosListener = plantRef.collection("photos").order(by: "date")
            .addSnapshotListener { [weak self] snapshot, _ in
                let photos = snapshot?.documents.compactMap { try? $0.data(as: PlantPhoto.self) } ?? []
                Task { @MainActor in
                    self?.photos = photos
                }
            }
    }

    func stop() {
        careEventsListener?.remove()
        photosListener?.remove()
        careEventsListener = nil
        photosListener = nil
    }
}
