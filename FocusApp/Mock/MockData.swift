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

    static let homeData = HomeData(user: user, stats: stats, goal: goal, tasks: tasks)

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

    // Les dates sont relatives à « aujourd'hui » pour que l'écran affiche toujours « Today, … ».
    private static func today(at hour: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: .now) ?? .now
    }
}
