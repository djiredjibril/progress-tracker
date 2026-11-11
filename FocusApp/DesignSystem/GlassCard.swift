import SwiftUI

// ⚛️ React : un `ViewModifier` est une fonction « vue → vue » réutilisable, ≈ un HOC (`withGlass(Component)`)
// ou un composant wrapper `<GlassCard>{children}</GlassCard>`. Différence : il s'écrit sous forme de modifier
// (`.glassCard()`), donc il s'enchaîne comme `.padding()` au lieu d'imbriquer des composants.
struct GlassCard: ViewModifier {
    let cornerRadius: CGFloat

    // ⚛️ React : `content` est la vue à envelopper (≈ `children`). `Content` est un type fourni par SwiftUI.
    func body(content: Content) -> some View {
        content.background {
            // ⚛️ React : `style: .continuous` donne les coins « squircle » d'iOS (≈ `borderCurve: 'continuous'` en RN).
            let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            shape
                // ⚛️ React : `.ultraThinMaterial` ≈ `<BlurView intensity>` d'expo-blur : un flou de ce qui est
                // DERRIÈRE la carte, géré par l'OS (s'adapte tout seul au clair/sombre).
                .fill(.ultraThinMaterial)
                // Voile blanc semi-transparent par-dessus le flou, puis liseré blanc de 1 pt (D-015).
                .overlay(shape.fill(Color.glassFill))
                .overlay(shape.strokeBorder(Color.glassStroke, lineWidth: 1))
                // ⚛️ React : ≈ `shadowColor/shadowRadius/shadowOffset` (iOS), mais valable partout et en un seul appel.
                .shadow(color: Color.cardShadow, radius: Shadow.cardRadius, y: Shadow.cardY)
        }
    }
}

// ⚛️ React : une extension de `View` ajoute `.glassCard()` à TOUTES les vues (voir CONCEPTS.md#extension).
// C'est ce qui permet d'écrire `.glassCard()` plutôt que `.modifier(GlassCard(...))`.
extension View {
    func glassCard(cornerRadius: CGFloat = Radius.card) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius))
    }
}
