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

    // Les dates sont relatives à « aujourd'hui » pour que l'écran affiche toujours « Today, … ».
    private static func today(at hour: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: .now) ?? .now
    }
}
