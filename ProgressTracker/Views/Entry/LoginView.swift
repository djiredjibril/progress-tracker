import SwiftUI

struct LoginView: View {
    // ViewModel d'authentification reçu en `let` (possédé par `AppFlowView`) : la vue lit ses propriétés `@Observable`.
    let auth: AuthViewModel
    let onShowSignUp: () -> Void

    @State private var draft = LoginDraft()
    @FocusState private var emailFocused: Bool
    @FocusState private var passwordFocused: Bool

    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.section + Spacing.xs) {
                    header
                    form
                    submitButton
                }
                .padding(.horizontal, Spacing.section)
                .padding(.top, Spacing.section * 2)
                .padding(.bottom, Spacing.section)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollIndicators(.hidden)
        }
        .safeAreaInset(edge: .bottom) {
            AuthSwitchRow(prompt: tr("Don't have an account?"), action: tr("Sign up"), onTap: onShowSignUp)
                .padding(.bottom, Spacing.s)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.card) {
            LogoTile()
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text("Welcome back")
                    .font(.appLargeTitle)
                    .tracking(-0.5)
                    .foregroundStyle(Color.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Text("Log in to pick up where you left off.")
                    .font(.appFieldText)
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }

    private var form: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            AuthField(
                label: tr("Email"),
                // L'erreur n'apparaît que quand on a fini de taper (le champ perd le focus) et que l'e-mail est invalide.
                errorMessage: (!draft.email.isEmpty && !draft.isEmailValid && !emailFocused) ? tr("Enter a valid email address.") : nil
            ) {
                // ⚛️ React : ≈ `<TextInput keyboardType="email-address" autoCapitalize="none" autoComplete="email" />`.
                TextField("", text: $draft.email, // `Text(verbatim:)` : sans lui, SwiftUI détecte l'adresse e-mail dans le texte et la colore comme un lien.
                    prompt: Text(verbatim: "you@example.com").foregroundStyle(Color.textPlaceholder))
                    .font(.appFieldText)
                    .foregroundStyle(Color.textPrimary)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($emailFocused)
                    .submitLabel(.next)
                    .onSubmit { passwordFocused = true }
                    .formField(isFocused: emailFocused)
            }
            AuthField(label: tr("Password")) {
                PasswordInput(
                    prompt: tr("Your password"),
                    text: $draft.password,
                    contentType: .password,
                    isFocused: $passwordFocused,
                    submitLabel: .go,
                    onSubmit: submit
                )
            }
            HStack {
                if let message = auth.errorMessage {
                    Text(message)
                        .font(.appCaption)
                        .foregroundStyle(Color.destructive)
                        .accessibilityAddTraits(.updatesFrequently)
                }
                Spacer()
                // Action mock : la récupération du mot de passe n'est pas dans le périmètre.
                Button {} label: {
                    Text("Forgot password?")
                        .font(.appLink.weight(.semibold))
                        .foregroundStyle(Color.appPrimaryStrong)
                        .frame(minHeight: Size.statIcon)
                }
                .buttonStyle(.plain)
            }
        }
        // Recommencer à taper efface l'erreur du serveur.
        .onChange(of: draft.email) { auth.clearError() }
        .onChange(of: draft.password) { auth.clearError() }
    }

    private var submitButton: some View {
        Button(action: submit) {
            SubmitButtonLabel(title: tr("Log In"), isSubmitting: auth.isSubmitting)
        }
        .buttonStyle(.primary)
        .disabled(!draft.isValid || auth.isSubmitting)
    }

    private func submit() {
        guard draft.isValid, !auth.isSubmitting else { return }
        emailFocused = false
        passwordFocused = false
        // ⚛️ voir CONCEPTS.md#viewbuilder : `Task { }` lance du code `async` depuis un handler synchrone. Si la connexion
        // réussit, `auth.session` change et `AppFlowView` affiche l'app : rien d'autre à faire ici.
        Task { _ = await auth.logIn(email: draft.email, password: draft.password) }
    }
}

#Preview {
    LoginView(auth: AuthViewModel(provider: MockAuthProvider(delay: .zero), defaults: UserDefaults(suiteName: "preview")!), onShowSignUp: {})
}
