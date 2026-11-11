import SwiftUI

// ⚛️ React : une vue SwiftUI est une `struct` conforme au protocole `View`, comme un composant fonction.
// Différence : ce n'est pas une fonction mais un petit type valeur, recréé à chaque rendu (très léger).
struct RootView: View {
    // ⚛️ voir CONCEPTS.md#state : ici `@State` détient l'onglet sélectionné. C'est la source de vérité ;
    // `CustomTabBar` la reçoit en `@Binding` (voir CustomTabBar.swift).
    @State private var selectedTab: AppTab = .home

    // ⚛️ React : le tableau des écrans EMPILÉS par-dessus les onglets (≈ l'état de navigation d'un stack navigator).
    // `append(.notifications)` ≈ `navigation.navigate('Notifications')`, `removeAll()` ≈ `popToTop()`. SwiftUI le met
    // à jour tout seul quand l'utilisateur revient en arrière (bouton ou balayage depuis le bord gauche).
    @State private var path: [AppRoute] = []

    // ⚛️ voir CONCEPTS.md#state : les ViewModels sont créés et possédés ICI, à la racine, pour être partagés entre
    // plusieurs écrans. ≈ un store global / un contexte React placé tout en haut de l'arbre (D-033, D-035).
    @State private var viewModel: HomeViewModel
    @State private var notificationsViewModel = NotificationsViewModel()
    @State private var calendarViewModel = CalendarViewModel()
    @State private var analyticsViewModel = AnalyticsViewModel()
    @State private var isAddingTask = false

    // ⚛️ voir CONCEPTS.md#state : on reçoit un *provider* pour que les `#Preview` injectent un service instantané ;
    // `_viewModel = State(initialValue:)` initialise le `@State` depuis un paramètre.
    init(provider: HomeDataProviding = MockHomeDataProvider()) {
        _viewModel = State(initialValue: HomeViewModel(provider: provider))
    }

    // ⚛️ React : `body` ≈ le `return (...)` du composant. SwiftUI le rappelle quand l'état change.
    // `some View` = « un type de vue précis, que le compilateur déduit » (≈ `JSX.Element`, mais vérifié statiquement).
    var body: some View {
        // ⚛️ React : `NavigationStack(path:)` ≈ `<Stack.Navigator>` de React Navigation. Tout ce qu'il contient (les
        // onglets ET la tab bar) est l'écran racine : un écran empilé par-dessus recouvre donc aussi la tab bar,
        // comme dans le canvas (Notifications et Focus Session n'ont pas de tab bar).
        NavigationStack(path: $path) {
            tabs
                .safeAreaInset(edge: .bottom) {
                    CustomTabBar(selection: $selectedTab, onAdd: { isAddingTask = true })
                        .padding(.horizontal, Spacing.screen)
                        .padding(.top, Size.fabRaise)           // place pour le bouton + qui dépasse
                }
                // ⚛️ React : `navigationDestination(for:)` ≈ déclarer les écrans du navigator : pour chaque valeur
                // `AppRoute` ajoutée au chemin, SwiftUI appelle cette closure et affiche la vue renvoyée.
                .navigationDestination(for: AppRoute.self) { route in
                    destination(for: route)
                }
                .toolbar(.hidden, for: .navigationBar)          // on dessine nos propres en-têtes
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

    // Le contenu des onglets.
    private var tabs: some View {
        ZStack {
            // HomeView reste montée même quand on change d'onglet : on la masque au lieu de la retirer, sinon son
            // `@State` (le ViewModel et les tâches cochées) serait détruit puis rechargé à chaque retour (D-026).
            // ⚛️ React : ≈ `display: 'none'` plutôt que `{tab === 'home' && <Home />}` (qui démonte le composant).
            HomeView(
                viewModel: viewModel,
                hasUnreadNotifications: notificationsViewModel.hasUnread,
                onNotifications: { path.append(.notifications) },
                onFocusTime: { path.append(.focusSession) },
                onGoalDetails: { select(.analytics) },
                onSeeAll: { select(.calendar) }
            )
            .opacity(selectedTab == .home ? 1 : 0)
            .allowsHitTesting(selectedTab == .home)
            .accessibilityHidden(selectedTab != .home)

            // ⚛️ React : un `switch` sur l'onglet ≈ `switch (tab) { case 'calendar': return <Calendar /> … }`. Home est déjà
            // montée plus haut ; Profile reste provisoire jusqu'à l'étape 13.
            switch selectedTab {
            case .home:
                EmptyView()
            case .calendar:
                CalendarView(viewModel: calendarViewModel, tasks: viewModel.data?.tasks ?? [])
            case .analytics:
                AnalyticsView(viewModel: analyticsViewModel, todayFocus: viewModel.data?.stats.focusTime ?? 0)
            case .profile:
                PlaceholderScreen(tab: selectedTab)
            }
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        // ⚛️ React : `switch` exhaustif sur la route : ajouter un `case` à `AppRoute` fait signaler ici (et partout où
        // on la traite) le cas à compléter.
        switch route {
        case .notifications:
            NotificationsView(
                viewModel: notificationsViewModel,
                onOpenAnalytics: {
                    path.removeAll()                            // revient à la racine, puis bascule d'onglet
                    select(.analytics)
                }
            )
        case .focusSession:
            // La tâche proposée est la prochaine à faire ; le temps de focus réalisé s'ajoute au total de Home.
            FocusSessionView(
                task: viewModel.nextTask,
                baseFocusToday: viewModel.data?.stats.focusTime ?? 0,
                onFocusLogged: { viewModel.addFocusTime($0) }
            )
        }
    }

    private func select(_ tab: AppTab) {
        withAnimation(.snappy) { selectedTab = tab }
    }
}

// ⚛️ React : `#Preview` ≈ une story Storybook : Xcode affiche ce composant à part, sans lancer l'app.
// Il est retiré du build de production.
#Preview {
    RootView(provider: MockHomeDataProvider(delay: .zero))
}
