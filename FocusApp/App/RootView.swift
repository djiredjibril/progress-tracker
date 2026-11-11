import SwiftUI

// ⚛️ React : une vue SwiftUI est une `struct` conforme au protocole `View`, comme un composant fonction.
// Différence : ce n'est pas une fonction mais un petit type valeur, recréé à chaque rendu (très léger).
struct RootView: View {
    // ⚛️ voir CONCEPTS.md#state : ici `@State` détient l'onglet sélectionné. C'est la source de vérité ;
    // `CustomTabBar` la reçoit en `@Binding` (voir CustomTabBar.swift).
    @State private var selectedTab: AppTab = .home

    // ⚛️ voir CONCEPTS.md#state : le ViewModel est créé et possédé ICI, à la racine, pour être partagé entre Home et
    // la feuille « New Task » (et, plus tard, Calendar et Analytics). ≈ un store global / un contexte React placé
    // tout en haut de l'arbre (D-033).
    @State private var viewModel: HomeViewModel
    @State private var isAddingTask = false

    // ⚛️ voir CONCEPTS.md#state : on reçoit un *provider* pour que les `#Preview` injectent un service instantané ;
    // `_viewModel = State(initialValue:)` initialise le `@State` depuis un paramètre.
    init(provider: HomeDataProviding = MockHomeDataProvider()) {
        _viewModel = State(initialValue: HomeViewModel(provider: provider))
    }

    // ⚛️ React : `body` ≈ le `return (...)` du composant. SwiftUI le rappelle quand l'état change.
    // `some View` = « un type de vue précis, que le compilateur déduit » (≈ `JSX.Element`, mais vérifié statiquement).
    var body: some View {
        ZStack {
            // HomeView reste montée même quand on change d'onglet : on la masque au lieu de la retirer, sinon son
            // `@State` (le ViewModel et les tâches cochées) serait détruit puis rechargé à chaque retour (D-026).
            // ⚛️ React : ≈ `display: 'none'` plutôt que `{tab === 'home' && <Home />}` (qui démonte le composant).
            HomeView(viewModel: viewModel)
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
            CustomTabBar(selection: $selectedTab, onAdd: { isAddingTask = true })
                .padding(.horizontal, Spacing.screen)
                .padding(.top, Size.fabRaise)                   // place pour le bouton + qui dépasse
        }
        // ⚛️ React : `.sheet(isPresented:)` ≈ `<Modal visible={isAddingTask}>` : la feuille s'affiche quand le booléen
        // passe à vrai, et SwiftUI le remet à faux tout seul quand on la ferme (`$` = binding en lecture ET écriture).
        .sheet(isPresented: $isAddingTask) {
            NewTaskView { task in
                // `withAnimation` : la nouvelle ligne apparaît avec une transition (voir CONCEPTS.md#with-animation).
                withAnimation(.snappy) { viewModel.addTask(task) }
            }
        }
        // ⚛️ React : ≈ `userInterfaceStyle: 'light'` d'Expo : on ignore le mode sombre du téléphone (D-014).
        // Posé à la racine, il s'applique à toute l'app.
        .preferredColorScheme(.light)
    }
}

// ⚛️ React : `#Preview` ≈ une story Storybook : Xcode affiche ce composant à part, sans lancer l'app.
// Il est retiré du build de production.
#Preview {
    RootView(provider: MockHomeDataProvider(delay: .zero))
}
