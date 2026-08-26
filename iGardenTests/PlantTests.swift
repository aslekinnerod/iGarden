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

    // MARK: - Smart hage (jord-pH)

    @Test func plantedatabasenFinnerPreferanseFraNavn() throws {
        let match = SoilDatabase.match(name: "Rhododendron ved trappen", species: nil)
        #expect(match?.name == "Rhododendron")
        #expect(match?.low == 4.5)
        #expect(match?.high == 6.0)
    }

    @Test func plantedatabasenFinnerPreferanseFraLatinskArt() throws {
        let match = SoilDatabase.match(name: "Busken min", species: "Vaccinium myrtillus")
        #expect(match?.name == "Blåbær")
    }

    @Test func lengsteSoekeordVinner() throws {
        // «Gressløk» skal ikke matches som «gress» (plen).
        let match = SoilDatabase.match(name: "Gressløk", species: nil)
        #expect(match?.name == "Gressløk")
    }

    @Test func jordvurderingSkillerSurtOgKalkrikt() throws {
        let plant = Plant(name: "Blåbær", preferredPHLow: 4.0, preferredPHHigh: 5.5)

        #expect(SoilFit.evaluate(plant: plant, bedPH: 5.0) == .good)
        #expect(SoilFit.evaluate(plant: plant, bedPH: 3.5) == .tooAcidic)
        #expect(SoilFit.evaluate(plant: plant, bedPH: 7.0) == .tooAlkaline)
        #expect(SoilFit.evaluate(plant: plant, bedPH: nil) == .unknown)
        #expect(SoilFit.evaluate(plant: Plant(name: "Ukjent"), bedPH: 6.0) == .unknown)
    }

    @Test func anbefalingForeslaarBedMedRiktigPH() throws {
        let surtBed = CustomLocation(id: "a", name: "Surbed", soilPH: 4.8)
        let kalkBed = CustomLocation(id: "b", name: "Kalkbed", soilPH: 7.2)
        let blaabaer = Plant(id: "p1", name: "Blåbær", location: "Kalkbed", preferredPHLow: 4.0, preferredPHHigh: 5.5)
        let lavendel = Plant(id: "p2", name: "Lavendel", location: "Kalkbed", preferredPHLow: 6.5, preferredPHHigh: 7.5)

        let recommendations = SoilAdvisor.recommendations(plants: [blaabaer, lavendel], beds: [surtBed, kalkBed])

        // Blåbæret står for kalkrikt og skal flyttes til surbedet;
        // lavendelen trives og skal ikke nevnes.
        #expect(recommendations.count == 1)
        #expect(recommendations.first?.plant.name == "Blåbær")
        #expect(recommendations.first?.fit == .tooAlkaline)
        #expect(recommendations.first?.suggestedBed?.name == "Surbed")
    }

    @Test func anbefalingUtenPassendeBedGirIngenForslag() throws {
        let kalkBed = CustomLocation(id: "b", name: "Kalkbed", soilPH: 7.2)
        let blaabaer = Plant(id: "p1", name: "Blåbær", location: "Kalkbed", preferredPHLow: 4.0, preferredPHHigh: 5.5)

        let recommendations = SoilAdvisor.recommendations(plants: [blaabaer], beds: [kalkBed])

        #expect(recommendations.count == 1)
        #expect(recommendations.first?.suggestedBed == nil)
    }

    @Test func egneOgInnebygdePlasseringerVisesRiktig() throws {
        let custom = Plant(name: "Test", location: "Vinterhagen")

        // Egne navn vises som de er; innebygde har localizable-nøkkel.
        #expect(custom.locationDisplayName == "Vinterhagen")
        #expect(PlantLocation.allCases.contains { $0.rawValue == Plant(name: "T").location })
    }
}
