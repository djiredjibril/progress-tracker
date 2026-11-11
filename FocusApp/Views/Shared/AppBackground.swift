import SwiftUI

// Fond d'écran : dégradé vertical + deux grandes taches floues pour l'ambiance lavande.
struct AppBackground: View {
    var body: some View {
        // ⚛️ React : `ZStack` empile ses enfants les uns SUR les autres (le premier est au fond).
        // ≈ des `<View>` en `position: 'absolute'` dans un conteneur, mais sans gérer top/left à la main.
        ZStack {
            // ⚛️ React : `LinearGradient` ≈ `<LinearGradient>` d'expo-linear-gradient (`colors`, `start`, `end`).
            // C'est une vue qui remplit tout l'espace disponible, pas un style de fond à part.
            LinearGradient(
                colors: [Color.backgroundTop, Color.backgroundBottom],
                startPoint: .top,
                endPoint: .bottom
            )

            // ⚛️ React : `frame(maxWidth: .infinity, maxHeight: .infinity, alignment:)` ≈ `flex: 1` + `alignSelf`.
            // Le cadre prend toute la place, et `alignment` colle la tache dans un coin.
            blob(Color.appPrimary.opacity(0.12))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            blob(Color.goalGradientEnd.opacity(0.12))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
        // ⚛️ React : par défaut SwiftUI respecte la safe area (≈ `SafeAreaView`). `ignoresSafeArea()` laisse le
        // fond passer derrière l'encoche et la barre d'accueil, comme un `StyleSheet.absoluteFill` plein écran.
        .ignoresSafeArea()
    }

    private func blob(_ color: Color) -> some View {
        Circle()
            .fill(color)
            .frame(width: Size.blob, height: Size.blob)
            // ⚛️ React : `blur` ≈ `<BlurView>` / `filter: blur()`. Les modifiers s'appliquent DANS L'ORDRE :
            // ici on dessine le cercle, on le dimensionne, puis on le floute (inverser changerait le résultat).
            .blur(radius: Size.blobBlur)
    }
}

#Preview {
    AppBackground()
}
