import Foundation

// Clés de `UserDefaults` des réglages.
// ⚛️ React : ≈ les clés d'`AsyncStorage`, regroupées en constantes pour ne pas les retaper (une faute de frappe donnerait
// un réglage qui ne se sauvegarde jamais). `@AppStorage` lit et écrit `UserDefaults` avec ces clés.
enum SettingsKey {
    static let notificationsEnabled = "settings.notificationsEnabled"
    static let dailyGoal = "settings.dailyGoal"
    static let focusMinutes = "settings.focusMinutes"
    static let appearance = "settings.appearance"
}

// Valeurs proposées et libellés des réglages (testables sans aucune vue).
enum SettingsOptions {
    static let defaultDailyGoal = 5
    static let defaultFocusMinutes = 25
    static let dailyGoalRange = 1...10
    static let focusMinuteOptions = [15, 25, 45, 60]

    // « 5 tasks », « 1 task »
    static func dailyGoalLabel(_ tasks: Int) -> String {
        "\(tasks) \(tasks == 1 ? "task" : "tasks")"
    }

    // « 25 min »
    static func focusLabel(_ minutes: Int) -> String {
        "\(minutes) min"
    }
}
