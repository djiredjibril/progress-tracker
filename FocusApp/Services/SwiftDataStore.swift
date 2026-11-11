import Foundation
import SwiftData

// ⚛️ React : `@Model` ≈ le schéma d'une table (une entité Prisma / TypeORM / WatermelonDB). SwiftData génère la base SQLite
// à partir de ces classes : pas de SQL, pas de migration à écrire pour un premier schéma.
// Différence : ce sont des CLASSES observables (pas des structs). On les garde à l'intérieur du stockage et on expose
// au reste de l'app les `struct` habituelles (`TaskItem`…) : les vues ne connaissent pas SwiftData.
@Model
final class TaskRecord {
    @Attribute(.unique) var id: UUID
    var title: String
    var dueDate: Date
    var isCompleted: Bool
    var categoryRaw: String          // `TaskCategory.rawValue` : on stocke le texte, pas l'enum
    var priorityRaw: String
    var durationMinutes: Int
    var reminderMinutes: Int?

    init(_ task: TaskItem) {
        id = task.id
        title = task.title
        dueDate = task.dueDate
        isCompleted = task.isCompleted
        categoryRaw = task.category.rawValue
        priorityRaw = task.priority.rawValue
        durationMinutes = task.durationMinutes
        reminderMinutes = task.reminderMinutes
    }

    func update(from task: TaskItem) {
        title = task.title
        dueDate = task.dueDate
        isCompleted = task.isCompleted
        categoryRaw = task.category.rawValue
        priorityRaw = task.priority.rawValue
        durationMinutes = task.durationMinutes
        reminderMinutes = task.reminderMinutes
    }

    var item: TaskItem {
        TaskItem(
            id: id,
            title: title,
            dueDate: dueDate,
            isCompleted: isCompleted,
            category: TaskCategory(rawValue: categoryRaw) ?? .work,
            priority: TaskPriority(rawValue: priorityRaw) ?? .medium,
            durationMinutes: durationMinutes,
            reminderMinutes: reminderMinutes
        )
    }
}

@Model
final class FocusRecord {
    @Attribute(.unique) var id: UUID
    var date: Date
    var seconds: Double
    var taskTitle: String?

    init(_ session: FocusSession) {
        id = session.id
        date = session.date
        seconds = session.seconds
        taskTitle = session.taskTitle
    }

    var item: FocusSession { FocusSession(id: id, date: date, seconds: seconds, taskTitle: taskTitle) }
}

@Model
final class NotificationRecord {
    @Attribute(.unique) var id: UUID
    var kindRaw: String
    var title: String
    var message: String
    var date: Date
    var isRead: Bool

    init(_ notification: AppNotification) {
        id = notification.id
        kindRaw = notification.kind.rawValue
        title = notification.title
        message = notification.message
        date = notification.date
        isRead = notification.isRead
    }

    func update(from notification: AppNotification) {
        title = notification.title
        message = notification.message
        date = notification.date
        isRead = notification.isRead
    }

    var item: AppNotification {
        AppNotification(
            id: id,
            kind: AppNotification.Kind(rawValue: kindRaw) ?? .taskCompleted,
            title: title,
            message: message,
            date: date,
            isRead: isRead
        )
    }
}

// Le stockage de production : SwiftData, dans un fichier sur l'appareil.
@MainActor
final class SwiftDataStore: DataStore {
    // ⚛️ React : le `ModelContainer` ≈ la connexion à la base (le fichier SQLite) ; son `mainContext` ≈ une transaction /
    // un « unit of work » : on y insère, modifie, supprime, puis `save()` écrit sur le disque.
    private let container: ModelContainer
    private var context: ModelContext { container.mainContext }

    // `inMemory: true` : base temporaire, détruite à la fermeture (tests de ce stockage).
    init(inMemory: Bool = false) throws {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)
        container = try ModelContainer(
            for: TaskRecord.self, FocusRecord.self, NotificationRecord.self,
            configurations: configuration
        )
    }

    // Le stockage de l'app : la vraie base ; si elle ne peut pas s'ouvrir (disque plein…), une base en mémoire plutôt qu'un
    // plantage : l'app reste utilisable, sans sauvegarde (D-047).
    static func makeDefault() -> DataStore {
        // Sur une installation neuve, le dossier « Application Support » n'existe pas encore : on le crée avant que SwiftData
        // ne l'y cherche (sinon il le crée seul après avoir journalisé des erreurs CoreData bruyantes mais sans gravité).
        try? FileManager.default.createDirectory(at: .applicationSupportDirectory, withIntermediateDirectories: true)
        if let store = try? SwiftDataStore() { return store }
        if let store = try? SwiftDataStore(inMemory: true) { return store }
        return InMemoryStore()
    }

    // MARK: - Tâches

    func tasks() -> [TaskItem] {
        let descriptor = FetchDescriptor<TaskRecord>(sortBy: [SortDescriptor(\.dueDate)])
        return ((try? context.fetch(descriptor)) ?? []).map(\.item)
    }

    func save(_ task: TaskItem) {
        let id = task.id
        let found = try? context.fetch(FetchDescriptor<TaskRecord>(predicate: #Predicate { $0.id == id })).first
        if let found {
            found.update(from: task)
        } else {
            context.insert(TaskRecord(task))
        }
        persist()
    }

    func deleteTask(id: UUID) {
        let found = try? context.fetch(FetchDescriptor<TaskRecord>(predicate: #Predicate { $0.id == id })).first
        if let found { context.delete(found) }
        persist()
    }

    // MARK: - Focus

    func focusSessions() -> [FocusSession] {
        ((try? context.fetch(FetchDescriptor<FocusRecord>())) ?? []).map(\.item)
    }

    func add(_ session: FocusSession) {
        context.insert(FocusRecord(session))
        persist()
    }

    // MARK: - Notifications

    func notifications() -> [AppNotification] {
        let descriptor = FetchDescriptor<NotificationRecord>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        return ((try? context.fetch(descriptor)) ?? []).map(\.item)
    }

    func save(_ notification: AppNotification) {
        let id = notification.id
        let found = try? context.fetch(FetchDescriptor<NotificationRecord>(predicate: #Predicate { $0.id == id })).first
        if let found {
            found.update(from: notification)
        } else {
            context.insert(NotificationRecord(notification))
        }
        persist()
    }

    // Écrit sur le disque. Un échec d'écriture est rare (disque plein) : on ne bloque pas l'écran, l'état en mémoire reste juste.
    private func persist() {
        do { try context.save() } catch { print("SwiftData save failed:", error) }
    }
}
