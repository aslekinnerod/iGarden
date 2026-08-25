//
//  iGardenApp.swift
//  iGarden
//
//  Created by Asle Kinnerød on 21/08/2026.
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct iGardenApp: App {
    init() {
        // Konfigureres bare når GoogleService-Info.plist ligger i prosjektet,
        // slik at appen også kjører i utviklingsmiljø uten Firebase.
        if Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist") != nil {
            FirebaseApp.configure()
        }
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Plant.self,
            CareEvent.self,
            PlantPhoto.self,
            CustomLocation.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
