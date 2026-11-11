import SwiftUI

// ⚛️ React : un `ButtonStyle` est le « style » d'un bouton, séparé de son contenu et de son action : on écrit
// `Button("Create") { … }.buttonStyle(.primary)` au lieu de recréer un composant `<PrimaryButton>`.
// Avantage : le bouton reste un vrai `Button` (accessibilité, focus, état désactivé) et on peut changer son look
// partout en un seul endroit. `configuration.label` est le contenu, `configuration.isPressed` l'état d'appui.
struct PrimaryButtonStyle: ButtonStyle {
    // ⚛️ React : ≈ un `useContext` : `isEnabled` reflète le `.disabled(…)` posé sur le bouton, sans le passer en prop.
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.appButton)
            .foregroundStyle(Color.textOnAccent)
            .frame(maxWidth: .infinity)
            .frame(height: Size.primaryButton)
            .background(
                RoundedRectangle(cornerRadius: Radius.button, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.buttonGradientStart, Color.buttonGradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.buttonShadow, radius: Shadow.fabRadius, y: Shadow.fabY)
            )
            // Désactivé : bouton pâle et sans ombre nette. Appuyé : très léger retrait.
            .opacity(isEnabled ? 1 : 0.45)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.snappy(duration: 0.15), value: configuration.isPressed)
    }
}

// ⚛️ React : cette extension permet d'écrire `.buttonStyle(.primary)` (notation point) au lieu de
// `.buttonStyle(PrimaryButtonStyle())`. Même principe que `Color.appPrimary` : une propriété statique.
extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

#Preview {
    VStack(spacing: Spacing.m) {
        Button("Create Task") {}
            .buttonStyle(.primary)
        Button("Create Task") {}
            .buttonStyle(.primary)
            .disabled(true)
    }
    .padding(Spacing.screen)
    .background { AppBackground() }
}
