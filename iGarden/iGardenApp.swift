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
    @State private var authStore: AuthStore

    init() {
        // Konfigureres bare når GoogleService-Info.plist ligger i prosjektet,
        // slik at appen også kjører i utviklingsmiljø uten Firebase.
        if Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist") != nil {
            FirebaseApp.configure()
        }
        _authStore = State(initialValue: AuthStore())
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
                .environment(authStore)
        }
        .modelContainer(sharedModelContainer)
    }
}
