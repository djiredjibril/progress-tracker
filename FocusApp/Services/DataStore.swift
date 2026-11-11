import Foundation

// Le stockage local de l'app : tâches, sessions de focus, notifications.
// ⚛️ React : un `protocol` ≈ l'interface d'un *repository* (`interface Storage { getTasks(); saveTask(t); … }`) : l'app parle
// au protocole ; en production c'est SwiftData (≈ SQLite), en test ou en preview c'est un simple tableau en mémoire
// (≈ remplacer AsyncStorage par un faux dans Jest). `@MainActor` : tout se passe sur le thread de l'interface.
@MainActor
protocol DataStore {
    func tasks() -> [TaskItem]
    // « Upsert » : crée la tâche si son `id` est inconnu, sinon la met à jour.
    func save(_ task: TaskItem)
    func deleteTask(id: UUID)

    func focusSessions() -> [FocusSession]
    func add(_ session: FocusSession)

    func notifications() -> [AppNotification]
    func save(_ notification: AppNotification)
}

// Stockage en mémoire : rien ne survit au relancement. Sert aux tests et aux previews.
@MainActor
final class InMemoryStore: DataStore {
    private var storedTasks: [TaskItem]
    private var storedSessions: [FocusSession]
    private var storedNotifications: [AppNotification]

    init(tasks: [TaskItem] = [], sessions: [FocusSession] = [], notifications: [AppNotification] = []) {
        storedTasks = tasks
        storedSessions = sessions
        storedNotifications = notifications
    }

    func tasks() -> [TaskItem] { storedTasks.sorted { $0.dueDate < $1.dueDate } }

    func save(_ task: TaskItem) {
        if let index = storedTasks.firstIndex(where: { $0.id == task.id }) {
            storedTasks[index] = task
        } else {
            storedTasks.append(task)
        }
    }

    func deleteTask(id: UUID) { storedTasks.removeAll { $0.id == id } }

    func focusSessions() -> [FocusSession] { storedSessions }
    func add(_ session: FocusSession) { storedSessions.append(session) }

    func notifications() -> [AppNotification] { storedNotifications }

    func save(_ notification: AppNotification) {
        if let index = storedNotifications.firstIndex(where: { $0.id == notification.id }) {
            storedNotifications[index] = notification
        } else {
            storedNotifications.append(notification)
        }
    }
}

extension InMemoryStore {
    // Un stockage REMPLI avec les données d'exemple : c'est ce que montrent les `#Preview` (l'app, elle, démarre vide).
    static func sample() -> InMemoryStore {
        let sessions = MockData.analytics.history.map { FocusSession(date: $0.date, seconds: $0.seconds) }
            + [FocusSession(date: .now, seconds: MockData.stats.focusTime)]
        return InMemoryStore(tasks: MockData.homeData.tasks, sessions: sessions, notifications: MockData.notifications)
    }
}
