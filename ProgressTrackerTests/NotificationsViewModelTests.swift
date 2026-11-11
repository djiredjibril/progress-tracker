import Foundation
import Testing
@testable import ProgressTracker

@MainActor
struct NotificationsViewModelTests {
    private let calendar = Calendar.current

    // Mercredi 11 novembre 2026, 15:00.
    private var now: Date {
        calendar.date(from: DateComponents(year: 2026, month: 11, day: 11, hour: 15))!
    }

    private func ago(hours: Double = 0, minutes: Double = 0, days: Double = 0) -> Date {
        now.addingTimeInterval(-(hours * 3600 + minutes * 60 + days * 86_400))
    }

    private func makeViewModel() -> NotificationsViewModel {
        NotificationsViewModel(
            notifications: [
                AppNotification(kind: .focusSession, title: "Focus", message: "m", date: ago(minutes: 1)),
                AppNotification(kind: .streak, title: "Streak", message: "m", date: ago(hours: 2)),
                AppNotification(kind: .taskCompleted, title: "Task", message: "m", date: ago(hours: 4), isRead: true),
                AppNotification(kind: .weeklyReport, title: "Report", message: "m", date: ago(days: 1), isRead: true),
                AppNotification(kind: .dailyGoal, title: "Goal", message: "m", date: ago(days: 2), isRead: true)
            ],
            now: { now }
        )
    }

    // MARK: - groupes

    @Test func groupsSplitTodayAndEarlierNewestFirst() {
        let groups = makeViewModel().groups(calendar: calendar)

        #expect(groups.map(\.title) == ["Today", "Earlier"])
        #expect(groups[0].items.map(\.title) == ["Focus", "Streak", "Task"])
        #expect(groups[1].items.map(\.title) == ["Report", "Goal"])
    }

    @Test func emptyGroupIsNotReturned() {
        let viewModel = NotificationsViewModel(
            notifications: [AppNotification(kind: .streak, title: "Old", message: "m", date: ago(days: 3))],
            now: { now }
        )
        #expect(viewModel.groups(calendar: calendar).map(\.title) == ["Earlier"])
    }

    // MARK: - lu / non lu

    @Test func unreadCountAndMarkAsRead() {
        let viewModel = makeViewModel()
        #expect(viewModel.unreadCount == 2)
        #expect(viewModel.hasUnread)

        viewModel.markAsRead(viewModel.notifications[0])
        #expect(viewModel.unreadCount == 1)
    }

    @Test func markAllAsReadClearsEverything() {
        let viewModel = makeViewModel()
        viewModel.markAllAsRead()

        #expect(viewModel.unreadCount == 0)
        #expect(!viewModel.hasUnread)
        #expect(viewModel.notifications.allSatisfy { $0.isRead })
    }

    // MARK: - libellés

    @Test func labelsAreRelativeToInjectedNow() {
        let viewModel = makeViewModel()
        let labels = viewModel.notifications.map { viewModel.label(for: $0, calendar: calendar) }
        #expect(labels == ["1m ago", "2h ago", "4h ago", "Yesterday", "Mon"])
    }
}

struct RelativeLabelTests {
    private let calendar = Calendar.current

    private func date(day: Int, hour: Int, minute: Int = 0, second: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 11, day: day, hour: hour, minute: minute, second: second))!
    }

    @Test func underAMinuteIsJustNow() {
        let now = date(day: 11, hour: 15)
        #expect(date(day: 11, hour: 14, minute: 59, second: 30).relativeLabel(now: now, calendar: calendar) == "Just now")
        #expect(now.addingTimeInterval(30).relativeLabel(now: now, calendar: calendar) == "Just now")   // futur
    }

    @Test func sameDayShowsMinutesThenHours() {
        let now = date(day: 11, hour: 15)
        #expect(date(day: 11, hour: 14, minute: 48).relativeLabel(now: now, calendar: calendar) == "12m ago")
        #expect(date(day: 11, hour: 13).relativeLabel(now: now, calendar: calendar) == "2h ago")
    }

    @Test func previousDaysUseYesterdayThenWeekday() {
        let now = date(day: 11, hour: 15)
        #expect(date(day: 10, hour: 9).relativeLabel(now: now, calendar: calendar) == "Yesterday")
        #expect(date(day: 9, hour: 9).relativeLabel(now: now, calendar: calendar) == "Mon")
    }
}
