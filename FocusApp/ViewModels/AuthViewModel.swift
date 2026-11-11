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
    private let avatarStore: AvatarStore

    private enum Key {
        static let firstName = "session.firstName"
        static let email = "session.email"
        static let hasSeenOnboarding = "session.hasSeenOnboarding"
        static let avatarFile = "session.avatarFile"
    }

    init(
        provider: AuthProviding = MockAuthProvider(),
        defaults: UserDefaults = .standard,
        avatarStore: AvatarStore = AvatarStore()
    ) {
        self.provider = provider
        self.defaults = defaults
        self.avatarStore = avatarStore
        hasSeenOnboarding = defaults.bool(forKey: Key.hasSeenOnboarding)
        if let firstName = defaults.string(forKey: Key.firstName), let email = defaults.string(forKey: Key.email) {
            session = AuthSession(firstName: firstName, email: email, avatarFileName: defaults.string(forKey: Key.avatarFile))
        }
    }

    // L'utilisateur tel que l'app l'affiche : la session, plus l'adresse locale de sa photo s'il en a choisi une.
    var currentUser: User? {
        guard let session else { return nil }
        return User(
            firstName: session.firstName,
            avatarName: "Avatar",
            email: session.email,
            avatarURL: session.avatarFileName.map(avatarStore.url(for:))
        )
    }

    // MARK: - Actions

    // Renvoient `true` si la connexion a réussi : la vue n'a rien d'autre à faire (l'état `session` change tout seul).
    func logIn(email: String, password: String) async -> Bool {
        await authenticate { try await self.provider.logIn(email: email, password: password) }
    }

    func signUp(firstName: String, email: String, password: String) async -> Bool {
        await authenticate { try await self.provider.signUp(firstName: firstName, email: email, password: password) }
    }

    // Enregistre le profil modifié : prénom, e-mail et photo. La session est mise à jour ET persistée ; l'ancienne photo
    // est supprimée du disque quand elle est remplacée ou retirée.
    func updateProfile(_ draft: ProfileDraft) {
        guard var updated = session, draft.isValid else { return }
        updated.firstName = draft.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.email = draft.email.trimmingCharacters(in: .whitespaces).lowercased()

        switch draft.avatar {
        case .keep:
            break
        case .remove:
            avatarStore.remove(updated.avatarFileName)
            updated.avatarFileName = nil
        case .replace(let data):
            // Si l'image est illisible, on garde la photo actuelle plutôt que de perdre l'avatar.
            if let newName = try? avatarStore.save(data) {
                avatarStore.remove(updated.avatarFileName)
                updated.avatarFileName = newName
            }
        }
        session = updated
        persist(updated)
    }

    func logOut() {
        avatarStore.remove(session?.avatarFileName)
        session = nil
        status = .idle
        defaults.removeObject(forKey: Key.firstName)
        defaults.removeObject(forKey: Key.email)
        defaults.removeObject(forKey: Key.avatarFile)
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
            persist(newSession)
            defaults.set(true, forKey: Key.hasSeenOnboarding)
            status = .idle
            return true
        } catch {
            status = .failed(error.localizedDescription)
            return false
        }
    }

    private func persist(_ session: AuthSession) {
        defaults.set(session.firstName, forKey: Key.firstName)
        defaults.set(session.email, forKey: Key.email)
        if let avatarFileName = session.avatarFileName {
            defaults.set(avatarFileName, forKey: Key.avatarFile)
        } else {
            defaults.removeObject(forKey: Key.avatarFile)
        }
    }
}
