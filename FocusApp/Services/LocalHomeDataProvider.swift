import Foundation

// Fournit les données de Home depuis le stockage local : les tâches sont lues, les statistiques CALCULÉES (LocalStats).
// ⚛️ React : ≈ le `queryFn` de React Query, qui lit la base locale au lieu du réseau.
struct LocalHomeDataProvider: HomeDataProviding {
    let store: DataStore
    var user: User = MockData.user
    var now: () -> Date = { .now }

    func fetchHomeData() async throws -> HomeData {
        let tasks = store.tasks()
        let sessions = store.focusSessions()
        let current = now()
        return HomeData(
            user: user,
            stats: LocalStats.stats(tasks: tasks, sessions: sessions, now: current),
            goal: LocalStats.goal(tasks: tasks, now: current),
            tasks: tasks
        )
    }
}
