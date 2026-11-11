import Foundation
import Testing
@testable import FocusApp

// Le ViewModel branché sur un stockage : tout est écrit, et les chiffres sont recalculés depuis les données.
@MainActor
struct LocalPersistenceTests {
    private static let noon = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: .now)!

    private func today(_ title: String, hour: Int, done: Bool = false) -> TaskItem {
        TaskItem(title: title, dueDate: Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: .now)!, isCompleted: done)
    }

    private func makeViewModel(store: DataStore) -> (HomeViewModel, () -> [AppNotification]) {
        let viewModel = HomeViewModel(provider: LocalHomeDataProvider(store: store), store: store, now: { Self.noon })
        var events: [AppNotification] = []
        viewModel.onEvent = { events.append($0) }
        return (viewModel, { events })
    }

    @Test func aNewInstallStartsEmpty() async throws {
        let (viewModel, _) = makeViewModel(store: InMemoryStore())
        await viewModel.load()
        let data = try #require(viewModel.data)
        #expect(data.tasks.isEmpty)
        #expect(data.stats.tasksDone == 0)
        #expect(data.stats.focusTime == 0)
        #expect(data.stats.streakDays == 0)
        #expect(data.goal.progress == 0)
    }

    @Test func tasksSurviveARelaunch() async throws {
        let store = try SwiftDataStore(inMemory: true)
        let (first, _) = makeViewModel(store: store)
        await first.load()
        first.addTask(today("Persisted", hour: 14))

        // « Relancement » : un nouveau ViewModel sur le MÊME stockage retrouve la tâche.
        let (second, _) = makeViewModel(store: store)
        await second.load()
        #expect(second.data?.tasks.map(\.title) == ["Persisted"])
    }

    @Test func togglingPersistsAndRecomputesStats() async throws {
        let store = InMemoryStore(tasks: [today("A", hour: 9), today("B", hour: 10)])
        let (viewModel, _) = makeViewModel(store: store)
        await viewModel.load()
        let first = try #require(viewModel.data?.tasks.first)

        viewModel.toggle(first)

        #expect(store.tasks().first { $0.id == first.id }?.isCompleted == true)
        #expect(viewModel.data?.stats.tasksDone == 1)
        #expect(viewModel.data?.goal.progressPercent == 50)
        #expect(viewModel.data?.stats.streakDays == 1)
    }

    @Test func editingAndDeletingArePersisted() async throws {
        let task = today("Old", hour: 9)
        let store = InMemoryStore(tasks: [task])
        let (viewModel, _) = makeViewModel(store: store)
        await viewModel.load()

        var edited = task
        edited.title = "New"
        viewModel.updateTask(edited)
        #expect(store.tasks().first?.title == "New")

        viewModel.deleteTask(edited)
        #expect(store.tasks().isEmpty)
    }

    @Test func focusTimeIsStoredAsASession() async throws {
        let store = InMemoryStore()
        let (viewModel, _) = makeViewModel(store: store)
        await viewModel.load()

        viewModel.addFocusTime(1500, taskTitle: "Read")

        #expect(store.focusSessions().count == 1)
        #expect(store.focusSessions().first?.taskTitle == "Read")
        #expect(viewModel.data?.stats.focusTime == 1500)
    }

    // MARK: - Événements → notifications

    @Test func completingTheLastTaskAnnouncesTheTaskAndTheGoal() async throws {
        let store = InMemoryStore(tasks: [today("Only", hour: 9)])
        let (viewModel, events) = makeViewModel(store: store)
        await viewModel.load()

        viewModel.toggle(try #require(viewModel.data?.tasks.first))

        let kinds = events().map(\.kind)
        #expect(kinds.contains(.taskCompleted))
        #expect(kinds.contains(.dailyGoal))
    }

    @Test func uncheckingAnnouncesNothing() async throws {
        let store = InMemoryStore(tasks: [today("Done", hour: 9, done: true)])
        let (viewModel, events) = makeViewModel(store: store)
        await viewModel.load()

        viewModel.toggle(try #require(viewModel.data?.tasks.first))

        #expect(events().isEmpty)
    }

    @Test func aFocusSessionAnnouncesItself() async throws {
        let (viewModel, events) = makeViewModel(store: InMemoryStore())
        await viewModel.load()

        viewModel.addFocusTime(1500, taskTitle: "Read")

        let note = try #require(events().first { $0.kind == .focusSession })
        #expect(note.message == "You focused 25 min on Read.")
    }

    @Test func aGrowingStreakIsAnnounced() async throws {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Self.noon)!
        let store = InMemoryStore(sessions: [FocusSession(date: yesterday, seconds: 600)])
        let (viewModel, events) = makeViewModel(store: store)
        await viewModel.load()
        #expect(viewModel.data?.stats.streakDays == 1)

        viewModel.addFocusTime(600)

        #expect(events().contains { $0.kind == .streak && $0.title == "2-day streak!" })
    }

    @Test func withoutAStoreNothingIsAnnounced() async throws {
        let viewModel = HomeViewModel(provider: MockHomeDataProvider(delay: .zero))
        var count = 0
        viewModel.onEvent = { _ in count += 1 }
        await viewModel.load()
        viewModel.toggle(try #require(viewModel.data?.tasks.first))
        #expect(count == 0)
    }

    // MARK: - Notifications

    @Test func notificationsArePersistedAndReloaded() throws {
        let store = InMemoryStore()
        let viewModel = NotificationsViewModel(store: store)
        #expect(viewModel.notifications.isEmpty)

        let note = AppNotification(kind: .taskCompleted, title: "Task completed", message: "x", date: .now)
        viewModel.add(note)
        viewModel.markAsRead(note)

        let reloaded = NotificationsViewModel(store: store)
        #expect(reloaded.notifications.count == 1)
        #expect(reloaded.unreadCount == 0)
    }

    @Test func analyticsViewModelCanBeUpdated() {
        let viewModel = AnalyticsViewModel(data: AnalyticsData(history: [], summaries: [:]))
        #expect(viewModel.summary.tasksDone == 0)
        viewModel.update(AnalyticsData(history: [], summaries: [.week: AnalyticsSummary(tasksDone: 4, tasksPlanned: 5, bestStreakDays: 2, shares: [])]))
        #expect(viewModel.summary.tasksDone == 4)
    }
}
