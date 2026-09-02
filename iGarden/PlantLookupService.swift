//
//  PlantLookupService.swift
//  iGarden
//
//  KI-oppslag av planter som ikke finnes i den lokale databasen.
//  Gemini (via Firebase AI Logic) returnerer strukturert JSON, og
//  resultatene caches i den delte Firestore-samlingen plantLookups
//  slik at hver plante bare slås opp én gang globalt.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAI

/// Resultatet av et planteoppslag – samme felter som skjemaet trenger.
struct PlantLookupResult: Codable {
    var kjentPlante: Bool
    var norskNavn: String
    var latinskNavn: String
    var phLav: Double
    var phHoey: Double
    /// Råverdi for WaterNeed ("Lite"/"Middels"/"Mye").
    var vannbehov: String
    /// Råverdi for LightNeed ("Skygge"/"Halvskygge"/"Full sol").
    var lysbehov: String
    var vanningsintervallDager: Int

    var waterNeed: WaterNeed? { WaterNeed(rawValue: vannbehov) }
    var lightNeed: LightNeed? { LightNeed(rawValue: lysbehov) }
}

enum PlantLookupError: LocalizedError {
    case unknownPlant(String)
    case unavailable

    var errorDescription: String? {
        switch self {
        case .unknownPlant(let name):
            String(localized: "Fant ingen planteinformasjon om «\(name)». Sjekk stavemåten.")
        case .unavailable:
            String(localized: "KI-oppslaget er ikke tilgjengelig akkurat nå. Prøv igjen senere.")
        }
    }
}

enum PlantLookupService {
    /// Slår opp et plantenavn: først i den delte cachen, deretter hos Gemini.
    static func lookup(name rawName: String) async throws -> PlantLookupResult {
        let query = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard FirebaseApp.app() != nil, !query.isEmpty else { throw PlantLookupError.unavailable }

        let cacheRef = Firestore.firestore().collection("plantLookups").document(cacheKey(for: query))
        if let cached = try? await cacheRef.getDocument(),
           cached.exists,
           let result = try? cached.data(as: PlantLookupResult.self) {
            guard result.kjentPlante else { throw PlantLookupError.unknownPlant(query) }
            return result
        }

        let result = try await askGemini(about: query)
        // Også «ukjent plante» caches, så samme feilsøk ikke koster flere kall.
        try? cacheRef.setData(from: result, merge: false)
        guard result.kjentPlante else { throw PlantLookupError.unknownPlant(query) }
        return result
    }

    private static func askGemini(about name: String) async throws -> PlantLookupResult {
        let schema = Schema.object(properties: [
            "kjentPlante": .boolean(),
            "norskNavn": .string(),
            "latinskNavn": .string(),
            "phLav": .double(),
            "phHoey": .double(),
            "vannbehov": .enumeration(values: ["Lite", "Middels", "Mye"]),
            "lysbehov": .enumeration(values: ["Skygge", "Halvskygge", "Full sol"]),
            "vanningsintervallDager": .integer(),
        ])

        let model = FirebaseAI.firebaseAI(backend: .googleAI()).generativeModel(
            modelName: "gemini-2.5-flash",
            generationConfig: GenerationConfig(
                responseMIMEType: "application/json",
                responseSchema: schema
            )
        )

        let prompt = """
        Du er en norsk gartnerekspert. Brukeren har skrevet inn planten «\(name)» \
        (norsk eller latinsk navn, kan inneholde skrivefeil).

        Hvis dette er en gjenkjennelig plante: sett kjentPlante=true og fyll ut \
        vanlig norsk navn, latinsk navn, foretrukket jord-pH (phLav < phHoey, \
        typisk mellom 3.5 og 8.5), vannbehov, lysbehov og et fornuftig \
        vanningsintervall i dager (1–60) for dyrking i Norge.

        Hvis det ikke er en plante, eller du ikke gjenkjenner den: sett \
        kjentPlante=false og fyll resten med tomme/nøytrale verdier.
        """

        do {
            let response = try await model.generateContent(prompt)
            guard let text = response.text, let data = text.data(using: .utf8) else {
                throw PlantLookupError.unavailable
            }
            var result = try JSONDecoder().decode(PlantLookupResult.self, from: data)
            // Belte og bukser: pH-området holdes gyldig uansett hva modellen svarer.
            result.phLav = min(max(result.phLav, 3.5), 9.0)
            result.phHoey = min(max(result.phHoey, result.phLav), 9.0)
            result.vanningsintervallDager = min(max(result.vanningsintervallDager, 1), 60)
            return result
        } catch is PlantLookupError {
            throw PlantLookupError.unavailable
        } catch is DecodingError {
            throw PlantLookupError.unavailable
        } catch {
            throw PlantLookupError.unavailable
        }
    }

    /// Cache-nøkkel: foldet navn, trygg som dokument-id.
    private static func cacheKey(for query: String) -> String {
        let folded = query.folded
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: " ", with: "-")
        return String(folded.prefix(100))
    }
}
