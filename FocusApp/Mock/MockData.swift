import Foundation

// ⚛️ React : `enum` sans case = espace de noms (voir Layout.swift). Ici il regroupe des données de test,
// ≈ un fichier `mocks/homeData.ts`. Il sert au service mock ET à tous les `#Preview` (voir D-009).
enum MockData {
    static let user = User(firstName: "Alex", avatarName: "Avatar")

    // 6 h 24 min = 23 040 s
    static let stats = UserStats(tasksDone: 12, focusTime: 23_040, streakDays: 5)

    static let goal = DailyGoal(title: "Keep Going!", progress: 0.7)

    static let tasks: [TaskItem] = [
        TaskItem(title: "Design new UI screens", dueDate: today(at: 10), isCompleted: true,
                 category: .work, durationMinutes: 90),
        TaskItem(title: "Workout", dueDate: today(at: 18),
                 category: .health, durationMinutes: 60),
        TaskItem(title: "Read a book", dueDate: today(at: 20),
                 category: .learning, durationMinutes: 30)
    ]

    // Quelques tâches sur d'autres jours de la semaine courante (lundi à dimanche), pour que les points du bandeau de
    // Calendar aient un sens. Celles qui tombent aujourd'hui sont écartées : Home ne doit montrer que les 3 du jour.
    static let weekTasks: [TaskItem] = [
        TaskItem(title: "Plan the week", dueDate: inThisWeek(day: 0, hour: 9), isCompleted: true,
                 category: .work, durationMinutes: 30),
        TaskItem(title: "Dentist appointment", dueDate: inThisWeek(day: 1, hour: 15),
                 category: .personal, durationMinutes: 60),
        TaskItem(title: "Prepare the presentation", dueDate: inThisWeek(day: 3, hour: 9, minute: 30),
                 category: .work, durationMinutes: 90),
        TaskItem(title: "Grocery shopping", dueDate: inThisWeek(day: 5, hour: 10),
                 category: .personal, durationMinutes: 45)
    ].filter { !Calendar.current.isDateInToday($0.dueDate) }

    // Toutes les tâches, triées par échéance.
    static let homeData = HomeData(
        user: user,
        stats: stats,
        goal: goal,
        tasks: (tasks + weekTasks).sorted { $0.dueDate < $1.dueDate }
    )

    // Notifications : les dates sont relatives à « maintenant » pour que les libellés (« Just now », « 2h ago »…)
    // et les groupes « Today / Earlier » restent cohérents quel que soit le moment du lancement.
    static let notifications: [AppNotification] = {
        let now = Date.now
        let twoDaysAgo = now.addingTimeInterval(-2 * 24 * 3600)
        let weekday = twoDaysAgo.formatted(.dateTime.weekday(.wide).locale(Locale(identifier: "en_US")))
        return [
            AppNotification(kind: .focusSession, title: "Focus session complete",
                            message: "You focused 25 min on Read a book.",
                            date: now.addingTimeInterval(-20)),
            AppNotification(kind: .streak, title: "5-day streak!",
                            message: "Finish one more task today to reach 6 days.",
                            date: now.addingTimeInterval(-2 * 3600)),
            AppNotification(kind: .taskCompleted, title: "Task completed",
                            message: "Design new UI screens was marked as done.",
                            date: now.addingTimeInterval(-4 * 3600), isRead: true),
            AppNotification(kind: .weeklyReport, title: "Weekly report is ready",
                            message: "See how your focus time compares to last week.",
                            date: now.addingTimeInterval(-24 * 3600), isRead: true),
            AppNotification(kind: .dailyGoal, title: "Daily goal reached",
                            message: "You completed every task planned for \(weekday).",
                            date: twoDaysAgo, isRead: true)
        ]
    }()

    // Historique de focus (≈ 13 mois) et chiffres par période. Le temps d'aujourd'hui n'est pas dedans : il vient de Home.
    // Les lundi et mardi de la semaine courante valent exactement 4 h 12 et 5 h 06 (comme le canvas) ; le reste varie un
    // peu d'un jour à l'autre, de façon déterministe.
    static let analytics: AnalyticsData = {
        let calendar = Calendar.mondayFirst
        let today = calendar.startOfDay(for: .now)
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        // Lundi → dimanche : 4h12, 5h06, 6h24, 4h40, 3h50, 2h20, 1h10.
        let base: [TimeInterval] = [15_120, 18_360, 23_040, 16_800, 13_800, 8_400, 4_200]

        let history = (1...400).compactMap { offset -> FocusDay? in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let weekdayIndex = (calendar.component(.weekday, from: day) + 5) % 7     // lundi = 0
            let factor = day >= weekStart ? 1.0 : 0.85 + Double((offset * 37) % 11) / 33
            return FocusDay(date: day, seconds: (base[weekdayIndex] * factor).rounded())
        }

        func shares(_ work: Int, _ health: Int, _ learning: Int) -> [CategoryShare] {
            [CategoryShare(category: .work, percent: work),
             CategoryShare(category: .health, percent: health),
             CategoryShare(category: .learning, percent: learning)]
        }
        return AnalyticsData(
            history: history,
            summaries: [
                .week: AnalyticsSummary(tasksDone: 9, tasksPlanned: 12, bestStreakDays: 12, shares: shares(55, 25, 20)),
                .month: AnalyticsSummary(tasksDone: 38, tasksPlanned: 50, bestStreakDays: 12, shares: shares(50, 30, 20)),
                .year: AnalyticsSummary(tasksDone: 410, tasksPlanned: 520, bestStreakDays: 12, shares: shares(48, 27, 25))
            ]
        )
    }()

    // `day` : 0 = lundi de la semaine courante, 6 = dimanche.
    private static func inThisWeek(day: Int, hour: Int, minute: Int = 0) -> Date {
        let calendar = Calendar.mondayFirst
        let start = calendar.dateInterval(of: .weekOfYear, for: .now)?.start ?? .now
        let date = calendar.date(byAdding: .day, value: day, to: start) ?? start
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date) ?? date
    }

    // Les dates sont relatives à « aujourd'hui » pour que l'écran affiche toujours « Today, … ».
    private static func today(at hour: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: .now) ?? .now
    }
}
