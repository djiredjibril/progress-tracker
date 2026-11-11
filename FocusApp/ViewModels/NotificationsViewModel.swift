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
    private let now: () -> Date

    // ⚛️ voir CONCEPTS.md#protocol : l'heure est injectable pour tester les libellés et les groupes.
    // Les notifications sont fournies directement (mock synchrone) : contrairement à Home, pas de chargement
    // asynchrone à simuler pour l'instant.
    init(notifications: [AppNotification] = MockData.notifications, now: @escaping () -> Date = { .now }) {
        self.notifications = notifications
        self.now = now
    }

    var unreadCount: Int { notifications.filter { !$0.isRead }.count }
    var hasUnread: Bool { unreadCount > 0 }

    // « Today » = même jour que maintenant ; tout le reste est « Earlier ». Un groupe vide n'est pas affiché.
    func groups(calendar: Calendar = .current) -> [Group] {
        let current = now()
        let sorted = notifications.sorted { $0.date > $1.date }
        let today = sorted.filter { calendar.isDate($0.date, inSameDayAs: current) }
        let earlier = sorted.filter { !calendar.isDate($0.date, inSameDayAs: current) }
        return [Group(title: "Today", items: today), Group(title: "Earlier", items: earlier)]
            .filter { !$0.items.isEmpty }
    }

    func label(for notification: AppNotification, calendar: Calendar = .current) -> String {
        notification.date.relativeLabel(now: now(), calendar: calendar)
    }

    func markAsRead(_ notification: AppNotification) {
        guard let index = notifications.firstIndex(where: { $0.id == notification.id }) else { return }
        notifications[index].isRead = true
    }

    func markAllAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
    }
}
