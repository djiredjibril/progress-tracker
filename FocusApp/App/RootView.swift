import SwiftUI

// ⚛️ React : une vue SwiftUI est une `struct` conforme au protocole `View`, comme un composant fonction.
// Différence : ce n'est pas une fonction mais un petit type valeur, recréé à chaque rendu (très léger).
struct RootView: View {
    // ⚛️ React : `body` ≈ le `return (...)` du composant. SwiftUI le rappelle quand l'état change.
    // `some View` = « un type de vue précis, que le compilateur déduit » (≈ `JSX.Element`, mais vérifié statiquement).
    var body: some View {
        // Étape 1 : on affiche l'écran brut. Il deviendra le conteneur de la tab bar à l'étape 6.
        HomeView()
            // ⚛️ React : ≈ `userInterfaceStyle: 'light'` d'Expo : on ignore le mode sombre du téléphone (D-014).
            // Posé à la racine, il s'applique à toute l'app.
            .preferredColorScheme(.light)
    }
}

// ⚛️ React : `#Preview` ≈ une story Storybook : Xcode affiche ce composant à part, sans lancer l'app.
// Il est retiré du build de production.
#Preview {
    RootView()
}
