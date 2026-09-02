//
//  Models.swift
//  iGarden
//
//  Firestore-modeller. Dokumentstrukturen er beskrevet i firestore.rules.
//

import Foundation
import FirebaseFirestore
import UIKit

/// Forhåndsutfylt plasseringsliste. Brukes bare til å foreslå valg –
/// planter lagrer plasseringen som streng, slik at egne navn også fungerer.
/// Råverdiene er lagringsformat (også i Firestore) og må ikke endres.
enum PlantLocation: String, Codable, CaseIterable, Identifiable {
    case livingRoom = "Stue"
    case kitchen = "Kjøkken"
    case bedroom = "Soverom"
    case bathroom = "Bad"
    case hallway = "Gang"
    case office = "Kontor"
    case balcony = "Balkong"
    case garden = "Hage"
    case greenhouse = "Drivhus"
    case other = "Annet"

    var id: String { rawValue }

    var displayName: String {
        String(localized: String.LocalizationValue(rawValue))
    }

    /// Lokaliserer innebygde plasseringsnavn; egne navn vises som de er
    /// (ukjente nøkler faller tilbake til seg selv).
    static func displayName(for storedName: String) -> String {
        String(localized: String.LocalizationValue(storedName))
    }
}

/// Vannbehov. Råverdiene er lagringsformat og må ikke endres.
enum WaterNeed: String, Codable, CaseIterable, Identifiable {
    case low = "Lite"
    case medium = "Middels"
    case high = "Mye"

    var id: String { rawValue }

    var displayName: String {
        String(localized: String.LocalizationValue(rawValue))
    }

    /// Foreslått vanningsintervall i dager for nye planter.
    var suggestedIntervalDays: Int {
        switch self {
        case .low: 14
        case .medium: 7
        case .high: 4
        }
    }
}

/// Lysbehov. Råverdiene er lagringsformat og må ikke endres.
enum LightNeed: String, Codable, CaseIterable, Identifiable {
    case shade = "Skygge"
    case partShade = "Halvskygge"
    case sun = "Full sol"

    var id: String { rawValue }

    var displayName: String {
        String(localized: String.LocalizationValue(rawValue))
    }

    var icon: String {
        switch self {
        case .shade: "cloud"
        case .partShade: "cloud.sun"
        case .sun: "sun.max"
        }
    }
}

enum WateringStatus {
    case overdue
    case dueToday
    case neverWatered
    case ok
    /// Ingen vanningsplan (N/A) – planten følges ikke opp automatisk.
    case noSchedule
}

struct Plant: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var name: String
    var species: String?
    var location: String
    var dateAcquired: Date
    var notes: String
    /// Dager mellom vanninger. nil betyr ingen vanningsplan (N/A).
    var wateringIntervalDays: Int?
    var lastWatered: Date?
    /// Storage-sti til nyeste bilde, denormalisert for liste/detalj-header.
    var photoPath: String?
    /// Foretrukket jord-pH (fra plantedatabasen eller manuelt satt).
    var preferredPHLow: Double?
    var preferredPHHigh: Double?
    /// Vann- og lysbehov (fra plantedatabasen eller manuelt satt).
    var waterNeed: WaterNeed?
    var lightNeed: LightNeed?

    init(
        id: String? = nil,
        name: String,
        species: String? = nil,
        location: String = PlantLocation.livingRoom.rawValue,
        dateAcquired: Date = .now,
        notes: String = "",
        wateringIntervalDays: Int? = 7,
        lastWatered: Date? = nil,
        photoPath: String? = nil,
        preferredPHLow: Double? = nil,
        preferredPHHigh: Double? = nil,
        waterNeed: WaterNeed? = nil,
        lightNeed: LightNeed? = nil
    ) {
        self.id = id
        self.name = name
        self.species = species
        self.location = location
        self.dateAcquired = dateAcquired
        self.notes = notes
        self.wateringIntervalDays = wateringIntervalDays
        self.lastWatered = lastWatered
        self.photoPath = photoPath
        self.preferredPHLow = preferredPHLow
        self.preferredPHHigh = preferredPHHigh
        self.waterNeed = waterNeed
        self.lightNeed = lightNeed
    }

    /// Neste vanningsdato, beregnet fra sist vannet + intervall.
    /// Uten vanningsplan eller registrert vanning finnes ingen dato.
    var nextWateringDate: Date? {
        guard let wateringIntervalDays, let lastWatered else { return nil }
        return Calendar.current.date(byAdding: .day, value: wateringIntervalDays, to: lastWatered)
    }

    var wateringStatus: WateringStatus {
        guard wateringIntervalDays != nil else { return .noSchedule }
        guard let nextWateringDate else { return .neverWatered }
        if Calendar.current.isDateInToday(nextWateringDate) { return .dueToday }
        if nextWateringDate < .now { return .overdue }
        return .ok
    }

    var needsWater: Bool {
        switch wateringStatus {
        case .overdue, .dueToday, .neverWatered: true
        case .ok, .noSchedule: false
        }
    }

    var locationDisplayName: String {
        PlantLocation.displayName(for: location)
    }

    /// Ren hjelper for vanning – brukes av GardenStore og i tester.
    func markingWatered(at date: Date = .now) -> Plant {
        var updated = self
        updated.lastWatered = date
        return updated
    }
}

enum CareEventType: String, Codable, CaseIterable, Identifiable {
    case watering = "Vanning"
    case fertilizing = "Gjødsling"
    case repotting = "Ompotting"
    case pruning = "Beskjæring"
    /// Kalking hever jord-pH – tiltak fra Smart hage.
    case liming = "Kalking"

    var id: String { rawValue }

    /// Råverdien er lagringsformat og må ikke endres; visningen lokaliseres her.
    var displayName: String {
        String(localized: String.LocalizationValue(rawValue))
    }

    var icon: String {
        switch self {
        case .watering: "drop.fill"
        case .fertilizing: "leaf.fill"
        case .repotting: "arrow.triangle.2.circlepath"
        case .pruning: "scissors"
        case .liming: "circle.dotted"
        }
    }
}

/// Vanlige gjødseltyper til hurtigvalg. Lagres som notat på hendelsen
/// (fritekst er brukerinnhold og lokaliseres ikke).
enum Fertilizers {
    static let options = ["Fullgjødsel", "Tomatgjødsel", "Surjordsgjødsel", "Kompost"]
}

struct CareEvent: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var type: CareEventType
    var date: Date
    var note: String

    init(id: String? = nil, type: CareEventType, date: Date = .now, note: String = "") {
        self.id = id
        self.type = type
        self.date = date
        self.note = note
    }
}

struct PlantPhoto: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var date: Date
    var storagePath: String

    init(id: String? = nil, date: Date = .now, storagePath: String) {
        self.id = id
        self.date = date
        self.storagePath = storagePath
    }
}

/// En plassering brukeren har lagt inn selv. Finnes det egne plasseringer,
/// vises bare disse i valglisten – ellers vises den innebygde listen.
struct CustomLocation: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var name: String
    var createdAt: Date
    /// Målt jord-pH i bedet, brukes av Smart hage-anbefalingene.
    var soilPH: Double?

    init(id: String? = nil, name: String, createdAt: Date = .now, soilPH: Double? = nil) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.soilPH = soilPH
    }
}

struct Garden: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var name: String
    var ownerId: String
    var createdAt: Date
}

struct GardenMember: Codable, Identifiable, Hashable {
    /// Dokument-id er brukerens uid.
    @DocumentID var id: String?
    var role: String
    var joinedAt: Date
    /// Skrives av medlemmet selv ved innmelding – users/-dokumenter er private.
    var displayName: String?
    var inviteCode: String?

    var isOwner: Bool { role == "owner" }
}

struct GardenInvite: Codable {
    var gardenId: String
    var createdBy: String
    var expiresAt: Date
    var role: String
}

extension UIImage {
    /// Nedskalerer til maks 1200 px lengste side og komprimerer til JPEG,
    /// så Storage ikke fylles av kamerabilder i full oppløsning.
    func downscaledJPEGData(maxDimension: CGFloat = 1200, quality: CGFloat = 0.8) -> Data? {
        let scale = min(1, maxDimension / max(size.width, size.height))
        guard scale < 1 else { return jpegData(compressionQuality: quality) }
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let resized = UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resized.jpegData(compressionQuality: quality)
    }
}
