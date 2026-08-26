//
//  SoilAdvisor.swift
//  iGarden
//
//  Jordsmonn-logikken bak «Smart hage»: en innebygd database over vanlige
//  hageplanters pH-preferanser, vurdering av hvordan en plante trives i
//  bedet den står i, og forslag til bed med bedre egnet jord.
//

import Foundation

struct SoilPreference {
    /// Visningsnavn på treffet, f.eks. «Rhododendron».
    let name: String
    /// Søkeord som matches mot plantens navn og art (små bokstaver).
    let keywords: [String]
    let low: Double
    let high: Double
}

enum SoilDatabase {
    /// Kuratert liste over vanlige hageplanter med foretrukket jord-pH.
    /// Norske og latinske navn som søkeord.
    static let entries: [SoilPreference] = [
        SoilPreference(name: "Rhododendron", keywords: ["rhododendron"], low: 4.5, high: 6.0),
        SoilPreference(name: "Asalea", keywords: ["asalea", "azalea"], low: 4.5, high: 6.0),
        SoilPreference(name: "Blåbær", keywords: ["blåbær", "vaccinium"], low: 4.0, high: 5.5),
        SoilPreference(name: "Tyttebær", keywords: ["tyttebær"], low: 4.5, high: 5.5),
        SoilPreference(name: "Røsslyng", keywords: ["røsslyng", "lyng", "calluna", "erica"], low: 4.5, high: 5.5),
        SoilPreference(name: "Hortensia", keywords: ["hortensia", "hydrangea"], low: 5.0, high: 6.5),
        SoilPreference(name: "Kamelia", keywords: ["kamelia", "camellia"], low: 5.0, high: 6.5),
        SoilPreference(name: "Magnolia", keywords: ["magnolia"], low: 5.5, high: 6.5),
        SoilPreference(name: "Bregne", keywords: ["bregne"], low: 5.0, high: 6.5),
        SoilPreference(name: "Astilbe", keywords: ["astilbe"], low: 5.5, high: 6.5),
        SoilPreference(name: "Lupin", keywords: ["lupin"], low: 5.5, high: 7.0),
        SoilPreference(name: "Potet", keywords: ["potet", "solanum tuberosum"], low: 5.0, high: 6.5),
        SoilPreference(name: "Jordbær", keywords: ["jordbær", "fragaria"], low: 5.5, high: 6.5),
        SoilPreference(name: "Bringebær", keywords: ["bringebær", "rubus idaeus"], low: 5.5, high: 6.5),
        SoilPreference(name: "Rips og solbær", keywords: ["rips", "solbær", "ribes"], low: 6.0, high: 6.5),
        SoilPreference(name: "Dill", keywords: ["dill"], low: 5.5, high: 6.5),
        SoilPreference(name: "Mais", keywords: ["mais", "zea mays"], low: 5.5, high: 7.0),
        SoilPreference(name: "Gressplen", keywords: ["gress", "plen"], low: 5.5, high: 7.0),
        SoilPreference(name: "Tomat", keywords: ["tomat", "lycopersicum"], low: 6.0, high: 6.8),
        SoilPreference(name: "Agurk", keywords: ["agurk", "cucumis"], low: 6.0, high: 7.0),
        SoilPreference(name: "Squash", keywords: ["squash", "cucurbita"], low: 6.0, high: 7.5),
        SoilPreference(name: "Gulrot", keywords: ["gulrot", "daucus"], low: 6.0, high: 7.0),
        SoilPreference(name: "Salat", keywords: ["salat", "lactuca"], low: 6.0, high: 7.0),
        SoilPreference(name: "Løk", keywords: ["løk", "allium cepa"], low: 6.0, high: 7.0),
        SoilPreference(name: "Gressløk", keywords: ["gressløk"], low: 6.0, high: 7.0),
        SoilPreference(name: "Purre", keywords: ["purre"], low: 6.0, high: 7.5),
        SoilPreference(name: "Persille", keywords: ["persille"], low: 6.0, high: 7.0),
        SoilPreference(name: "Basilikum", keywords: ["basilikum", "ocimum"], low: 6.0, high: 7.5),
        SoilPreference(name: "Mynte", keywords: ["mynte", "mentha"], low: 6.0, high: 7.5),
        SoilPreference(name: "Rosmarin", keywords: ["rosmarin"], low: 6.0, high: 7.5),
        SoilPreference(name: "Rose", keywords: ["rose", "rosa "], low: 6.0, high: 7.0),
        SoilPreference(name: "Tulipan", keywords: ["tulipan", "tulipa"], low: 6.0, high: 7.0),
        SoilPreference(name: "Narsiss", keywords: ["narsiss", "påskelilje", "narcissus"], low: 6.0, high: 7.0),
        SoilPreference(name: "Iris", keywords: ["iris"], low: 6.0, high: 7.5),
        SoilPreference(name: "Solsikke", keywords: ["solsikke", "helianthus"], low: 6.0, high: 7.5),
        SoilPreference(name: "Hosta", keywords: ["hosta"], low: 6.0, high: 7.5),
        SoilPreference(name: "Eple", keywords: ["eple", "malus"], low: 6.0, high: 7.0),
        SoilPreference(name: "Plomme", keywords: ["plomme", "prunus"], low: 6.0, high: 7.5),
        SoilPreference(name: "Erter", keywords: ["ert", "pisum"], low: 6.0, high: 7.5),
        SoilPreference(name: "Bønner", keywords: ["bønne", "phaseolus"], low: 6.0, high: 7.5),
        SoilPreference(name: "Rødbet", keywords: ["rødbet", "beta vulgaris"], low: 6.0, high: 7.5),
        SoilPreference(name: "Timian", keywords: ["timian", "thymus"], low: 6.5, high: 7.5),
        SoilPreference(name: "Lavendel", keywords: ["lavendel", "lavandula"], low: 6.5, high: 7.5),
        SoilPreference(name: "Pion", keywords: ["pion", "paeonia"], low: 6.5, high: 7.5),
        SoilPreference(name: "Klematis", keywords: ["klematis", "clematis"], low: 6.5, high: 7.5),
        SoilPreference(name: "Syrin", keywords: ["syrin", "syringa"], low: 6.5, high: 7.5),
        SoilPreference(name: "Kål", keywords: ["kål", "brassica"], low: 6.5, high: 7.5),
        SoilPreference(name: "Spinat", keywords: ["spinat", "spinacia"], low: 6.5, high: 7.5),
    ]

    /// Finner pH-preferanse fra plantens navn og art. Lengste søkeord
    /// vinner, så «gressløk» ikke matches som «gress».
    static func match(name: String, species: String?) -> SoilPreference? {
        let haystack = (name + " " + (species ?? "")).lowercased()
        var best: (entry: SoilPreference, keywordLength: Int)?
        for entry in entries {
            for keyword in entry.keywords where haystack.contains(keyword) {
                if keyword.count > (best?.keywordLength ?? 0) {
                    best = (entry, keyword.count)
                }
            }
        }
        return best?.entry
    }
}

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
