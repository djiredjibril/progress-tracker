import Foundation
import Observation

// ViewModel de l'écran Notifications. Il est possédé par `RootView` (comme `HomeViewModel`) parce que la pastille de la
// cloche sur Home dépend de `hasUnread` : deux écrans partagent le même état (D-035).
@Observable
@MainActor
final class NotificationsViewModel {
    // Un groupe affiché : « Today » ou « Earlier », avec ses notifications (les plus récentes d'abord).
    struct Group: Identifiable {
        let title: String
        let items: [AppNotification]
        var id: String { title }
    }

    private(set) var notifications: [AppNotification]
    // Avec un stockage, chaque changement est écrit sur l'appareil (les notifications survivent au relancement).
    private let store: DataStore?
    private let now: () -> Date

    // ⚛️ voir CONCEPTS.md#protocol : l'heure est injectable pour tester les libellés et les groupes.
    // Les notifications sont fournies directement (mock synchrone) : contrairement à Home, pas de chargement
    // asynchrone à simuler pour l'instant.
    init(notifications: [AppNotification] = MockData.notifications, now: @escaping () -> Date = { .now }) {
        self.notifications = notifications
        self.store = nil
        self.now = now
    }

    // Version de l'app : les notifications viennent du stockage local (vide au premier lancement).
    init(store: DataStore, now: @escaping () -> Date = { .now }) {
        self.notifications = store.notifications()
        self.store = store
        self.now = now
    }

    // Ajoute une notification née d'un événement réel (tâche terminée, session de focus…).
    func add(_ notification: AppNotification) {
        notifications.insert(notification, at: 0)
        store?.save(notification)
    }

    var unreadCount: Int { notifications.filter { !$0.isRead }.count }
    var hasUnread: Bool { unreadCount > 0 }

    // « Today » = même jour que maintenant ; tout le reste est « Earlier ». Un groupe vide n'est pas affiché.
    func groups(calendar: Calendar = .current) -> [Group] {
        let current = now()
        let sorted = notifications.sorted { $0.date > $1.date }
        let today = sorted.filter { calendar.isDate($0.date, inSameDayAs: current) }
        let earlier = sorted.filter { !calendar.isDate($0.date, inSameDayAs: current) }
        return [Group(title: tr("Today"), items: today), Group(title: tr("Earlier"), items: earlier)]
            .filter { !$0.items.isEmpty }
    }

    func label(for notification: AppNotification, calendar: Calendar = .current) -> String {
        notification.date.relativeLabel(now: now(), calendar: calendar)
    }

    func markAsRead(_ notification: AppNotification) {
        guard let index = notifications.firstIndex(where: { $0.id == notification.id }) else { return }
        notifications[index].isRead = true
        store?.save(notifications[index])
    }

    func markAllAsRead() {
        for index in notifications.indices where !notifications[index].isRead {
            notifications[index].isRead = true
            store?.save(notifications[index])
        }
    }
}
