//
//  PlantCatalog.swift
//  iGarden
//
//  Den delte plantekatalogen: Firestore-samlingen plants, felles for alle
//  brukere. Grunnlaget er den kuraterte listen i PlantDatabase.swift, som
//  såes inn én gang (versjonert). Planter funnet med KI-oppslag legges til
//  automatisk, så neste bruker finner dem i autoutfyllingen uten nytt
//  KI-kall – katalogen vokser og antall Gemini-oppslag synker over tid.
//
//  Datamodell:
//    plants/{id}            – PlantInfo (id = foldet navn), source: curated|ai
//    catalogMeta/bundled    – hvilken versjon av den kuraterte listen som er sådd
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

@Observable
final class PlantCatalog {
    /// Sammenslått katalog: kuratert liste + Firestore. Alltid tilgjengelig,
    /// også offline og før innlogging (da bare den kuraterte listen).
    private(set) var plants: [PlantInfo] = PlantDatabase.plants
    /// Det som faktisk ligger i Firestore akkurat nå.
    private(set) var remotePlants: [PlantInfo] = []

    private var listener: ListenerRegistration?
    private var authListener: AuthStateDidChangeListenerHandle?
    private var seedTask: Task<Void, Never>?

    private var isConfigured: Bool { FirebaseApp.app() != nil }
    private var db: Firestore { Firestore.firestore() }
    private var collection: CollectionReference { db.collection("plants") }

    // MARK: - Oppstart

    /// Kobler på sanntidslytteren så snart en bruker er innlogget (reglene
    /// krever innlogging), og sår inn den kuraterte listen ved behov.
    func start() {
        guard isConfigured else { return }
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                guard let self else { return }
                self.listener?.remove()
                self.listener = nil
                self.seedTask?.cancel()
                guard user != nil else {
                    self.remotePlants = []
                    self.rebuild()
                    return
                }
                self.attachListener()
                self.seedTask = Task { await self.seedIfNeeded() }
            }
        }
    }

    private func attachListener() {
        listener = collection.addSnapshotListener { [weak self] snapshot, _ in
            let remote = snapshot?.documents.compactMap { try? $0.data(as: PlantInfo.self) } ?? []
            Task { @MainActor in
                self?.remotePlants = remote
                self?.rebuild()
            }
        }
    }

    private func rebuild() {
        plants = PlantCatalog.merge(bundled: PlantDatabase.plants, remote: remotePlants)
    }

    /// Slår sammen kuratert liste og Firestore. Fjernoppføringer vinner
    /// per id, så rettelser gjort i konsollen slår gjennom uten ny appversjon.
    static func merge(bundled: [PlantInfo], remote: [PlantInfo]) -> [PlantInfo] {
        var byID: [String: PlantInfo] = [:]
        for info in bundled { byID[info.id] = info }
        for info in remote { byID[info.id] = info }
        return byID.values.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    // MARK: - Søk

    func search(_ query: String) -> [PlantInfo] {
        PlantDatabase.search(query, in: plants)
    }

    func match(name: String, species: String?) -> PlantInfo? {
        PlantDatabase.match(name: name, species: species, in: plants)
    }

    // MARK: - KI-oppslag

    /// Slår opp et ukjent navn med KI og lærer katalogen resultatet.
    func lookUp(name: String) async throws -> PlantLookupResult {
        let result = try await PlantLookupService.lookup(name: name)
        learn(result, query: name)
        return result
    }

    /// Legger et KI-funn inn i den delte katalogen. Finnes planten fra før
    /// (typisk under et annet navn/skrivemåte) får den bare søkeordet som
    /// nytt alias – da treffer autoutfyllingen neste gang uten KI.
    func learn(_ result: PlantLookupResult, query: String) {
        guard isConfigured, Auth.auth().currentUser != nil, result.kjentPlante,
              let water = result.waterNeed, let light = result.lightNeed else { return }
        let name = result.norskNavn.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        let latin = result.latinskNavn.trimmingCharacters(in: .whitespacesAndNewlines)
        let alias = query.trimmingCharacters(in: .whitespacesAndNewlines)

        var info = PlantInfo(
            name: name,
            latinName: latin.isEmpty ? nil : latin,
            aliases: [],
            phLow: result.phLav,
            phHigh: result.phHoey,
            water: water,
            light: light,
            source: .ai
        )
        let isNewAlias = !alias.isEmpty && !info.keywords.contains(alias.folded)
        let ref = collection.document(info.id)

        if let existing = plants.first(where: { $0.id == info.id }) {
            // Kuraterte planter som ennå ikke er sådd har ikke noe dokument å
            // oppdatere; ellers legges bare aliaset til (reglene tillater kun det).
            guard isNewAlias, !existing.keywords.contains(alias.folded),
                  remotePlants.contains(where: { $0.id == info.id }) else { return }
            ref.updateData(["aliases": FieldValue.arrayUnion([alias])])
            return
        }

        if isNewAlias {
            info = PlantInfo(name: info.name, latinName: info.latinName, aliases: [alias], phLow: info.phLow, phHigh: info.phHigh, water: info.water, light: info.light, source: .ai)
        }
        do {
            var data = try Firestore.Encoder().encode(info)
            data["createdAt"] = FieldValue.serverTimestamp()
            data["createdBy"] = Auth.auth().currentUser?.uid as Any
            ref.setData(data)
        } catch {
            // Katalogen er en bonus – oppslaget lyktes uansett.
        }
    }

    // MARK: - Såing av kuratert liste

    /// Skriver den kuraterte listen til Firestore hvis den ikke er sådd,
    /// eller er sådd fra en eldre versjon. Idempotent: dokument-id er foldet
    /// navn, så to klienter som sår samtidig skriver det samme.
    private func seedIfNeeded() async {
        let metaRef = db.collection("catalogMeta").document("bundled")
        let seeded = (try? await metaRef.getDocument().data()?["version"] as? Int) ?? 0
        guard !Task.isCancelled, seeded < PlantDatabase.bundledVersion else { return }

        let chunks = PlantDatabase.plants.chunked(into: 400)
        do {
            for (index, chunk) in chunks.enumerated() {
                let batch = db.batch()
                for info in chunk {
                    try batch.setData(from: info, forDocument: collection.document(info.id))
                }
                if index == chunks.count - 1 {
                    batch.setData([
                        "version": PlantDatabase.bundledVersion,
                        "count": PlantDatabase.plants.count,
                        "seededAt": FieldValue.serverTimestamp(),
                        "seededBy": Auth.auth().currentUser?.uid as Any,
                    ], forDocument: metaRef)
                }
                try await batch.commit()
            }
        } catch {
            // Neste oppstart prøver igjen; appen fungerer med den lokale listen.
        }
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map { Array(self[$0..<Swift.min($0 + size, count)]) }
    }
}
