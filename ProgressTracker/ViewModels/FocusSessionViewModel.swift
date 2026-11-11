import Foundation
import Observation

// Machine à états du minuteur de focus. Toute la logique vit ici (pas dans la vue) et ne dépend que d'une HORLOGE
// injectée : les tests avancent le temps à la main, sans attendre ni `Timer`.
@Observable
@MainActor
final class FocusSessionViewModel {
    // ⚛️ React : deux `enum` = deux axes d'état indépendants (≈ `useReducer` avec des états nommés) : QUELLE phase
    // (focus ou pause) et SI le minuteur tourne. Plus lisible, et plus sûr, que des booléens `isBreak` / `isPaused`.
    enum Phase { case focus, rest }
    enum RunState { case idle, running, paused, finished }
    enum SessionDot { case done, current, upcoming }

    let config: FocusSessionConfig
    let task: TaskItem?

    private(set) var phase: Phase = .focus
    private(set) var runState: RunState = .idle
    private(set) var remaining: TimeInterval
    private(set) var sessionIndex = 1                       // session de focus en cours, de 1 à `sessionCount`
    private(set) var loggedFocusSeconds: TimeInterval = 0   // focus déjà comptabilisé pendant cette série

    private let baseFocusToday: TimeInterval
    private var endDate: Date?
    private let now: () -> Date
    private let onFocusLogged: (TimeInterval) -> Void

    // ⚛️ voir CONCEPTS.md#protocol : l'horloge et le callback sont injectés par l'`init`. En test, `now` renvoie une date
    // qu'on avance à la main ; en vrai, `.now`. `onFocusLogged` prévient le parent (Home) du temps de focus réalisé.
    init(
        task: TaskItem? = nil,
        config: FocusSessionConfig = FocusSessionConfig(),
        baseFocusToday: TimeInterval = 0,
        now: @escaping () -> Date = { .now },
        onFocusLogged: @escaping (TimeInterval) -> Void = { _ in }
    ) {
        self.task = task
        self.config = config
        self.baseFocusToday = baseFocusToday
        self.now = now
        self.onFocusLogged = onFocusLogged
        self.remaining = config.focusDuration
    }

    // MARK: - Valeurs dérivées pour la vue

    var phaseDuration: TimeInterval { phase == .focus ? config.focusDuration : config.breakDuration }
    var elapsed: TimeInterval { phaseDuration - remaining }
    var isRunning: Bool { runState == .running }

    // 0...1 : part de la phase déjà écoulée (pilote l'anneau).
    var progress: Double {
        guard phaseDuration > 0, runState != .finished else { return runState == .finished ? 1 : 0 }
        return min(max(elapsed / phaseDuration, 0), 1)
    }

    // « 15:00 » : on arrondit à la seconde SUPÉRIEURE, comme un vrai minuteur (14,2 s restantes s'affichent « 0:15 »).
    var timeText: String {
        let total = Int(remaining.rounded(.up))
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    var phaseLabel: String {
        switch (runState, phase) {
        case (.finished, _): tr("Complete")
        case (_, .focus): tr("Deep work")
        case (_, .rest): tr("Break")
        }
    }

    var durationLabel: String {
        runState == .finished ? tr("all sessions done") : tr("of %lld min", Int(phaseDuration / 60))
    }

    // « Next break : 5 min » pendant le focus, « Next focus : 25 min » pendant la pause.
    var nextLabel: String { phase == .focus ? tr("Next break") : tr("Next focus") }
    var nextDurationText: String {
        tr("%lld min", Int((phase == .focus ? config.breakDuration : config.focusDuration) / 60))
    }

    // Temps de focus du jour : la base (Home) + ce qui est déjà comptabilisé + la session en cours.
    var focusToday: TimeInterval {
        let current = (phase == .focus && runState != .finished) ? elapsed : 0
        return baseFocusToday + loggedFocusSeconds + current
    }

    // ⚛️ React : les 4 pastilles sous l'anneau : fait / en cours / à venir.
    func dot(at index: Int) -> SessionDot {
        if runState == .finished || index < sessionIndex { return .done }
        if index == sessionIndex { return phase == .rest ? .done : .current }
        return .upcoming
    }

    // MARK: - Actions

    func toggle() {
        switch runState {
        case .idle, .paused: start()
        case .running: pause()
        case .finished: reset()
        }
    }

    func start() {
        guard runState == .idle || runState == .paused else { return }
        endDate = now().addingTimeInterval(remaining)
        runState = .running
    }

    func pause() {
        guard runState == .running else { return }
        tick()
        guard runState == .running else { return }      // la phase vient de se terminer pendant `tick()`
        endDate = nil
        runState = .paused
    }

    // Appelée régulièrement par la vue. Le temps restant se déduit de l'HORLOGE (`endDate - now`) et non d'un compteur
    // décrémenté : si l'app passe en arrière-plan ou si un tick est en retard, l'affichage reste juste.
    func tick() {
        guard runState == .running, let endDate else { return }
        remaining = max(0, endDate.timeIntervalSince(now()))
        if remaining <= 0 { finishPhase(focusedSeconds: phase == .focus ? config.focusDuration : 0) }
    }

    // Passe à la phase suivante sans attendre : en focus, on comptabilise le temps réellement fait.
    func skip() {
        guard runState != .finished else { return }
        if runState == .running { tick() }
        guard runState != .finished else { return }
        finishPhase(focusedSeconds: phase == .focus ? elapsed : 0)
    }

    // Recommence la phase courante (ou toute la série si elle est terminée). Le temps écoulé n'est pas comptabilisé.
    func reset() {
        if runState == .finished {
            sessionIndex = 1
            phase = .focus
        }
        remaining = phaseDuration
        endDate = nil
        runState = .idle
    }

    // Quand on quitte l'écran : le temps de focus déjà fait dans la session en cours est comptabilisé, puis on s'arrête.
    func leave() {
        if runState == .running { tick() }
        if phase == .focus, runState != .finished {
            log(elapsed)
        }
        endDate = nil
        remaining = phaseDuration
        if runState != .finished { runState = .idle }
    }

    // MARK: - Interne

    private func finishPhase(focusedSeconds: TimeInterval) {
        log(focusedSeconds)
        switch phase {
        case .focus:
            if sessionIndex >= config.sessionCount {
                remaining = 0
                endDate = nil
                runState = .finished
            } else {
                // La pause démarre toute seule.
                phase = .rest
                remaining = config.breakDuration
                endDate = now().addingTimeInterval(remaining)
                runState = .running
            }
        case .rest:
            // Le focus suivant attend l'appui de l'utilisateur.
            sessionIndex += 1
            phase = .focus
            remaining = config.focusDuration
            endDate = nil
            runState = .idle
        }
    }

    private func log(_ seconds: TimeInterval) {
        guard seconds > 0 else { return }
        loggedFocusSeconds += seconds
        onFocusLogged(seconds)
    }
}
