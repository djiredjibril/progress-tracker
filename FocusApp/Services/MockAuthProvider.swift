// Authentification FICTIVE : elle simule un appel réseau, puis réussit pour n'importe quelle saisie valide.
// `failure` permet de simuler une erreur (utile aux tests et à la démo).
struct MockAuthProvider: AuthProviding {
    var delay: Duration = .milliseconds(700)
    var failure: AuthError?

    func logIn(email: String, password: String) async throws -> AuthSession {
        try await Task.sleep(for: delay)
        if let failure { throw failure }
        let cleaned = email.trimmingCharacters(in: .whitespaces).lowercased()
        return AuthSession(firstName: AuthSession.firstName(fromEmail: cleaned), email: cleaned)
    }

    func signUp(firstName: String, email: String, password: String) async throws -> AuthSession {
        try await Task.sleep(for: delay)
        if let failure { throw failure }
        return AuthSession(
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespaces).lowercased()
        )
    }
}
