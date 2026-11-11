import SwiftUI

// Version BRUTE de l'écran (textes empilés) : elle sert à prouver que les données circulent
// du service au ViewModel puis à la vue. Le vrai design arrive aux étapes 2 à 6.
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
        }
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
            ProgressView()
                .frame(maxWidth: .infinity)
        case .failed(let message):
            Text(message)
                .font(.appBody)
                .foregroundStyle(Color.textSecondary)
        case .loaded:
            // ⚛️ React : `if let` ≈ `if (data) { … }` avec, en plus, `data` re-typé « non nul » dans le bloc.
            if let data = viewModel.data {
                loadedContent(data)
            }
        }
    }

    private func loadedContent(_ data: HomeData) -> some View {
        Group {
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

            Text("My Tasks")
                .font(.appSectionTitle)
                .foregroundStyle(Color.textPrimary)
                .padding(.top, Spacing.s)

            // ⚛️ React : `ForEach` ≈ `tasks.map(task => <Row key={task.id} />)` : grâce à `Identifiable`,
            // pas besoin de préciser la clé.
            ForEach(data.tasks) { task in
                // ⚛️ React : `Button { action } label: { vue }` ≈ `<Pressable onPress={action}>vue</Pressable>`.
                // La vue envoie une *intention* au ViewModel, elle ne modifie jamais les données elle-même.
                Button {
                    viewModel.toggle(task)
                } label: {
                    Text("\(task.isCompleted ? "✅" : "⬜️") \(task.title) · \(task.dueDate.dueLabel())")
                        .font(.appTaskTitle)
                        .foregroundStyle(Color.textPrimary)
                }
            }
        }
    }
}

#Preview {
    // Service instantané : la preview affiche directement les données chargées.
    HomeView(provider: MockHomeDataProvider(delay: .zero))
}
