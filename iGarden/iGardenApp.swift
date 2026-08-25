//
//  iGardenApp.swift
//  iGarden
//

import SwiftUI
import FirebaseCore

@main
struct iGardenApp: App {
    @State private var authStore: AuthStore
    @State private var gardenStore: GardenStore

    init() {
        // Konfigureres bare når GoogleService-Info.plist ligger i prosjektet,
        // slik at appen også bygger i utviklingsmiljø uten Firebase.
        if Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist") != nil {
            FirebaseApp.configure()
        }
        _authStore = State(initialValue: AuthStore())
        _gardenStore = State(initialValue: GardenStore())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authStore)
                .environment(gardenStore)
                .onAppear {
                    gardenStore.start()
                }
        }
    }
}
