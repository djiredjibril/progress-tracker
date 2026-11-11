import SwiftUI

// Écran d'accueil : il lit l'état du ViewModel et assemble les composants présentationnels.
struct HomeView: View {
    // ⚛️ React : `@State` ≈ `useState`, mais pour un objet @Observable entier : la vue en est propriétaire
    // et le conserve entre les rendus (comme un `useRef`/`useState` initialisé une fois). Sans `@State`,
    // le ViewModel serait recréé à chaque rendu. Pas besoin de setter : on modifie ses propriétés.
    @State private var viewModel: HomeViewModel

    // ⚛️ React : on passe un *provider* plutôt que le ViewModel pour que les `#Preview` puissent injecter
    // un service instantané. `_viewModel = State(initialValue:)` initialise le `@State` depuis un paramètre
    // (≈ `useState(() => new ViewModel(provider))`).
    init(provider: HomeDataProviding = MockHomeDataProvider()) {
        _viewModel = State(initialValue: HomeViewModel(provider: provider))
    }

    var body: some View {
        // ⚛️ React : `ScrollView` ≈ `<ScrollView>` RN. `VStack` ≈ `<View>` avec `flexDirection: 'column'`
        // (détaillé à l'étape 2).
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.m) {
                content
            }
            .padding(Spacing.screen)
            // ⚛️ React : `.animation(_:value:)` ≈ une `LayoutAnimation` déclenchée quand `value` change : ici, à chaque
            // changement d'état de chargement, les vues qui apparaissent/disparaissent le font avec leur `transition`.
            // Différence avec `withAnimation` : il est attaché à UNE valeur précise, donc plus prévisible.
            .animation(.smooth, value: viewModel.state)
        }
        // ⚛️ React : ≈ le `onRefresh` + `refreshing` du `<RefreshControl>` de RN, mais sans état à gérer : le spinner
        // reste affiché tant que la closure `async` n'est pas terminée.
        .refreshable { await viewModel.refresh() }
        .scrollIndicators(.hidden)
        // ⚛️ React : `.background { vue }` place une vue DERRIÈRE le ScrollView (voir CircleIconButton).
        .background { AppBackground() }
        // ⚛️ React : `.task { }` ≈ `useEffect(() => { load() }, [])`, avec annulation automatique quand la
        // vue disparaît. Le bloc est `async`, donc on peut y écrire `await` directement.
        .task { await viewModel.load() }
    }

    // ⚛️ React : une propriété calculée qui renvoie une vue ≈ une petite fonction `renderContent()`.
    // `@ViewBuilder` permet d'y écrire plusieurs vues / un `switch`, comme du JSX.
    @ViewBuilder
    private var content: some View {
        // ⚛️ React : `switch` sur l'enum ≈ `switch (state.status)` d'une union discriminée, mais le compilateur
        // vérifie qu'on a traité TOUS les cas. `case .failed(let message)` extrait la valeur associée.
        switch viewModel.state {
        case .idle, .loading:
            // ⚛️ React : `.redacted(reason: .placeholder)` ≈ un skeleton screen : SwiftUI remplace chaque texte et
            // chaque image par un bloc gris, SANS écrire de composant squelette. On réutilise donc le VRAI écran avec
            // des données mock (D-009) : le squelette a toujours exactement la bonne forme.
            loadedContent(MockData.homeData)
                .redacted(reason: .placeholder)
                // Squelette non interactif, et annoncé comme « Loading » plutôt que lu mot à mot par VoiceOver.
                .allowsHitTesting(false)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Loading")
                .transition(.opacity)
        case .failed(let message):
            failureView(message)
        case .loaded:
            // ⚛️ React : `if let` ≈ `if (data) { … }` avec, en plus, `data` re-typé « non nul » dans le bloc.
            if let data = viewModel.data {
                loadedContent(data)
                    // ⚛️ React : `transition` décrit COMMENT la vue entre/sort (≈ `entering={FadeIn}` de Reanimated) :
                    // fondu + légère montée. Elle ne joue que si l'insertion a lieu dans une animation (voir ci-dessus).
                    .transition(.opacity.combined(with: .offset(y: Spacing.section)))
            }
        }
    }

    private func failureView(_ message: String) -> some View {
        VStack(spacing: Spacing.m) {
            Text(message)
                .font(.appBody)
                .foregroundStyle(Color.textSecondary)
            Button {
                // ⚛️ React : `Task { }` lance du code `async` depuis un contexte synchrone (un handler de bouton),
                // ≈ appeler une fonction `async` sans `await` dans un `onPress`.
                Task { await viewModel.load() }
            } label: {
                Text("Try again")
                    .font(.appLink)
                    .foregroundStyle(Color.appPrimary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // Un VStack (et non un `Group`) : la transition s'applique ainsi à TOUT le bloc, et le `zIndex` du header
    // continue de s'appliquer entre ses frères directs.
    private func loadedContent(_ data: HomeData) -> some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            HomeHeaderView(
                greeting: viewModel.greeting,
                firstName: data.user.firstName,
                avatarName: data.user.avatarName,
                hasUnreadNotifications: true,   // pas encore dans le modèle : valeur fixe pour la maquette
                onSearch: {},                   // actions mock : rien à brancher pour l'instant
                onNotifications: {}
            )
            // ⚛️ React : `zIndex` ≈ `zIndex` de RN. Dans un VStack, les vues suivantes se dessinent par-dessus les
            // précédentes ; sans `zIndex(1)`, les cartes de stats masqueraient le bas de l'avatar qui déborde.
            .zIndex(1)

            // ⚛️ React : un `HStack` dont chaque enfant a `frame(maxWidth: .infinity)` ≈ trois enfants `flex: 1`.
            HStack(spacing: Spacing.m) {
                StatCardView(
                    icon: "chart.bar.fill",
                    iconColors: [Color.statTasksLight, Color.statTasksDark],
                    value: .stat([(data.stats.tasksDone, "")]),
                    label: "Tasks Done"
                )
                StatCardView(
                    icon: "clock",
                    iconColors: [Color.statFocusLight, Color.statFocusDark],
                    value: .stat([(data.stats.focusHours, "h"), (data.stats.focusMinutes, "m")]),
                    label: "Focus Time"
                )
                StatCardView(
                    icon: "flame.fill",
                    iconColors: [Color.statStreakLight, Color.statStreakDark],
                    value: .stat([(data.stats.streakDays, "")]),
                    label: "Day Streak"
                )
            }

            GoalCardView(
                title: data.goal.title,
                progress: data.goal.progress,
                percent: data.goal.progressPercent,
                onTap: {}       // action mock : la navigation viendra plus tard
            )

            SectionHeaderView(title: "My Tasks", actionTitle: "See All", onAction: {})
                .padding(.top, Spacing.m)       // 12 (VStack) + 12 = 24 = Spacing.section entre les grands blocs

            // ⚛️ React : `ForEach` ≈ `tasks.map(task => <Row key={task.id} />)` : grâce à `Identifiable`,
            // pas besoin de préciser la clé.
            ForEach(data.tasks) { task in
                TaskRowView(
                    task: task,
                    // ⚛️ React : une closure passée en prop ≈ `onPress={() => toggle(task)}`. La vue envoie une
                    // *intention* au ViewModel, elle ne modifie jamais les données elle-même.
                    // `withAnimation` ≈ `LayoutAnimation.configureNext(...)` / `Animated.timing` : tout ce qui change
                    // d'état dans ce bloc (coche, compteur « Tasks Done ») est animé. `.snappy` = ressort court et vif.
                    onToggle: { withAnimation(.snappy) { viewModel.toggle(task) } },
                    onEdit: {},         // actions mock du menu ⋮
                    onDelete: {}
                )
            }
        }
    }
}

#Preview {
    // Service instantané : la preview affiche directement les données chargées.
    HomeView(provider: MockHomeDataProvider(delay: .zero))
}
