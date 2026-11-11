// Agrège tout ce dont l'écran d'accueil a besoin : c'est la « réponse d'API » du service.
struct HomeData {
    var user: User
    var stats: UserStats
    var goal: DailyGoal
    var tasks: [TaskItem]       // ⚛️ voir CONCEPTS.md#struct-vs-class : `[TaskItem]` ≈ `TaskItem[]`
}
