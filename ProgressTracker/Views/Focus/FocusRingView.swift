import SwiftUI

// Anneau de progression du minuteur : une piste, un arc en dégradé et le contenu au centre.
// Composant présentationnel : il reçoit la progression (0...1) et un contenu, il ignore le ViewModel.
struct FocusRingView<Center: View>: View {
    let progress: Double
    // ⚛️ React : `@ViewBuilder` + un générique `Center` ≈ la prop `children` : l'appelant place ce qu'il veut au centre.
    @ViewBuilder let center: () -> Center

    var body: some View {
        ZStack {
            // Disque translucide + piste claire (même tracé : le disque se remplit, le trait dessine la piste).
            Circle()
                .fill(Color.glassFill)
                .overlay(Circle().stroke(Color.ringTrack, lineWidth: Size.ringStroke))
            // ⚛️ React : `trim(from:to:)` ≈ `strokeDasharray` / `strokeDashoffset` d'un `<Circle>` SVG : on ne dessine
            // qu'une fraction du cercle. Le cercle démarre à 3 h, d'où la rotation de -90° pour partir de midi.
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [Color.ringGradientStart, Color.appPrimaryStrong],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: Size.ringStroke, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            center()
        }
        // Le tracé fait 224 pt dans un cadre de 264 : 20 pt de marge, dont la moitié du trait.
        .padding(Spacing.card)
        .frame(width: Size.focusRing, height: Size.focusRing)
        // ⚛️ React : `trim` est ANIMABLE : à chaque seconde l'arc avance de façon fluide (linéaire, d'une seconde),
        // sans `Animated.Value`. L'animation est liée à `progress` : rien d'autre ne s'anime.
        .animation(.linear(duration: 1), value: progress)
    }
}

#Preview {
    ZStack {
        AppBackground()
        FocusRingView(progress: 0.4) {
            Text("15:00").font(.appTimer)
        }
    }
}
