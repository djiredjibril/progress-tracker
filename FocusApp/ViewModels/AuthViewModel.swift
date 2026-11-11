import Foundation
import Observation

// État d'authentification de l'app : qui est connecté, si l'onboarding a été vu, et l'état du formulaire en cours.
// La session est persistée dans `UserDefaults` (injecté : les tests utilisent une suite jetable).
@Observable
@MainActor
final class AuthViewModel {
    // ⚛️ React : l'état d'une soumission de formulaire ≈ `{ status: 'idle' | 'submitting' | 'error', message }`, en union typée.
    enum Status: Equatable {
        case idle
        case submitting
        case failed(String)
    }

    private(set) var session: AuthSession?
    private(set) var hasSeenOnboarding: Bool
    private(set) var status: Status = .idle

    var isLoggedIn: Bool { session != nil }
    var isSubmitting: Bool { status == .submitting }
    var errorMessage: String? {
        if case .failed(let message) = status { message } else { nil }
    }

    private let provider: AuthProviding
    private let defaults: UserDefaults

    private enum Key {
        static let firstName = "session.firstName"
        static let email = "session.email"
        static let hasSeenOnboarding = "session.hasSeenOnboarding"
    }

    init(provider: AuthProviding = MockAuthProvider(), defaults: UserDefaults = .standard) {
        self.provider = provider
        self.defaults = defaults
        hasSeenOnboarding = defaults.bool(forKey: Key.hasSeenOnboarding)
        if let firstName = defaults.string(forKey: Key.firstName), let email = defaults.string(forKey: Key.email) {
            session = AuthSession(firstName: firstName, email: email)
        }
    }

    // MARK: - Actions

    // Renvoient `true` si la connexion a réussi : la vue n'a rien d'autre à faire (l'état `session` change tout seul).
    func logIn(email: String, password: String) async -> Bool {
        await authenticate { try await self.provider.logIn(email: email, password: password) }
    }

    func signUp(firstName: String, email: String, password: String) async -> Bool {
        await authenticate { try await self.provider.signUp(firstName: firstName, email: email, password: password) }
    }

    func logOut() {
        session = nil
        status = .idle
        defaults.removeObject(forKey: Key.firstName)
        defaults.removeObject(forKey: Key.email)
        // `hasSeenOnboarding` reste vrai : après une déconnexion on retombe sur Log In, pas sur l'onboarding.
    }

    // Efface le message d'erreur quand l'utilisateur recommence à taper.
    func clearError() {
        if case .failed = status { status = .idle }
    }

    // MARK: - Interne

    private func authenticate(_ action: () async throws -> AuthSession) async -> Bool {
        status = .submitting
        do {
            let newSession = try await action()
            session = newSession
            hasSeenOnboarding = true
            defaults.set(newSession.firstName, forKey: Key.firstName)
            defaults.set(newSession.email, forKey: Key.email)
            defaults.set(true, forKey: Key.hasSeenOnboarding)
            status = .idle
            return true
        } catch {
            status = .failed(error.localizedDescription)
            return false
        }
    }
}
