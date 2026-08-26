//
//  SoilAdvisor.swift
//  iGarden
//
//  Jordsmonn-logikken bak «Smart hage»: vurdering av hvordan en plante
//  trives i bedet den står i, og forslag til bed med bedre egnet jord.
//  Plantedatabasen med pH-preferanser ligger i PlantDatabase.swift.
//

import Foundation

enum SoilFit: Equatable {
    /// Bedets pH ligger i plantens foretrukne område.
    case good
    /// Bedet er surere enn planten vil ha (pH for lav).
    case tooAcidic
    /// Bedet er mer kalkrikt enn planten vil ha (pH for høy).
    case tooAlkaline
    /// Mangler pH på bedet eller preferanse på planten.
    case unknown

    static func evaluate(plant: Plant, bedPH: Double?) -> SoilFit {
        guard let bedPH, let low = plant.preferredPHLow, let high = plant.preferredPHHigh else {
            return .unknown
        }
        if bedPH < low { return .tooAcidic }
        if bedPH > high { return .tooAlkaline }
        return .good
    }
}

struct SoilRecommendation: Identifiable {
    var id: String { plant.id ?? plant.name }
    let plant: Plant
    let currentBed: CustomLocation
    let fit: SoilFit
    /// Bedet med best egnet pH, hvis noe finnes.
    let suggestedBed: CustomLocation?
}

enum SoilAdvisor {
    /// Planter som står i bed med målt pH utenfor sitt foretrukne område,
    /// med forslag til bedre bed der det finnes.
    static func recommendations(plants: [Plant], beds: [CustomLocation]) -> [SoilRecommendation] {
        let bedsByName = Dictionary(grouping: beds, by: \.name).compactMapValues(\.first)

        return plants.compactMap { plant in
            guard let currentBed = bedsByName[plant.location] else { return nil }
            let fit = SoilFit.evaluate(plant: plant, bedPH: currentBed.soilPH)
            guard fit == .tooAcidic || fit == .tooAlkaline else { return nil }

            guard let low = plant.preferredPHLow, let high = plant.preferredPHHigh else { return nil }
            let midpoint = (low + high) / 2
            let suggested = beds
                .filter { $0.name != currentBed.name }
                .filter { bed in
                    guard let ph = bed.soilPH else { return false }
                    return ph >= low && ph <= high
                }
                .min { abs(($0.soilPH ?? 0) - midpoint) < abs(($1.soilPH ?? 0) - midpoint) }

            return SoilRecommendation(plant: plant, currentBed: currentBed, fit: fit, suggestedBed: suggested)
        }
    }
}

extension Plant {
    /// «5,5–6,5»-tekst for foretrukket pH, eller nil uten preferanse.
    var preferredPHText: String? {
        guard let preferredPHLow, let preferredPHHigh else { return nil }
        let low = preferredPHLow.formatted(.number.precision(.fractionLength(1)))
        let high = preferredPHHigh.formatted(.number.precision(.fractionLength(1)))
        return "\(low)–\(high)"
    }
}
