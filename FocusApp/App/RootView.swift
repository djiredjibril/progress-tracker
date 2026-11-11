import SwiftUI

// ⚛️ React : une vue SwiftUI est une `struct` conforme au protocole `View`, comme un composant fonction.
// Différence : ce n'est pas une fonction mais un petit type valeur, recréé à chaque rendu (très léger).
struct RootView: View {
    // ⚛️ React : `body` ≈ le `return (...)` du composant. SwiftUI le rappelle quand l'état change.
    // `some View` = « un type de vue précis, que le compilateur déduit » (≈ `JSX.Element`, mais vérifié statiquement).
    var body: some View {
        // ⚛️ React : `Text` ≈ `<Text>` de React Native. Pas de JSX : on appelle des initialiseurs,
        // et on enchaîne des *modifiers* (`.font`, `.padding`…) à la place des props de style.
        Text("FocusApp")
    }
}

// ⚛️ React : `#Preview` ≈ une story Storybook : Xcode affiche ce composant à part, sans lancer l'app.
// Il est retiré du build de production.
#Preview {
    RootView()
}
