import SwiftUI

// Écran d'accueil : il lit l'état du ViewModel et assemble les composants présentationnels.
struct HomeView: View {
    // ⚛️ React : le ViewModel est maintenant reçu en PROP : c'est `RootView` qui le possède (voir D-033). C'est
    // « remonter l'état » (lifting state up) : le bouton + de la tab bar et l'écran Home doivent partager les mêmes
    // tâches. Un simple `let` suffit : la classe est @Observable, la vue suit les propriétés qu'elle lit.
    let viewModel: HomeViewModel

    // ⚛️ React : la navigation est décidée par le PARENT : l'écran reçoit des callbacks (`onNotifications`…) comme les
    // `navigation.navigate(...)` qu'on passerait en props. HomeView ne connaît ni la pile ni les onglets.
    let hasUnreadNotifications: Bool
    let onSearch: () -> Void
    let onNotifications: () -> Void
    let onFocusTime: () -> Void
    let onGoalDetails: () -> Void
    let onSeeAll: () -> Void
    let onAddTask: () -> Void
    let onEditTask: (TaskItem) -> Void

    // La tâche dont l'utilisateur a demandé la suppression : tant qu'il n'a pas confirmé, rien n'est supprimé.
    @State private var taskPendingDeletion: TaskItem?

    var body: some View {
        // ⚛️ React : `ScrollView` ≈ `<ScrollView>` RN. `VStack` ≈ `<View>` avec `flexDirection: 'column'`
        // (détaillé à l'étape 2).
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                content
            }
            // Marges du canvas : 20 pt sur les côtés, peu d'espace en haut (la safe area dégage déjà l'encoche).
            .padding(.horizontal, Spacing.screen)
            .padding(.top, Spacing.s)
            .padding(.bottom, Spacing.screen)
            // ⚛️ React : `.animation(_:value:)` ≈ une `LayoutAnimation` déclenchée quand `value` change : ici, à chaque
            // changement d'état de chargement, les vues qui apparaissent/disparaissent le font avec leur `transition`.
            // Différence avec `withAnimation` : il est attaché à UNE valeur précise, donc plus prévisible.
            .animation(.smooth, value: viewModel.state)
        }
        // ⚛️ React : ≈ le `onRefresh` + `refreshing` du `<RefreshControl>` de RN, mais sans état à gérer : le spinner
        // reste affiché tant que la closure `async` n'est pas terminée.
        .refreshable { await viewModel.refresh() }
        // ⚛️ voir CONCEPTS.md#confirmation-dialog : `presenting:` transmet la tâche concernée à la boîte de dialogue.
        // L'`isPresented` dérive de `taskPendingDeletion` : non `nil` = boîte ouverte, et la fermer le remet à `nil`.
        .confirmationDialog(
            "Delete this task?",
            isPresented: Binding(
                get: { taskPendingDeletion != nil },
                set: { if !$0 { taskPendingDeletion = nil } }
            ),
            titleVisibility: .visible,
            presenting: taskPendingDeletion
        ) { task in
            Button("Delete “\(task.title)”", role: .destructive) {
                withAnimation(.snappy) { viewModel.deleteTask(task) }
            }
            Button("Cancel", role: .cancel) {}
        } message: { _ in
            Text("This cannot be undone.")
        }
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
        // Rythme du canvas : 16 pt entre les grands blocs.
        VStack(alignment: .leading, spacing: Spacing.l) {
            HomeHeaderView(
                greeting: viewModel.greeting,
                firstName: data.user.firstName,
                avatarName: data.user.avatarName,
                avatarURL: data.user.avatarURL,
                hasUnreadNotifications: hasUnreadNotifications,
                onSearch: onSearch,
                onNotifications: onNotifications
            )

            // ⚛️ React : un `HStack` dont chaque enfant a `frame(maxWidth: .infinity)` ≈ trois enfants `flex: 1`.
            HStack(spacing: Spacing.m) {
                StatCardView(
                    icon: "chart.bar.fill",
                    iconColors: [Color.statTasksLight, Color.statTasksDark],
                    value: .stat([(data.stats.tasksDone, "")]),
                    label: "Tasks Done"
                )
                // ⚛️ React : ≈ envelopper la carte dans un `<Pressable onPress>`. `.plain` garde l'apparence de la carte ;
                // le hint dit à VoiceOver où mène le toucher (la carte seule est annoncée comme une statistique).
                Button(action: onFocusTime) {
                    StatCardView(
                        icon: "clock",
                        iconColors: [Color.statFocusLight, Color.statFocusDark],
                        value: .stat([(data.stats.focusHours, "h"), (data.stats.focusMinutes, "m")]),
                        label: "Focus Time"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityHint("Opens your focus session")
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
                onTap: onGoalDetails
            )

            // En-tête (44 pt) puis les lignes : 4 pt entre eux, 8 pt entre les lignes (canvas).
            VStack(alignment: .leading, spacing: Spacing.xs) {
                SectionHeaderView(title: "My Tasks", actionTitle: "See All", onAction: onSeeAll)

                let todayTasks = data.tasks(on: viewModel.currentDate)
                if todayTasks.isEmpty {
                    // Premier lancement ou journée vide : on invite à créer une tâche au lieu de laisser un blanc.
                    EmptyStateView(
                        systemImage: "checklist",
                        title: "No tasks today",
                        message: "Plan your day by adding your first task.",
                        actionTitle: "Add a task",
                        action: onAddTask
                    )
                    .glassCard(cornerRadius: Radius.stat, hasShadow: false)
                }
                VStack(spacing: Spacing.s) {
                    // ⚛️ React : `ForEach` ≈ `tasks.map(task => <Row key={task.id} />)` : grâce à `Identifiable`,
                    // pas besoin de préciser la clé.
                    ForEach(todayTasks) { task in
                        TaskRowView(
                            task: task,
                            // ⚛️ React : une closure passée en prop ≈ `onPress={() => toggle(task)}`. La vue envoie une
                            // *intention* au ViewModel, elle ne modifie jamais les données elle-même.
                            // `withAnimation` ≈ `LayoutAnimation.configureNext(...)` : tout ce qui change d'état dans ce
                            // bloc (coche, compteur « Tasks Done ») est animé. `.snappy` = ressort court et vif.
                            onToggle: { withAnimation(.snappy) { viewModel.toggle(task) } },
                            onEdit: { onEditTask(task) },
                            onDelete: { taskPendingDeletion = task }
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    // Service instantané : la preview affiche directement les données chargées.
    HomeView(
        viewModel: HomeViewModel(provider: MockHomeDataProvider(delay: .zero)),
        hasUnreadNotifications: true,
        onSearch: {},
        onNotifications: {},
        onFocusTime: {},
        onGoalDetails: {},
        onSeeAll: {},
        onAddTask: {},
        onEditTask: { _ in }
    )
}
