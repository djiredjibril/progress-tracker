import SwiftUI

// Écran de démarrage animé (≈ 2,5 s) : l'anneau se dessine, la coche apparaît, puis le nom et le slogan montent en fondu.
// Avec « Réduire les animations », tout s'affiche d'un coup (accessibilité).
struct SplashView: View {
    let onFinished: () -> Void

    // ⚛️ React : ≈ `AccessibilityInfo.isReduceMotionEnabled` (RN) : une valeur de l'environnement, lue sans prop.
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // ⚛️ React : chaque étape de l'animation est un `useState` (≈ une `Animated.Value`). Changer ces valeurs DANS un
    // `withAnimation(...delay)` les fait interpoler tout seul ; on enchaîne les étapes avec des délais.
    @State private var arc = 0.0
    @State private var checkScale: CGFloat = 0.5
    @State private var checkOpacity = 0.0
    @State private var nameVisible = false
    @State private var taglineVisible = false
    @State private var haloOpacity = 0.35

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.brandStart, Color.brandMid, Color.brandEnd],
                startPoint: UnitPoint(x: 0.3, y: 0),
                endPoint: UnitPoint(x: 0.7, y: 1)
            )
            halos

            VStack(spacing: Spacing.section + Spacing.xs) {
                AppLogoView(size: Size.splashLogo, arcProgress: arc, checkScale: checkScale, checkOpacity: checkOpacity)
                VStack(spacing: Spacing.s) {
                    Text("FocusApp")
                        .font(.appSplashTitle)
                        .tracking(-0.5)
                        .opacity(nameVisible ? 1 : 0)
                        .offset(y: nameVisible ? 0 : Spacing.m)
                    Text("Plan. Focus. Achieve.")
                        .font(.appFieldText.weight(.medium))
                        .opacity(taglineVisible ? 1 : 0)
                        .offset(y: taglineVisible ? 0 : Spacing.m)
                }
                .foregroundStyle(Color.textOnAccent)
            }
        }
        .ignoresSafeArea()
        // Un toucher passe directement à la suite.
        .contentShape(Rectangle())
        .onTapGesture { onFinished() }
        // ⚛️ voir CONCEPTS.md#task-id : la séquence tourne dans un `.task` (annulé si la vue disparaît avant la fin).
        .task { await play() }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("FocusApp. Plan. Focus. Achieve.")
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Double-tap to continue")
    }

    private var halos: some View {
        ZStack {
            Circle()
                .fill(Color.splashHalo)
                .frame(width: 320, height: 320)
                .blur(radius: 90)
                .opacity(haloOpacity)
                .offset(y: -110)
            Circle()
                .fill(Color.splashShade)
                .frame(width: 300, height: 300)
                .blur(radius: 90)
                .offset(x: 140, y: 380)
        }
        .accessibilityHidden(true)
    }

    private func play() async {
        if reduceMotion {
            arc = 0.75; checkScale = 1; checkOpacity = 1; nameVisible = true; taglineVisible = true
            try? await Task.sleep(for: .seconds(1))
        } else {
            // ⚛️ React : `timingCurve` ≈ `Easing.bezier(...)` de RN, et `spring` ≈ `Animated.spring` : le « pop » de la coche
            // dépasse un peu sa taille finale avant de se stabiliser.
            withAnimation(.timingCurve(0.65, 0, 0.35, 1, duration: 1.1).delay(0.2)) { arc = 0.75 }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.55).delay(1.15)) {
                checkScale = 1
                checkOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.5).delay(1.5)) { nameVisible = true }
            withAnimation(.easeOut(duration: 0.5).delay(1.7)) { taglineVisible = true }
            // ⚛️ React : ≈ une `Animated.loop` : le halo « respire » en boucle.
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) { haloOpacity = 0.6 }
            try? await Task.sleep(for: .seconds(2.6))
        }
        onFinished()
    }
}

#Preview {
    SplashView(onFinished: {})
}
