import Foundation

// Réglages d'une série de sessions de focus (technique Pomodoro) : 4 sessions de 25 min, séparées par 5 min de pause.
struct FocusSessionConfig: Equatable {
    var focusDuration: TimeInterval = 25 * 60
    var breakDuration: TimeInterval = 5 * 60
    var sessionCount = 4

    // La durée de focus vient du réglage « Focus session » (en minutes) ; le reste garde ses valeurs par défaut.
    init(focusMinutes: Int) {
        self.focusDuration = TimeInterval(focusMinutes) * 60
    }

    init(focusDuration: TimeInterval = 25 * 60, breakDuration: TimeInterval = 5 * 60, sessionCount: Int = 4) {
        self.focusDuration = focusDuration
        self.breakDuration = breakDuration
        self.sessionCount = sessionCount
    }
}
