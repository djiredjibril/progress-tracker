import SwiftUI

// Pièces communes des écrans Log In et Sign Up.

// Un champ avec son libellé au-dessus et, si besoin, un message en dessous (aide ou erreur).
struct AuthField<Field: View>: View {
    let label: String
    var hint: String?
    var errorMessage: String?
    @ViewBuilder let field: () -> Field

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(label)
                .font(.appFieldLabel)
                .foregroundStyle(Color.textSecondary)
            field()
            if let errorMessage {
                Text(errorMessage)
                    .font(.appCaption)
                    .foregroundStyle(Color.destructive)
            } else if let hint {
                Text(hint)
                    .font(.appStatLabel)
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }
}

// Champ mot de passe avec un bouton « œil » pour afficher ou masquer la saisie.
struct PasswordInput: View {
    let prompt: String
    @Binding var text: String
    let contentType: UITextContentType
    // ⚛️ React : `FocusState<Bool>.Binding` est le « binding » de focus du PARENT : celui-ci décide quel champ a le focus
    // (ici pour passer de l'e-mail au mot de passe), et ce composant s'y branche avec `.focused(...)`.
    var isFocused: FocusState<Bool>.Binding
    let submitLabel: SubmitLabel
    let onSubmit: () -> Void

    @State private var isRevealed = false

    var body: some View {
        HStack(spacing: Spacing.s) {
            // ⚛️ React : `SecureField` ≈ `<TextInput secureTextEntry />` ; on bascule vers un `TextField` normal pour afficher.
            Group {
                if isRevealed {
                    TextField("", text: $text, prompt: promptText)
                } else {
                    SecureField("", text: $text, prompt: promptText)
                }
            }
            .font(.appFieldText)
            .foregroundStyle(Color.textPrimary)
            .textContentType(contentType)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused(isFocused)
            .submitLabel(submitLabel)
            .onSubmit(onSubmit)

            Button {
                isRevealed.toggle()
            } label: {
                Image(systemName: isRevealed ? "eye.slash" : "eye")
                    .font(.appIconButton)
                    .foregroundStyle(Color.textSecondary)
                    .frame(width: Size.circleButton, height: Size.circleButton)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isRevealed ? "Hide password" : "Show password")
        }
        .padding(.trailing, -Spacing.s)     // l'œil colle au bord : on compense le padding du champ
        .formField(isFocused: isFocused.wrappedValue)
    }

    private var promptText: Text {
        Text(prompt).foregroundStyle(Color.textPlaceholder)
    }
}

// Tuile du logo (dégradé de la marque) affichée en haut de Log In.
struct LogoTile: View {
    var body: some View {
        AppLogoView(size: Size.logoTile * 0.62)
            .frame(width: Size.logoTile, height: Size.logoTile)
            .background(
                RoundedRectangle(cornerRadius: Radius.logoTile, style: .continuous)
                    .fill(LinearGradient(
                        colors: [Color.brandStart, Color.brandMid, Color.brandEnd],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .shadow(color: Color.brandEnd.opacity(0.3), radius: Shadow.fabRadius, y: Shadow.fabY)
            )
    }
}

// « Don't have an account? Sign up » : une phrase et un lien.
struct AuthSwitchRow: View {
    let prompt: String
    let action: String
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Text(prompt)
                .font(.appFieldText.weight(.regular))
                .foregroundStyle(Color.textSecondary)
            Button(action: onTap) {
                Text(action)
                    .font(.appFieldText.weight(.bold))
                    .foregroundStyle(Color.appPrimaryStrong)
                    .padding(.horizontal, Spacing.xs)
                    .frame(minHeight: Size.circleButton)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }
}

// Libellé d'un bouton principal qui affiche un indicateur pendant l'envoi.
struct SubmitButtonLabel: View {
    let title: String
    let isSubmitting: Bool

    var body: some View {
        if isSubmitting {
            ProgressView().tint(Color.textOnAccent)
        } else {
            Text(title)
        }
    }
}
