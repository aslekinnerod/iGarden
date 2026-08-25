//
//  iGardenApp.swift
//  iGarden
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

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
                .onOpenURL { url in
                    if url.scheme == "igarden" {
                        // Invitasjonslenke: igarden://join?code=XXXXXX
                        if url.host() == "join",
                           let code = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                               .queryItems?.first(where: { $0.name == "code" })?.value {
                            gardenStore.pendingInviteCode = code
                        }
                    } else {
                        // Google Sign-In-tilbakekallet (URL-scheme i Info.plist).
                        GIDSignIn.sharedInstance.handle(url)
                    }
                }
        }
    }
}
