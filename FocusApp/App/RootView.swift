import SwiftUI

// ⚛️ React : une vue SwiftUI est une `struct` conforme au protocole `View`, comme un composant fonction.
// Différence : ce n'est pas une fonction mais un petit type valeur, recréé à chaque rendu (très léger).
struct RootView: View {
    // ⚛️ voir CONCEPTS.md#state : ici `@State` détient l'onglet sélectionné. C'est la source de vérité ;
    // `CustomTabBar` la reçoit en `@Binding` (voir CustomTabBar.swift).
    @State private var selectedTab: AppTab = .home

    // ⚛️ React : `body` ≈ le `return (...)` du composant. SwiftUI le rappelle quand l'état change.
    // `some View` = « un type de vue précis, que le compilateur déduit » (≈ `JSX.Element`, mais vérifié statiquement).
    var body: some View {
        ZStack {
            // HomeView reste montée même quand on change d'onglet : on la masque au lieu de la retirer, sinon son
            // `@State` (le ViewModel et les tâches cochées) serait détruit puis rechargé à chaque retour (D-026).
            // ⚛️ React : ≈ `display: 'none'` plutôt que `{tab === 'home' && <Home />}` (qui démonte le composant).
            HomeView()
                .opacity(selectedTab == .home ? 1 : 0)
                .allowsHitTesting(selectedTab == .home)
                .accessibilityHidden(selectedTab != .home)

            if selectedTab != .home {
                PlaceholderScreen(tab: selectedTab)
            }
        }
        // ⚛️ React : `safeAreaInset(edge: .bottom)` réserve de la place en bas ET la déclare au contenu : le
        // `ScrollView` de HomeView ajoute tout seul une marge, donc la dernière tâche n'est pas cachée par la barre.
        // ≈ `contentContainerStyle={{ paddingBottom }}` + une vue en `position: 'absolute'`, mais sans calculer la hauteur.
        .safeAreaInset(edge: .bottom) {
            CustomTabBar(selection: $selectedTab, onAdd: {})    // onAdd mock : la feuille d'ajout est un bonus
                .padding(.horizontal, Spacing.screen)
                .padding(.top, Size.fabRaise)                   // place pour le bouton + qui dépasse
        }
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
