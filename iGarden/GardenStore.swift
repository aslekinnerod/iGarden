//
//  GardenStore.swift
//  iGarden
//
//  Eneste datalager: Firestore med innebygd offline-cache. Endringer fra
//  andre medlemmer i hagen kommer i sanntid via snapshot-lyttere.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

@Observable
final class GardenStore {
    private(set) var garden: Garden?
    private(set) var plants: [Plant] = []
    private(set) var customLocations: [CustomLocation] = []
    private(set) var members: [GardenMember] = []
    /// Sann når hagen er funnet/opprettet og lytterne er koblet på.
    private(set) var isReady = false
    var errorMessage: String?
    /// Invitasjonskode mottatt via igarden://join-lenke, venter på bekreftelse.
    var pendingInviteCode: String?

    private var plantsListener: ListenerRegistration?
    private var locationsListener: ListenerRegistration?
    private var membersListener: ListenerRegistration?
    private var authListener: AuthStateDidChangeListenerHandle?
    private var startedForUid: String?

    var currentUserId: String? { Auth.auth().currentUser?.uid }

    var isOwner: Bool {
        garden?.ownerId == currentUserId
    }

    var isConfigured: Bool { FirebaseApp.app() != nil }

    private var db: Firestore { Firestore.firestore() }

    private var gardenRef: DocumentReference? {
        guard let id = garden?.id else { return nil }
        return db.collection("gardens").document(id)
    }

    // MARK: - Oppstart

    /// Sørger for innlogget bruker (anonym om nødvendig), finner eller
    /// oppretter hagen, og kobler på sanntidslytterne. Kjøres på nytt
    /// automatisk når bruker-id endres (innlogging/utlogging/sletting).
    func start() {
        guard isConfigured else { return }
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                guard let self else { return }
                if let user {
                    guard self.startedForUid != user.uid else { return }
                    self.startedForUid = user.uid
                    self.detachListeners()
                    await self.bootstrap(uid: user.uid)
                } else {
                    self.startedForUid = nil
                    self.detachListeners()
                    await self.signInAnonymously()
                }
            }
        }
        if Auth.auth().currentUser == nil {
            Task { await signInAnonymously() }
        }
    }

    private func signInAnonymously() async {
        do {
            try await Auth.auth().signInAnonymously()
        } catch {
            errorMessage = String(localized: "Kunne ikke koble til skyen. Sjekk nettforbindelsen og prøv igjen.")
        }
    }

    private func bootstrap(uid: String) async {
        do {
            let userRef = db.collection("users").document(uid)
            let userDoc = try await userRef.getDocument()

            if let existing = userDoc.data()?["primaryGardenId"] as? String {
                // Mistet tilgang (fjernet av eier) eller slettet hage
                // faller igjennom til å opprette en ny egen hage.
                if let gardenDoc = try? await db.collection("gardens").document(existing).getDocument(),
                   gardenDoc.exists,
                   let loaded = try? gardenDoc.data(as: Garden.self) {
                    garden = loaded
                    attachListeners(gardenId: existing)
                    return
                }
            }

            // Sekvensielt, ikke batch: reglene for medlemsdokumentet
            // krever at hagedokumentet allerede finnes.
            let newGarden = db.collection("gardens").document()
            try await newGarden.setData([
                "name": String(localized: "Min hage"),
                "ownerId": uid,
                "createdAt": Timestamp(date: .now),
            ])
            try await newGarden.collection("members").document(uid).setData([
                "role": "owner",
                "joinedAt": Timestamp(date: .now),
                "displayName": Auth.auth().currentUser?.displayName as Any,
            ])
            try await userRef.setData(["primaryGardenId": newGarden.documentID], merge: true)

            let gardenDoc = try await newGarden.getDocument()
            garden = try gardenDoc.data(as: Garden.self)
            attachListeners(gardenId: newGarden.documentID)
        } catch {
            errorMessage = String(localized: "Kunne ikke laste hagen din. Prøv igjen senere.")
        }
    }

    private func attachListeners(gardenId: String) {
        let gardenRef = db.collection("gardens").document(gardenId)

        plantsListener = gardenRef.collection("plants").order(by: "name")
            .addSnapshotListener { [weak self] snapshot, _ in
                let plants = snapshot?.documents.compactMap { try? $0.data(as: Plant.self) } ?? []
                Task { @MainActor in
                    self?.plants = plants
                    self?.isReady = true
                }
            }

        locationsListener = gardenRef.collection("customLocations").order(by: "name")
            .addSnapshotListener { [weak self] snapshot, _ in
                let locations = snapshot?.documents.compactMap { try? $0.data(as: CustomLocation.self) } ?? []
                Task { @MainActor in
                    self?.customLocations = locations
                }
            }

        membersListener = gardenRef.collection("members").order(by: "joinedAt")
            .addSnapshotListener { [weak self] snapshot, _ in
                let members = snapshot?.documents.compactMap { try? $0.data(as: GardenMember.self) } ?? []
                Task { @MainActor in
                    self?.members = members
                }
            }
    }

    private func detachListeners() {
        plantsListener?.remove()
        locationsListener?.remove()
        membersListener?.remove()
        plantsListener = nil
        locationsListener = nil
        membersListener = nil
        garden = nil
        plants = []
        customLocations = []
        members = []
        isReady = false
    }

    // MARK: - Planter

    func addPlant(_ plant: Plant) {
        guard let gardenRef else { return }
        do {
            _ = try gardenRef.collection("plants").addDocument(from: plant)
        } catch {
            errorMessage = String(localized: "Kunne ikke lagre planten.")
        }
    }

    func updatePlant(_ plant: Plant) {
        guard let gardenRef, let id = plant.id else { return }
        do {
            try gardenRef.collection("plants").document(id).setData(from: plant)
            NotificationManager.reschedule(for: plant)
        } catch {
            errorMessage = String(localized: "Kunne ikke lagre planten.")
        }
    }

    func deletePlant(_ plant: Plant) {
        guard let gardenRef, let id = plant.id else { return }
        NotificationManager.cancel(for: plant)
        let plantRef = gardenRef.collection("plants").document(id)
        Task {
            // Undersamlinger og bilder slettes best effort før selve dokumentet.
            for collection in ["careEvents", "photos"] {
                if let docs = try? await plantRef.collection(collection).getDocuments().documents {
                    for doc in docs {
                        if collection == "photos", let path = doc.data()["storagePath"] as? String {
                            try? await Storage.storage().reference(withPath: path).delete()
                        }
                        try? await doc.reference.delete()
                    }
                }
            }
            try? await plantRef.delete()
        }
    }

    func markWatered(_ plant: Plant) {
        guard let gardenRef, let id = plant.id else { return }
        let updated = plant.markingWatered()
        do {
            try gardenRef.collection("plants").document(id).setData(from: updated)
            _ = try gardenRef.collection("plants").document(id)
                .collection("careEvents").addDocument(from: CareEvent(type: .watering))
            NotificationManager.reschedule(for: updated)
        } catch {
            errorMessage = String(localized: "Kunne ikke registrere vanningen.")
        }
    }

    // MARK: - Stell-logg

    func addCareEvent(_ event: CareEvent, to plant: Plant) {
        guard let gardenRef, let id = plant.id else { return }
        do {
            _ = try gardenRef.collection("plants").document(id)
                .collection("careEvents").addDocument(from: event)
            // En vanning bakover i tid skal ikke overskrive en nyere registrering.
            if event.type == .watering, event.date > (plant.lastWatered ?? .distantPast) {
                updatePlant(plant.markingWatered(at: event.date))
            }
        } catch {
            errorMessage = String(localized: "Kunne ikke registrere stellet.")
        }
    }

    func deleteCareEvent(_ event: CareEvent, from plant: Plant) {
        guard let gardenRef, let plantId = plant.id, let eventId = event.id else { return }
        gardenRef.collection("plants").document(plantId)
            .collection("careEvents").document(eventId).delete()
    }

    // MARK: - Bilder

    func addPhoto(_ image: UIImage, to plant: Plant) async {
        guard let gardenRef, let gardenId = garden?.id, let plantId = plant.id,
              let jpeg = image.downscaledJPEGData() else { return }
        let path = "gardens/\(gardenId)/plants/\(plantId)/\(UUID().uuidString).jpg"
        do {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            _ = try await Storage.storage().reference(withPath: path).putDataAsync(jpeg, metadata: metadata)
            await ImageStore.shared.store(image, forPath: path)

            let photo = PlantPhoto(storagePath: path)
            _ = try gardenRef.collection("plants").document(plantId)
                .collection("photos").addDocument(from: photo)

            var updated = plant
            updated.photoPath = path
            try gardenRef.collection("plants").document(plantId).setData(from: updated)
        } catch {
            errorMessage = String(localized: "Kunne ikke laste opp bildet.")
        }
    }

    func deletePhoto(_ photo: PlantPhoto, from plant: Plant) async {
        guard let gardenRef, let plantId = plant.id, let photoId = photo.id else { return }
        let plantRef = gardenRef.collection("plants").document(plantId)
        do {
            try await plantRef.collection("photos").document(photoId).delete()
            try? await Storage.storage().reference(withPath: photo.storagePath).delete()

            // Pekte listebildet på dette bildet, pekes det om til nyeste gjenværende.
            if plant.photoPath == photo.storagePath {
                let remaining = try await plantRef.collection("photos")
                    .order(by: "date", descending: true).limit(to: 1).getDocuments()
                var updated = plant
                updated.photoPath = remaining.documents.first
                    .flatMap { try? $0.data(as: PlantPhoto.self) }?.storagePath
                try plantRef.setData(from: updated)
            }
        } catch {
            errorMessage = String(localized: "Kunne ikke slette bildet.")
        }
    }

    // MARK: - Deling og medlemmer

    enum InviteError: LocalizedError {
        case invalidCode
        case ownGarden

        var errorDescription: String? {
            switch self {
            case .invalidCode:
                String(localized: "Fant ingen gyldig invitasjon med den koden. Sjekk koden, eller be om en ny – koder utløper etter 7 dager.")
            case .ownGarden:
                String(localized: "Du er allerede medlem av denne hagen.")
            }
        }
    }

    /// Lager en invitasjonskode som er gyldig i 7 dager. Kun eieren.
    func createInvite() async throws -> String {
        guard let gardenId = garden?.id, let uid = currentUserId else {
            throw InviteError.invalidCode
        }
        // Kort kode uten lett forvekslbare tegn (I/O/0/1).
        let charset = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        var code: String
        repeat {
            code = String((0..<6).map { _ in charset.randomElement()! })
        } while try await db.collection("invites").document(code).getDocument().exists

        try await db.collection("invites").document(code).setData([
            "gardenId": gardenId,
            "createdBy": uid,
            "expiresAt": Timestamp(date: Calendar.current.date(byAdding: .day, value: 7, to: .now)!),
            "role": "member",
        ])
        return code
    }

    /// Melder brukeren inn i hagen invitasjonskoden peker på, og bytter
    /// til den som primærhage. Brukerens egen hage blir liggende urørt.
    func joinGarden(withCode rawCode: String) async throws {
        guard let uid = currentUserId else { throw InviteError.invalidCode }
        let code = rawCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        let inviteDoc = try await db.collection("invites").document(code).getDocument()
        guard inviteDoc.exists,
              let invite = try? inviteDoc.data(as: GardenInvite.self),
              invite.expiresAt > .now else {
            throw InviteError.invalidCode
        }
        guard invite.gardenId != garden?.id else { throw InviteError.ownGarden }

        try await db.collection("gardens").document(invite.gardenId)
            .collection("members").document(uid).setData([
                "role": "member",
                "joinedAt": Timestamp(date: .now),
                "inviteCode": code,
                "displayName": Auth.auth().currentUser?.displayName as Any,
            ])
        try await db.collection("users").document(uid)
            .setData(["primaryGardenId": invite.gardenId], merge: true)

        detachListeners()
        await bootstrap(uid: uid)
    }

    /// Eieren fjerner et annet medlem fra hagen.
    func removeMember(_ member: GardenMember) {
        guard let gardenRef, let uid = member.id, uid != currentUserId else { return }
        gardenRef.collection("members").document(uid).delete()
    }

    /// Et medlem forlater hagen og får sin egen hage tilbake (eller en ny).
    func leaveGarden() async {
        guard let gardenRef, let uid = currentUserId, !isOwner else { return }
        do {
            try await gardenRef.collection("members").document(uid).delete()
            try await db.collection("users").document(uid)
                .setData(["primaryGardenId": FieldValue.delete()], merge: true)
            detachListeners()
            await bootstrap(uid: uid)
        } catch {
            errorMessage = String(localized: "Kunne ikke forlate hagen.")
        }
    }

    // MARK: - Egne plasseringer

    func addCustomLocation(named name: String) {
        guard let gardenRef else { return }
        do {
            _ = try gardenRef.collection("customLocations")
                .addDocument(from: CustomLocation(name: name))
        } catch {
            errorMessage = String(localized: "Kunne ikke lagre plasseringen.")
        }
    }

    func deleteCustomLocation(_ location: CustomLocation) {
        guard let gardenRef, let id = location.id else { return }
        gardenRef.collection("customLocations").document(id).delete()
    }

    /// Setter (eller fjerner) målt jord-pH på et bed.
    func setSoilPH(_ ph: Double?, for location: CustomLocation) {
        guard let gardenRef, let id = location.id else { return }
        var updated = location
        updated.soilPH = ph.map { ($0 * 10).rounded() / 10 }
        do {
            try gardenRef.collection("customLocations").document(id).setData(from: updated)
        } catch {
            errorMessage = String(localized: "Kunne ikke lagre plasseringen.")
        }
    }
}
