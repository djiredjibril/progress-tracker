import Foundation

// Le nom `Notification` est déjà pris par Foundation (comme `Task`, voir D-007) : d'où le préfixe `App`.
struct AppNotification: Identifiable, Hashable {
    enum Kind: Hashable {
        case focusSession
        case streak
        case taskCompleted
        case weeklyReport
        case dailyGoal

        var systemImage: String {
            switch self {
            case .focusSession: "clock"
            case .streak: "flame.fill"
            case .taskCompleted: "checkmark"
            case .weeklyReport: "chart.bar"
            case .dailyGoal: "target"
            }
        }
    }

    let id: UUID
    var kind: Kind
    var title: String
    var message: String
    var date: Date
    var isRead: Bool

    init(id: UUID = UUID(), kind: Kind, title: String, message: String, date: Date, isRead: Bool = false) {
        self.id = id
        self.kind = kind
        self.title = title
        self.message = message
        self.date = date
        self.isRead = isRead
    }
}
