import Foundation

// La personne connectée. Pas de mot de passe ici : l'authentification est FICTIVE (D-032), rien n'est envoyé nulle part.
struct AuthSession: Equatable {
    var firstName: String
    var email: String

    // Au login, on ne connaît que l'e-mail : « alex@example.com » donne « Alex », « marie.curie@x.fr » donne « Marie ».
    static func firstName(fromEmail email: String) -> String {
        let local = email.split(separator: "@").first.map(String.init) ?? email
        let word = local.split(whereSeparator: { ".-_+".contains($0) }).first.map(String.init) ?? local
        return word.prefix(1).uppercased() + word.dropFirst()
    }

    var user: User { User(firstName: firstName, avatarName: "Avatar", email: email) }
}

// ⚛️ React : une erreur typée ≈ une classe `AuthError extends Error` avec un `message`. `LocalizedError` fournit le texte
// affiché à l'utilisateur via `error.localizedDescription`.
enum AuthError: LocalizedError, Equatable {
    case invalidCredentials
    case emailAlreadyUsed
    case network

    var errorDescription: String? {
        switch self {
        case .invalidCredentials: "Incorrect email or password."
        case .emailAlreadyUsed: "An account with this email already exists."
        case .network: "Something went wrong. Please try again."
        }
    }
}

// ⚛️ voir CONCEPTS.md#protocol : l'app dépend du protocole ; ici une implémentation fictive, plus tard un vrai backend.
protocol AuthProviding {
    func logIn(email: String, password: String) async throws -> AuthSession
    func signUp(firstName: String, email: String, password: String) async throws -> AuthSession
}

// Validation d'un e-mail : volontairement simple (quelque chose, un @, quelque chose, un point, quelque chose).
enum EmailValidator {
    static func isValid(_ email: String) -> Bool {
        email.trimmingCharacters(in: .whitespaces)
            .range(of: #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#, options: .regularExpression) != nil
    }
}

// Brouillon du formulaire Log In : la logique de validation vit ici (testable), pas dans la vue (comme `NewTaskDraft`).
struct LoginDraft {
    var email = ""
    var password = ""

    var isEmailValid: Bool { EmailValidator.isValid(email) }
    var isValid: Bool { isEmailValid && !password.isEmpty }
}

// Brouillon du formulaire Sign Up.
struct SignUpDraft {
    static let minimumPasswordLength = 8

    var firstName = ""
    var email = ""
    var password = ""
    var acceptsTerms = true         // coché par défaut, comme dans le canvas

    var isFirstNameValid: Bool { !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    var isEmailValid: Bool { EmailValidator.isValid(email) }
    var isPasswordLongEnough: Bool { password.count >= Self.minimumPasswordLength }
    var isValid: Bool { isFirstNameValid && isEmailValid && isPasswordLongEnough && acceptsTerms }
}
