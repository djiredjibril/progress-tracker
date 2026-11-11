import Foundation

// La période affichée par l'écran Analytics.
enum AnalyticsPeriod: String, CaseIterable, Identifiable, Hashable {
    case week, month, year

    var id: String { rawValue }
    var title: String { rawValue.capitalized }                   // « Week », « Month », « Year »
    var focusTitle: String { "Focus time this \(rawValue)" }
}

// Le temps de focus d'une journée (l'historique, base de toutes les agrégations).
struct FocusDay {
    var date: Date
    var seconds: TimeInterval
}

// Part du temps passée dans une catégorie, en pourcentage.
struct CategoryShare: Identifiable {
    var category: TaskCategory
    var percent: Int
    var id: TaskCategory { category }
}

// Les chiffres d'une période : tâches faites sur prévues, meilleure série, répartition par catégorie.
struct AnalyticsSummary {
    var tasksDone: Int
    var tasksPlanned: Int
    var bestStreakDays: Int
    var shares: [CategoryShare]

    // 0...1 : 9 sur 12 donne 0,75 (l'anneau et « 75% »).
    var tasksProgress: Double {
        tasksPlanned > 0 ? Double(tasksDone) / Double(tasksPlanned) : 0
    }

    static let empty = AnalyticsSummary(tasksDone: 0, tasksPlanned: 0, bestStreakDays: 0, shares: [])
}

struct AnalyticsData {
    var history: [FocusDay]
    var summaries: [AnalyticsPeriod: AnalyticsSummary]
}

// Une barre du graphique de focus (un jour, une semaine du mois ou un mois selon la période).
struct FocusBar: Identifiable {
    let id: Int                 // position de la barre : sert d'abscisse et de clé
    let label: String           // « M », « W2 », « N »
    let name: String            // « Wednesday », « Nov 8–14 », « November » (VoiceOver)
    let seconds: TimeInterval
    let isCurrent: Bool         // contient aujourd'hui
    let isFuture: Bool          // pas encore commencée
}
