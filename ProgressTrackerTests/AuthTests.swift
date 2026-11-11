import Foundation
import Testing
@testable import ProgressTracker

struct AuthValidationTests {
    @Test(arguments: [
        ("alex@example.com", true),
        ("  alex@example.com  ", true),
        ("marie.curie@lab.fr", true),
        ("alex", false),
        ("alex@", false),
        ("alex@example", false),
        ("@example.com", false),
        ("a b@example.com", false),
        ("", false)
    ])
    func emailValidation(email: String, expected: Bool) {
        #expect(EmailValidator.isValid(email) == expected)
    }

    @Test func loginNeedsAValidEmailAndAPassword() {
        var draft = LoginDraft()
        #expect(!draft.isValid)

        draft.email = "alex@example.com"
        #expect(!draft.isValid)                     // pas de mot de passe

        draft.password = "x"
        #expect(draft.isValid)

        draft.email = "alex"
        #expect(!draft.isValid)
    }

    @Test func signUpNeedsEveryRule() {
        var draft = SignUpDraft(firstName: "Alex", email: "alex@example.com", password: "12345678", acceptsTerms: true)
        #expect(draft.isValid)

        draft.password = "1234567"                  // 7 caractères : trop court
        #expect(!draft.isPasswordLongEnough)
        #expect(!draft.isValid)

        draft.password = "12345678"
        draft.acceptsTerms = false
        #expect(!draft.isValid)

        draft.acceptsTerms = true
        draft.firstName = "   "
        #expect(!draft.isValid)
    }

    @Test func termsAreAcceptedByDefaultLikeTheCanvas() {
        #expect(SignUpDraft().acceptsTerms)
    }

    @Test(arguments: [
        ("alex@example.com", "Alex"),
        ("marie.curie@lab.fr", "Marie"),
        ("jean-paul@x.com", "Jean"),
        ("SAM@x.com", "SAM")
    ])
    func firstNameIsDerivedFromTheEmail(email: String, expected: String) {
        #expect(AuthSession.firstName(fromEmail: email) == expected)
    }
}

@MainActor
struct AuthViewModelTests {
    // Une suite de `UserDefaults` jetable par test : rien n'est écrit dans les vrais réglages de l'app.
    private func makeDefaults() -> UserDefaults {
        let name = "auth-tests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    private func makeViewModel(defaults: UserDefaults, failure: AuthError? = nil) -> AuthViewModel {
        AuthViewModel(provider: MockAuthProvider(delay: .zero, failure: failure), defaults: defaults)
    }

    @Test func startsLoggedOutWithoutOnboardingSeen() {
        let viewModel = makeViewModel(defaults: makeDefaults())
        #expect(!viewModel.isLoggedIn)
        #expect(!viewModel.hasSeenOnboarding)
        #expect(viewModel.status == .idle)
    }

    @Test func logInSucceedsAndPersistsTheSession() async {
        let defaults = makeDefaults()
        let viewModel = makeViewModel(defaults: defaults)

        let succeeded = await viewModel.logIn(email: "Alex@Example.com ", password: "secret")

        #expect(succeeded)
        #expect(viewModel.session == AuthSession(firstName: "Alex", email: "alex@example.com"))
        #expect(viewModel.hasSeenOnboarding)
        #expect(viewModel.status == .idle)

        // Un nouveau ViewModel sur les mêmes réglages retrouve la session (≈ relancer l'app).
        let relaunched = makeViewModel(defaults: defaults)
        #expect(relaunched.isLoggedIn)
        #expect(relaunched.session?.email == "alex@example.com")
        #expect(relaunched.hasSeenOnboarding)
    }

    @Test func signUpUsesTheGivenFirstName() async {
        let viewModel = makeViewModel(defaults: makeDefaults())
        let succeeded = await viewModel.signUp(firstName: "  Sam ", email: "sam@example.com", password: "12345678")

        #expect(succeeded)
        #expect(viewModel.session?.firstName == "Sam")
        #expect(viewModel.session?.user.email == "sam@example.com")
    }

    @Test func failedLogInKeepsTheUserLoggedOutAndShowsTheMessage() async {
        let viewModel = makeViewModel(defaults: makeDefaults(), failure: .invalidCredentials)
        let succeeded = await viewModel.logIn(email: "alex@example.com", password: "nope")

        #expect(!succeeded)
        #expect(!viewModel.isLoggedIn)
        #expect(viewModel.errorMessage == "Incorrect email or password.")
        #expect(!viewModel.hasSeenOnboarding)

        viewModel.clearError()
        #expect(viewModel.errorMessage == nil)
    }

    @Test func logOutClearsTheSessionButKeepsOnboardingSeen() async {
        let defaults = makeDefaults()
        let viewModel = makeViewModel(defaults: defaults)
        _ = await viewModel.logIn(email: "alex@example.com", password: "secret")

        viewModel.logOut()

        #expect(!viewModel.isLoggedIn)
        #expect(viewModel.hasSeenOnboarding)
        #expect(!makeViewModel(defaults: defaults).isLoggedIn)      // et c'est persisté
    }

    @Test func homeProviderUsesTheLoggedInUser() async throws {
        let session = AuthSession(firstName: "Sam", email: "sam@example.com")
        let data = try await MockHomeDataProvider(delay: .zero, user: session.user).fetchHomeData()
        #expect(data.user.firstName == "Sam")
        #expect(data.user.email == "sam@example.com")

        let fallback = try await MockHomeDataProvider(delay: .zero).fetchHomeData()
        #expect(fallback.user.firstName == "Alex")
    }
}
