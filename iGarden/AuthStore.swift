//
//  AuthStore.swift
//  iGarden
//

import Foundation
import Security
import CryptoKit
import AuthenticationServices
import FirebaseCore
import FirebaseAuth

/// Innloggingstilstand og Sign in with Apple-flyt mot Firebase Auth.
/// Nonce-basert etter Firebases anbefalte oppskrift.
@Observable
final class AuthStore {
    private(set) var user: User?

    /// Sann når brukeren har en ekte konto (ikke bare den automatiske anonyme).
    var hasAccount: Bool { user != nil && user?.isAnonymous == false }

    /// Firebase er bare konfigurert når GoogleService-Info.plist ligger i appen.
    var isFirebaseConfigured: Bool { FirebaseApp.app() != nil }

    private var currentNonce: String?
    private var listenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        guard FirebaseApp.app() != nil else { return }
        user = Auth.auth().currentUser
        listenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.user = user
            }
        }
    }

    enum AuthError: LocalizedError {
        case invalidCredential

        var errorDescription: String? {
            String(localized: "Innloggingen kunne ikke fullføres. Prøv igjen.")
        }
    }

    // MARK: - Sign in with Apple

    func prepareRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = Self.randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = Self.sha256(nonce)
    }

    func signIn(with result: Result<ASAuthorization, Error>) async throws {
        let (appleCredential, idToken, nonce) = try extractCredential(from: result)
        let credential = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: nonce,
            fullName: appleCredential.fullName
        )
        // Den automatiske anonyme kontoen kobles til Apple-identiteten,
        // slik at hagen brukeren allerede har beholdes.
        if let current = Auth.auth().currentUser, current.isAnonymous {
            do {
                let linked = try await current.link(with: credential)
                user = linked.user
            } catch let error as NSError
                where error.code == AuthErrorCode.credentialAlreadyInUse.rawValue {
                // Apple-id-en har allerede en konto fra før – logg inn på den.
                let existing = (error.userInfo[AuthErrorUserInfoUpdatedCredentialKey] as? AuthCredential) ?? credential
                try await Auth.auth().signIn(with: existing)
            }
        } else {
            try await Auth.auth().signIn(with: credential)
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    /// Sletting krever fersk innlogging, så brukeren bekrefter med en ny
    /// Apple-runde. Apple-tokenet trekkes også tilbake (App Store-krav).
    func deleteAccount(reauthorizedWith result: Result<ASAuthorization, Error>) async throws {
        guard let user = Auth.auth().currentUser else { throw AuthError.invalidCredential }
        let (appleCredential, idToken, nonce) = try extractCredential(from: result)
        let credential = OAuthProvider.appleCredential(withIDToken: idToken, rawNonce: nonce, fullName: nil)
        try await user.reauthenticate(with: credential)
        if let codeData = appleCredential.authorizationCode,
           let authorizationCode = String(data: codeData, encoding: .utf8) {
            try await Auth.auth().revokeToken(withAuthorizationCode: authorizationCode)
        }
        try await user.delete()
    }

    private func extractCredential(
        from result: Result<ASAuthorization, Error>
    ) throws -> (ASAuthorizationAppleIDCredential, idToken: String, nonce: String) {
        switch result {
        case .failure(let error):
            throw error
        case .success(let authorization):
            guard let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = appleCredential.identityToken,
                  let idToken = String(data: tokenData, encoding: .utf8),
                  let nonce = currentNonce else {
                throw AuthError.invalidCredential
            }
            return (appleCredential, idToken, nonce)
        }
    }

    // MARK: - Nonce

    private static func randomNonceString(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remaining = length
        while remaining > 0 {
            var randoms = [UInt8](repeating: 0, count: 16)
            guard SecRandomCopyBytes(kSecRandomDefault, randoms.count, &randoms) == errSecSuccess else {
                fatalError("Kunne ikke generere nonce")
            }
            for random in randoms where remaining > 0 {
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remaining -= 1
                }
            }
        }
        return result
    }

    private static func sha256(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }
}
