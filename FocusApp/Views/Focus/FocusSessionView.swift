import SwiftUI

// Écran Focus Session : minuteur Pomodoro (4 sessions de 25 min, pauses de 5 min).
struct FocusSessionView: View {
    // ⚛️ voir CONCEPTS.md#state : la vue POSSÈDE son ViewModel. `RootView` recrée cette vue à chaque changement de Home
    // (le temps de focus y est mis à jour) ; `@State` garde la première instance, donc le minuteur n'est pas réinitialisé.
    @State private var viewModel: FocusSessionViewModel

    @Environment(\.dismiss) private var dismiss

    init(
        task: TaskItem?,
        baseFocusToday: TimeInterval,
        onFocusLogged: @escaping (TimeInterval) -> Void
    ) {
        _viewModel = State(initialValue: FocusSessionViewModel(
            task: task,
            baseFocusToday: baseFocusToday,
            onFocusLogged: onFocusLogged
        ))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.section) {
                header
                if let task = viewModel.task {
                    taskPill(task)
                }
                ring
                sessionIndicator
                controls
                infoCards
            }
            .padding(.horizontal, Spacing.screen)
            .padding(.bottom, Spacing.section)
        }
        .scrollIndicators(.hidden)
        .background { AppBackground() }
        .toolbar(.hidden, for: .navigationBar)
        // ⚛️ React : `.task(id:)` ≈ `useEffect(() => { … return cleanup }, [runState])` : le bloc redémarre quand `id`
        // change, et l'ANCIEN est annulé automatiquement (`Task.isCancelled`). Il ne tourne donc que pendant « running ».
        .task(id: viewModel.runState) {
            guard viewModel.runState == .running else { return }
            while !Task.isCancelled {
                // ⚛️ React : ≈ `await new Promise(r => setTimeout(r, 500))` : annulable, et sans fuite si on quitte l'écran
                // (≈ le `clearInterval` du cleanup d'un `useEffect`).
                try? await Task.sleep(for: .milliseconds(500))
                viewModel.tick()
            }
        }
        // ⚛️ React : ≈ le cleanup d'un `useEffect` au démontage : on comptabilise le focus déjà fait en quittant l'écran.
        .onDisappear { viewModel.leave() }
        // ⚛️ voir CONCEPTS.md#sensory-feedback : un léger retour haptique à chaque démarrage, pause ou changement de phase.
        .sensoryFeedback(.impact, trigger: viewModel.runState)
        .sensoryFeedback(.success, trigger: viewModel.phase)
    }

    // MARK: - Sections

    private var header: some View {
        // `ZStack` : le titre est centré sur TOUTE la largeur, quelle que soit la taille des boutons.
        ZStack {
            Text("Focus Session")
                .font(.appSheetTitle)
                .foregroundStyle(Color.textPrimary)
                .accessibilityAddTraits(.isHeader)
            HStack {
                CircleIconButton(systemName: "chevron.left", accessibilityLabel: "Back") { dismiss() }
                Spacer()
                // Action mock : les réglages de session ne sont pas encore dans le design détaillé.
                CircleIconButton(systemName: "ellipsis", accessibilityLabel: "Session settings") {}
            }
        }
    }

    private func taskPill(_ task: TaskItem) -> some View {
        HStack(spacing: Spacing.s) {
            Circle()
                .fill(task.category.tint)
                .frame(width: Size.badge, height: Size.badge)
                .accessibilityHidden(true)
            Text(task.title)
                .font(.appChip)
                .foregroundStyle(Color.textPrimary)
            Text("· \(task.category.title)")
                .font(.appStatLabel)
                .foregroundStyle(Color.textSecondary)
        }
        .padding(.horizontal, Spacing.m + 2)
        .padding(.vertical, Spacing.s)
        .background(Capsule().fill(Color.glassFill))
        .overlay(Capsule().strokeBorder(Color.glassStroke, lineWidth: 1))
        .accessibilityElement(children: .combine)
    }

    private var ring: some View {
        FocusRingView(progress: viewModel.progress) {
            VStack(spacing: Spacing.xs) {
                Text(viewModel.phaseLabel)
                    .font(.appFieldLabel)
                    .foregroundStyle(Color.appPrimaryDeep)
                    .padding(.horizontal, Spacing.s + 2)
                    .padding(.vertical, Spacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.segment - 2, style: .continuous)
                            .fill(Color.selectedChipFill)
                    )
                Text(viewModel.timeText)
                    .font(.appTimer)
                    .tracking(-1.5)
                    .foregroundStyle(Color.textPrimary)
                    // ⚛️ voir CONCEPTS.md#with-animation : les chiffres défilent au lieu de sauter.
                    .contentTransition(.numericText(countsDown: true))
                Text(viewModel.durationLabel)
                    .font(.appCardBody)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        // Une seule annonce VoiceOver, mise à jour en continu : « 14 minutes 59 seconds remaining ».
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(viewModel.phaseLabel)
        .accessibilityValue("\(viewModel.timeText) remaining, \(viewModel.durationLabel)")
        .accessibilityAddTraits(.updatesFrequently)
    }

    private var sessionIndicator: some View {
        HStack(spacing: Spacing.m - 2) {
            Text(viewModel.runState == .finished
                 ? "All \(viewModel.config.sessionCount) sessions done"
                 : "Session \(viewModel.sessionIndex) of \(viewModel.config.sessionCount)")
                .font(.appCardBody)
                .foregroundStyle(Color.textSecondary)
            HStack(spacing: 6) {
                ForEach(1...viewModel.config.sessionCount, id: \.self) { index in
                    dot(viewModel.dot(at: index))
                }
            }
            .accessibilityHidden(true)       // le texte à gauche dit déjà « Session 2 of 4 »
        }
    }

    @ViewBuilder
    private func dot(_ state: FocusSessionViewModel.SessionDot) -> some View {
        switch state {
        case .done:
            Circle().fill(Color.appPrimaryStrong)
                .frame(width: Size.sessionDot, height: Size.sessionDot)
        case .current:
            Circle().strokeBorder(Color.appPrimaryStrong, lineWidth: 2)
                .frame(width: Size.sessionDot, height: Size.sessionDot)
        case .upcoming:
            Circle().fill(Color.segmentTrack)
                .frame(width: Size.sessionDot, height: Size.sessionDot)
        }
    }

    private var controls: some View {
        HStack(spacing: Spacing.section + Spacing.xs) {
            RoundControlButton(systemName: "arrow.counterclockwise", accessibilityLabel: "Reset") {
                withAnimation(.snappy) { viewModel.reset() }
            }
            RoundControlButton(
                systemName: viewModel.isRunning ? "pause.fill" : "play.fill",
                accessibilityLabel: playLabel,
                style: .primary
            ) {
                withAnimation(.snappy) { viewModel.toggle() }
            }
            RoundControlButton(
                systemName: "forward.end.fill",
                accessibilityLabel: viewModel.phase == .focus ? "Skip to break" : "Skip break"
            ) {
                withAnimation(.snappy) { viewModel.skip() }
            }
            // Pas de « skip » quand tout est fini.
            .disabled(viewModel.runState == .finished)
            .opacity(viewModel.runState == .finished ? 0.4 : 1)
        }
    }

    private var playLabel: String {
        switch viewModel.runState {
        case .idle: "Start"
        case .running: "Pause"
        case .paused: "Resume"
        case .finished: "Restart"
        }
    }

    private var infoCards: some View {
        HStack(spacing: Spacing.m) {
            InfoCard(
                icon: "clock",
                iconColors: [Color.statFocusLight, Color.statFocusDark],
                value: viewModel.focusToday.shortDurationLabel,
                label: "Focus today"
            )
            InfoCard(
                icon: "cup.and.saucer",
                iconColors: [Color.statTasksLight, Color.statTasksDark],
                value: viewModel.nextDurationText,
                label: viewModel.nextLabel
            )
        }
    }
}

// Petite carte horizontale (icône, valeur, libellé), propre à cet écran.
private struct InfoCard: View {
    let icon: String
    let iconColors: [Color]
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: Spacing.m - 2) {
            Image(systemName: icon)
                .font(.appStatIcon)
                .foregroundStyle(Color.textOnAccent)
                .frame(width: Size.statIcon, height: Size.statIcon)
                .background(
                    Circle().fill(
                        LinearGradient(colors: iconColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                )
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.appInfoValue)
                    .foregroundStyle(Color.textPrimary)
                    .contentTransition(.numericText())
                Text(label)
                    .font(.appCaption)
                    .foregroundStyle(Color.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(Spacing.row)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: Radius.stat, hasShadow: false)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        FocusSessionView(task: MockData.tasks[1], baseFocusToday: MockData.stats.focusTime, onFocusLogged: { _ in })
    }
}
