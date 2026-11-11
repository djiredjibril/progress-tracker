import SwiftUI

// Composant présentationnel (D-006) : il reçoit des valeurs et une closure, il ignore le ViewModel.
struct CircleIconButton: View {
    // ⚛️ React : ces propriétés sont les *props* du composant. L'`init` est généré automatiquement,
    // dans l'ordre de déclaration ; une valeur par défaut (`= false`) rend l'argument facultatif.
    let systemName: String
    let accessibilityLabel: String
    var showsBadge: Bool = false
    // ⚛️ React : `() -> Void` est le type d'une closure sans argument ni retour ≈ `onPress: () => void`.
    let action: () -> Void

    var body: some View {
        // ⚛️ React : `Button` ≈ `<Pressable onPress={action}>`. Le contenu est le *label*, ici une icône.
        Button(action: action) {
            // ⚛️ React : `Image(systemName:)` affiche un SF Symbol (icône vectorielle d'Apple), ≈ `@expo/vector-icons`
            // mais intégré à l'OS : il suit la police et la couleur du texte.
            Image(systemName: systemName)
                .font(.appIconButton)
                .foregroundStyle(Color.textPrimary)
                // ⚛️ React : `frame(width:height:)` ≈ `style={{ width, height }}`.
                .frame(width: Size.circleButton, height: Size.circleButton)
                // ⚛️ React : `background` dessine DERRIÈRE la vue, `overlay` PAR-DESSUS. Les deux se calent sur la
                // taille de la vue (ici 44×44), contrairement à un `<View>` absolu qu'on dimensionne soi-même.
                .background(Circle().fill(Color.glassFill))
                .overlay(Circle().strokeBorder(Color.glassStroke, lineWidth: 1))
                // ⚛️ React : `overlay(alignment:)` ≈ un enfant `position: 'absolute', top: 0, right: 0`.
                .overlay(alignment: .topTrailing) {
                    if showsBadge {
                        Circle()
                            .fill(Color.appPrimary)
                            .frame(width: Size.badge, height: Size.badge)
                            .padding(Spacing.xs)
                    }
                }
        }
        // ⚛️ React : sans `.plain`, SwiftUI applique le style de bouton par défaut (teinte d'accent, flash au toucher).
        .buttonStyle(.plain)
        // ⚛️ React : ≈ `accessibilityLabel` de RN. Obligatoire sur un bouton qui n'a qu'une icône,
        // sinon VoiceOver ne sait pas quoi annoncer.
        .accessibilityLabel(accessibilityLabel)
    }
}

#Preview {
    ZStack {
        AppBackground()
        HStack(spacing: Spacing.s) {
            CircleIconButton(systemName: "magnifyingglass", accessibilityLabel: "Search") {}
            CircleIconButton(systemName: "bell", accessibilityLabel: "Notifications", showsBadge: true) {}
        }
    }
}
