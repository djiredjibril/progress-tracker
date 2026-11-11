import SwiftUI

// Barre de progression : une piste claire et un remplissage dont la largeur suit `progress` (0...1).
struct ProgressBarView: View {
    let progress: Double
    var height: CGFloat = Size.progressBar

    // On borne la valeur : un `progress` de 1,4 ou de -0,2 ne doit jamais faire déborder la barre.
    private var clamped: Double { min(max(progress, 0), 1) }

    var body: some View {
        // ⚛️ React : `GeometryReader` ≈ `onLayout` de RN : il donne la taille réelle que le parent accorde à la vue
        // (`proxy.size`), ici pour convertir un pourcentage en points. Différence : la taille est disponible
        // dès le rendu, sans état ni second rendu. Attention : il s'étire pour remplir tout l'espace proposé,
        // d'où le `frame(height:)` plus bas.
        GeometryReader { proxy in
            // ⚛️ React : `ZStack(alignment: .leading)` superpose deux couches collées à gauche :
            // ≈ une barre `position: 'absolute'` posée sur sa piste.
            ZStack(alignment: .leading) {
                // ⚛️ React : `Capsule` ≈ un rectangle avec `borderRadius` maximal (une « pilule »).
                // Les coins s'adaptent seuls à la hauteur, pas besoin de calculer le rayon.
                Capsule()
                    .fill(Color.progressTrack)
                Capsule()
                    .fill(Color.textOnAccent)
                    .frame(width: proxy.size.width * clamped)
            }
        }
        .frame(height: height)
        // VoiceOver annonce « Progress, 70 percent » plutôt que de lire des formes sans sens.
        .accessibilityElement()
        .accessibilityLabel("Progress")
        .accessibilityValue("\(Int((clamped * 100).rounded())) percent")
    }
}

#Preview {
    VStack(spacing: Spacing.m) {
        ProgressBarView(progress: 0)
        ProgressBarView(progress: 0.7)
        ProgressBarView(progress: 1)
        ProgressBarView(progress: 1.4)     // borné à 100 %
    }
    .padding(Spacing.screen)
    .background(Color.goalGradientStart)
}
