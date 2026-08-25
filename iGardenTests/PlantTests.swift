//
//  PlantTests.swift
//  iGardenTests
//

import Foundation
import SwiftData
import Testing
@testable import iGarden

@MainActor
struct PlantTests {
    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Plant.self, CareEvent.self, PlantPhoto.self,
            configurations: config
        )
        return ModelContext(container)
    }

    // MARK: - Vanningslogikk

    @Test func nesteVanningsdatoBeregnesFraSistVannetPlussIntervall() throws {
        let plant = Plant(name: "Test", wateringIntervalDays: 7)
        let lastWatered = Date(timeIntervalSince1970: 1_700_000_000)
        plant.lastWatered = lastWatered

        let expected = Calendar.current.date(byAdding: .day, value: 7, to: lastWatered)
        #expect(plant.nextWateringDate == expected)
    }

    @Test func aldriVannetPlanteHarIngenNesteDatoOgTrengerVann() throws {
        let plant = Plant(name: "Test")

        #expect(plant.nextWateringDate == nil)
        #expect(plant.wateringStatus == .neverWatered)
        #expect(plant.needsWater)
    }

    @Test func forfaltNaarNesteVanningErPassertMedMerEnnEnDag() throws {
        let plant = Plant(name: "Test", wateringIntervalDays: 7)
        plant.lastWatered = Calendar.current.date(byAdding: .day, value: -10, to: .now)

        #expect(plant.wateringStatus == .overdue)
        #expect(plant.needsWater)
    }

    @Test func vannesIDagNaarNesteVanningErIDag() throws {
        let plant = Plant(name: "Test", wateringIntervalDays: 7)
        plant.lastWatered = Calendar.current.date(byAdding: .day, value: -7, to: .now)

        #expect(plant.wateringStatus == .dueToday)
        #expect(plant.needsWater)
    }

    @Test func okNaarNesteVanningErFremITid() throws {
        let plant = Plant(name: "Test", wateringIntervalDays: 7)
        plant.lastWatered = .now

        #expect(plant.wateringStatus == .ok)
        #expect(!plant.needsWater)
    }

    @Test func utenVanningsplanTrengerAldriVann() throws {
        let plant = Plant(name: "Hageplante", wateringIntervalDays: nil)
        plant.lastWatered = Calendar.current.date(byAdding: .day, value: -30, to: .now)

        #expect(plant.wateringStatus == .noSchedule)
        #expect(!plant.needsWater)
        #expect(plant.nextWateringDate == nil)
    }

    @Test func markWateredSetterSistVannetOgLoggerHendelse() throws {
        let context = try makeContext()
        let plant = Plant(name: "Test", wateringIntervalDays: 7)
        context.insert(plant)

        plant.markWatered()

        #expect(plant.lastWatered != nil)
        #expect(plant.careEvents.count == 1)
        #expect(plant.careEvents.first?.type == .watering)
        #expect(plant.wateringStatus == .ok)
    }

    // MARK: - CRUD og relasjoner

    @Test func planterKanOpprettesOgSlettes() throws {
        let context = try makeContext()
        context.insert(Plant(name: "A"))
        context.insert(Plant(name: "B"))
        try context.save()

        var plants = try context.fetch(FetchDescriptor<Plant>())
        #expect(plants.count == 2)

        context.delete(plants[0])
        try context.save()

        plants = try context.fetch(FetchDescriptor<Plant>())
        #expect(plants.count == 1)
    }

    @Test func slettingAvPlanteKaskadeSletterStellHendelser() throws {
        let context = try makeContext()
        let plant = Plant(name: "Test")
        context.insert(plant)
        plant.markWatered()
        plant.careEvents.append(CareEvent(type: .fertilizing))
        try context.save()

        #expect(try context.fetch(FetchDescriptor<CareEvent>()).count == 2)

        context.delete(plant)
        try context.save()

        #expect(try context.fetch(FetchDescriptor<CareEvent>()).isEmpty)
    }

    @Test func nyesteBildeVelgesSomLatestPhoto() throws {
        let context = try makeContext()
        let plant = Plant(name: "Test")
        context.insert(plant)

        let old = PlantPhoto(imageData: Data([1]), date: Date(timeIntervalSince1970: 1_000))
        let new = PlantPhoto(imageData: Data([2]), date: Date(timeIntervalSince1970: 2_000))
        plant.photos.append(old)
        plant.photos.append(new)

        #expect(plant.latestPhoto?.date == new.date)
    }
}
