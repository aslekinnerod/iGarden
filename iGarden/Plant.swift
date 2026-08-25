//
//  Plant.swift
//  iGarden
//

import Foundation
import SwiftData

/// Forhåndsutfylt plasseringsliste. Brukes bare til å foreslå valg –
/// planter lagrer plasseringen som streng, slik at egne navn også fungerer.
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

    /// Råverdien er lagringsformat og må ikke endres; visningen lokaliseres her.
    var displayName: String {
        String(localized: String.LocalizationValue(rawValue))
    }

    /// Lokaliserer innebygde plasseringsnavn; egne navn vises som de er
    /// (ukjente nøkler faller tilbake til seg selv).
    static func displayName(for storedName: String) -> String {
        String(localized: String.LocalizationValue(storedName))
    }
}

@Model
final class Plant {
    var name: String
    var species: String?
    var location: String
    var dateAcquired: Date
    var notes: String
    var wateringIntervalDays: Int
    var lastWatered: Date?

    /// Stabil identifikator for plantens vanningsvarsel.
    var reminderId: UUID = UUID()

    @Relationship(deleteRule: .cascade, inverse: \CareEvent.plant)
    var careEvents: [CareEvent] = []

    @Relationship(deleteRule: .cascade, inverse: \PlantPhoto.plant)
    var photos: [PlantPhoto] = []

    init(
        name: String,
        species: String? = nil,
        location: String = PlantLocation.livingRoom.rawValue,
        dateAcquired: Date = .now,
        notes: String = "",
        wateringIntervalDays: Int = 7,
        lastWatered: Date? = nil
    ) {
        self.name = name
        self.species = species
        self.location = location
        self.dateAcquired = dateAcquired
        self.notes = notes
        self.wateringIntervalDays = wateringIntervalDays
        self.lastWatered = lastWatered
    }

    /// Neste vanningsdato, beregnet fra sist vannet + intervall.
    /// Uten registrert vanning regnes planten som klar for vanning nå.
    var nextWateringDate: Date? {
        guard let lastWatered else { return nil }
        return Calendar.current.date(byAdding: .day, value: wateringIntervalDays, to: lastWatered)
    }

    var wateringStatus: WateringStatus {
        guard let nextWateringDate else { return .neverWatered }
        if Calendar.current.isDateInToday(nextWateringDate) { return .dueToday }
        if nextWateringDate < .now { return .overdue }
        return .ok
    }

    var needsWater: Bool { wateringStatus != .ok }

    var latestPhoto: PlantPhoto? {
        photos.max { $0.date < $1.date }
    }

    var locationDisplayName: String {
        PlantLocation.displayName(for: location)
    }

    func markWatered() {
        lastWatered = .now
        careEvents.append(CareEvent(type: .watering))
    }
}

enum WateringStatus {
    case overdue
    case dueToday
    case neverWatered
    case ok
}
