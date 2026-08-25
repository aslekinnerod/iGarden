//
//  AccountView.swift
//  iGarden
//

import SwiftUI
import AuthenticationServices
import FirebaseAuth

/// Kontosiden: Sign in with Apple, utlogging og sletting av konto.
/// Innlogging trengs bare for delt hage – appen fungerer lokalt uten.
struct AccountView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(AuthStore.self) private var authStore

    @State private var errorMessage: String?
    @State private var confirmingDeletion = false

    var body: some View {
        NavigationStack {
            Group {
                if authStore.isSignedIn {
                    signedInView
                } else {
                    signedOutView
                }
            }
            .navigationTitle("Konto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ferdig") { dismiss() }
                }
            }
            .alert(
                "Noe gikk galt",
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: { if !$0 { errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private var signedOutView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "person.2.circle")
                .font(.system(size: 64))
                .foregroundStyle(.green)
            Text("Logg inn for å dele hagen din")
                .font(.title3.bold())
            Text("Med en konto kan du invitere andre til å stelle plantene sammen med deg. Appen fungerer som vanlig uten innlogging.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
            SignInWithAppleButton(.signIn) { request in
                authStore.prepareRequest(request)
            } onCompletion: { result in
                Task {
                    do {
                        try await authStore.signIn(with: result)
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            }
            .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
            .frame(height: 50)
        }
        .padding(24)
    }

    private var signedInView: some View {
        List {
            Section {
                if let name = authStore.user?.displayName, !name.isEmpty {
                    LabeledContent("Navn", value: name)
                }
                if let email = authStore.user?.email, !email.isEmpty {
                    LabeledContent("E-post", value: email)
                }
            }

            Section {
                Button("Logg ut") {
                    do {
                        try authStore.signOut()
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            }

            Section {
                if confirmingDeletion {
                    Text("Bekreft med Apple for å slette kontoen. Dette kan ikke angres.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    SignInWithAppleButton(.continue) { request in
                        authStore.prepareRequest(request)
                    } onCompletion: { result in
                        Task {
                            do {
                                try await authStore.deleteAccount(reauthorizedWith: result)
                                dismiss()
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                        }
                    }
                    .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                    .frame(height: 44)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                } else {
                    Button("Slett konto", role: .destructive) {
                        withAnimation { confirmingDeletion = true }
                    }
                }
            }
        }
    }
}

#Preview {
    AccountView()
        .environment(AuthStore())
}
