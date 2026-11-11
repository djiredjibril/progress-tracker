import Foundation

// Agrège tout ce dont l'écran d'accueil a besoin : c'est la « réponse d'API » du service.
struct HomeData {
    var user: User
    var stats: UserStats
    var goal: DailyGoal
    var tasks: [TaskItem]       // ⚛️ voir CONCEPTS.md#struct-vs-class : `[TaskItem]` ≈ `TaskItem[]`

    // Les tâches dont l'échéance tombe un jour donné (Home affiche celles d'aujourd'hui, Calendar celles du jour choisi).
    func tasks(on day: Date, calendar: Calendar = .current) -> [TaskItem] {
        tasks.filter { calendar.isDate($0.dueDate, inSameDayAs: day) }
    }
}
