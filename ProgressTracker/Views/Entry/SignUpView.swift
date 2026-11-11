import SwiftUI

struct SignUpView: View {
    let auth: AuthViewModel
    let onBack: () -> Void
    let onShowLogIn: () -> Void

    @State private var draft = SignUpDraft()
    // ⚛️ React : une `enum` pour le focus ≈ une valeur `focusedField: 'name' | 'email' | 'password' | null`. Un seul
    // `@FocusState` suffit pour tout le formulaire, et on passe au champ suivant en changeant sa valeur.
    private enum Field { case name, email, password }
    @FocusState private var focused: Field?
    // `PasswordInput` attend un focus booléen : on le dérive du focus du formulaire.
    @FocusState private var passwordFocused: Bool

    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.section) {
                    CircleIconButton(systemName: "chevron.left", accessibilityLabel: "Back", action: onBack)
                    header
                    form
                    Toggle("I agree to the Terms of Service and Privacy Policy.", isOn: $draft.acceptsTerms)
                        .toggleStyle(.checkbox)
                    submitButton
                }
                .padding(.horizontal, Spacing.section)
                .padding(.top, Spacing.s)
                .padding(.bottom, Spacing.section)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollIndicators(.hidden)
        }
        .safeAreaInset(edge: .bottom) {
            AuthSwitchRow(prompt: "Already have an account?", action: "Log in", onTap: onShowLogIn)
                .padding(.bottom, Spacing.s)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text("Create your account")
                .font(.appLargeTitle)
                .tracking(-0.5)
                .foregroundStyle(Color.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text("It takes less than a minute.")
                .font(.appFieldText)
                .foregroundStyle(Color.textSecondary)
        }
    }

    private var form: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            AuthField(label: "First name") {
                TextField("", text: $draft.firstName, prompt: Text("Alex").foregroundStyle(Color.textPlaceholder))
                    .font(.appFieldText)
                    .foregroundStyle(Color.textPrimary)
                    .textContentType(.givenName)
                    .textInputAutocapitalization(.words)
                    .focused($focused, equals: .name)
                    .submitLabel(.next)
                    .onSubmit { focused = .email }
                    .formField(isFocused: focused == .name)
            }
            AuthField(
                label: "Email",
                errorMessage: (!draft.email.isEmpty && !draft.isEmailValid && focused != .email)
                    ? "Enter a valid email address." : nil
            ) {
                TextField("", text: $draft.email, // `Text(verbatim:)` : sans lui, SwiftUI détecte l'adresse e-mail dans le texte et la colore comme un lien.
                    prompt: Text(verbatim: "you@example.com").foregroundStyle(Color.textPlaceholder))
                    .font(.appFieldText)
                    .foregroundStyle(Color.textPrimary)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focused, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { passwordFocused = true }
                    .formField(isFocused: focused == .email)
            }
            AuthField(
                label: "Password",
                // Le rappel devient une erreur seulement quand on a commencé à taper un mot de passe trop court.
                hint: "At least \(SignUpDraft.minimumPasswordLength) characters.",
                errorMessage: (!draft.password.isEmpty && !draft.isPasswordLongEnough && !passwordFocused)
                    ? "Use at least \(SignUpDraft.minimumPasswordLength) characters." : nil
            ) {
                PasswordInput(
                    prompt: "Create a password",
                    text: $draft.password,
                    contentType: .newPassword,
                    isFocused: $passwordFocused,
                    submitLabel: .done,
                    onSubmit: { passwordFocused = false }
                )
            }
            if let message = auth.errorMessage {
                Text(message)
                    .font(.appCaption)
                    .foregroundStyle(Color.destructive)
                    .accessibilityAddTraits(.updatesFrequently)
            }
        }
        .onChange(of: draft.email) { auth.clearError() }
    }

    private var submitButton: some View {
        Button(action: submit) {
            SubmitButtonLabel(title: "Create Account", isSubmitting: auth.isSubmitting)
        }
        .buttonStyle(.primary)
        .disabled(!draft.isValid || auth.isSubmitting)
    }

    private func submit() {
        guard draft.isValid, !auth.isSubmitting else { return }
        focused = nil
        passwordFocused = false
        Task { _ = await auth.signUp(firstName: draft.firstName, email: draft.email, password: draft.password) }
    }
}

#Preview {
    SignUpView(
        auth: AuthViewModel(provider: MockAuthProvider(delay: .zero), defaults: UserDefaults(suiteName: "preview")!),
        onBack: {},
        onShowLogIn: {}
    )
}
