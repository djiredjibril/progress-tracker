import Foundation

// Ce que l'utilisateur veut faire de sa photo de profil.
enum AvatarChange: Equatable {
    case keep
    case replace(Data)      // une nouvelle image choisie dans la photothèque
    case remove             // retour à l'avatar par défaut
}

// Brouillon du formulaire « Edit profile » : même principe que `NewTaskDraft` (état local + validation testable).
struct ProfileDraft: Equatable {
    var firstName: String
    var email: String
    var avatar: AvatarChange = .keep

    init(user: User) {
        firstName = user.firstName
        email = user.email
    }

    var isFirstNameValid: Bool { !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    var isEmailValid: Bool { EmailValidator.isValid(email) }
    var isValid: Bool { isFirstNameValid && isEmailValid }

    // Y a-t-il quelque chose à enregistrer ? Évite un bouton « Save » actif quand rien n'a changé.
    func hasChanges(from user: User) -> Bool {
        firstName.trimmingCharacters(in: .whitespacesAndNewlines) != user.firstName
            || email.trimmingCharacters(in: .whitespaces).lowercased() != user.email
            || avatar != .keep
    }
}
