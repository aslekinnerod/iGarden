//
//  PlantTests.swift
//  iGardenTests
//

import Foundation
import Testing
import FirebaseFirestore
@testable import iGarden

@MainActor
struct PlantTests {
    // MARK: - Vanningslogikk

    @Test func nesteVanningsdatoBeregnesFraSistVannetPlussIntervall() throws {
        var plant = Plant(name: "Test", wateringIntervalDays: 7)
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
        var plant = Plant(name: "Test", wateringIntervalDays: 7)
        plant.lastWatered = Calendar.current.date(byAdding: .day, value: -10, to: .now)

        #expect(plant.wateringStatus == .overdue)
        #expect(plant.needsWater)
    }

    @Test func vannesIDagNaarNesteVanningErIDag() throws {
        var plant = Plant(name: "Test", wateringIntervalDays: 7)
        plant.lastWatered = Calendar.current.date(byAdding: .day, value: -7, to: .now)

        #expect(plant.wateringStatus == .dueToday)
        #expect(plant.needsWater)
    }

    @Test func okNaarNesteVanningErFremITid() throws {
        var plant = Plant(name: "Test", wateringIntervalDays: 7)
        plant.lastWatered = .now

        #expect(plant.wateringStatus == .ok)
        #expect(!plant.needsWater)
    }

    @Test func utenVanningsplanTrengerAldriVann() throws {
        var plant = Plant(name: "Hageplante", wateringIntervalDays: nil)
        plant.lastWatered = Calendar.current.date(byAdding: .day, value: -30, to: .now)

        #expect(plant.wateringStatus == .noSchedule)
        #expect(!plant.needsWater)
        #expect(plant.nextWateringDate == nil)
    }

    @Test func markingWateredSetterSistVannetUtenAaEndreOriginalen() throws {
        let plant = Plant(name: "Test", wateringIntervalDays: 7)
        let watered = plant.markingWatered()

        #expect(watered.lastWatered != nil)
        #expect(watered.wateringStatus == .ok)
        #expect(plant.lastWatered == nil)
    }

    @Test func markingWateredBakoverITidBrukerOppgittDato() throws {
        let plant = Plant(name: "Test", wateringIntervalDays: 7)
        let date = Date(timeIntervalSince1970: 1_700_000_000)

        #expect(plant.markingWatered(at: date).lastWatered == date)
    }

    // MARK: - Modellkoding (Firestore bruker Codable)

    @Test func plantKodesTilRiktigLagringsformat() throws {
        var plant = Plant(
            id: "skal-ikke-lagres",
            name: "Monstera",
            species: "Monstera deliciosa",
            location: "Vinterhagen",
            notes: "Trives i skygge",
            wateringIntervalDays: nil,
            photoPath: "gardens/g/plants/p/foto.jpg"
        )
        plant.lastWatered = Date(timeIntervalSince1970: 1_700_000_000)

        // @DocumentID kan bare dekodes fra et ekte Firestore-dokument,
        // så her verifiseres selve lagringsformatet i stedet.
        let encoded = try Firestore.Encoder().encode(plant)

        #expect(encoded["name"] as? String == "Monstera")
        #expect(encoded["species"] as? String == "Monstera deliciosa")
        #expect(encoded["location"] as? String == "Vinterhagen")
        #expect(encoded["wateringIntervalDays"] == nil)
        #expect(encoded["lastWatered"] != nil)
        #expect(encoded["photoPath"] as? String == "gardens/g/plants/p/foto.jpg")
        // Dokument-id-en er adressen til dokumentet og skal ikke inn i innholdet.
        #expect(encoded["id"] == nil)
    }

    @Test func careEventTypeBrukerNorskeRaaverdierSomLagringsformat() throws {
        // Råverdiene er lagringsformat i Firestore og må ikke endres.
        #expect(CareEventType.watering.rawValue == "Vanning")
        #expect(CareEventType.fertilizing.rawValue == "Gjødsling")
        #expect(CareEventType.repotting.rawValue == "Ompotting")
        #expect(CareEventType.pruning.rawValue == "Beskjæring")
    }

    @Test func egneOgInnebygdePlasseringerVisesRiktig() throws {
        let custom = Plant(name: "Test", location: "Vinterhagen")

        // Egne navn vises som de er; innebygde har localizable-nøkkel.
        #expect(custom.locationDisplayName == "Vinterhagen")
        #expect(PlantLocation.allCases.contains { $0.rawValue == Plant(name: "T").location })
    }
}
