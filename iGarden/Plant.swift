//
//  Plant.swift
//  iGarden
//

import Foundation
import SwiftData

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
}

@Model
final class Plant {
    var name: String
    var species: String?
    var location: PlantLocation
    var dateAcquired: Date
    var notes: String
    var wateringIntervalDays: Int
    var lastWatered: Date?

    init(
        name: String,
        species: String? = nil,
        location: PlantLocation = .livingRoom,
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

    var needsWater: Bool {
        guard let nextWateringDate else { return true }
        return nextWateringDate <= .now
    }
}
