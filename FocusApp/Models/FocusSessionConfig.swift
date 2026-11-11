import Foundation

// Réglages d'une série de sessions de focus (technique Pomodoro) : 4 sessions de 25 min, séparées par 5 min de pause.
struct FocusSessionConfig: Equatable {
    var focusDuration: TimeInterval = 25 * 60
    var breakDuration: TimeInterval = 5 * 60
    var sessionCount = 4
}
