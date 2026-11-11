import Foundation
import Testing
@testable import FocusApp

// ⚛️ React : `@testable import` ≈ importer le module sous test en accédant aussi à ses éléments internes.
// `@MainActor` : le ViewModel vit sur le thread principal, les tests qui le touchent aussi.
@MainActor
struct HomeViewModelTests {
    // ⚛️ React : ≈ un helper `renderHook(...)`/factory de test. L'heure est injectée pour rendre `greeting` déterministe.
    private func makeViewModel(hour: Int = 9) -> HomeViewModel {
        HomeViewModel(
            provider: MockHomeDataProvider(delay: .zero),
            now: { Self.date(atHour: hour) }
        )
    }

    private static func date(atHour hour: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: .now)!
    }

    // MARK: - load()

    @Test func loadFillsDataAndSetsLoadedState() async {
        let viewModel = makeViewModel()
        #expect(viewModel.state == .idle)
        #expect(viewModel.data == nil)

        await viewModel.load()

        #expect(viewModel.state == .loaded)
        #expect(viewModel.data?.user.firstName == "Alex")
        #expect(viewModel.data?.tasks.count == 3)
    }

    // MARK: - toggle()

    @Test func toggleFlipsCompletionAndAdjustsTasksDone() async throws {
        let viewModel = makeViewModel()
        await viewModel.load()
        let initialData = try #require(viewModel.data)
        let initialDone = initialData.stats.tasksDone
        let pending = try #require(initialData.tasks.first { !$0.isCompleted })

        viewModel.toggle(pending)
        let afterCheck = try #require(viewModel.data)
        #expect(afterCheck.tasks.first { $0.id == pending.id }?.isCompleted == true)
        #expect(afterCheck.stats.tasksDone == initialDone + 1)

        viewModel.toggle(pending)
        let afterUncheck = try #require(viewModel.data)
        #expect(afterUncheck.tasks.first { $0.id == pending.id }?.isCompleted == false)
        #expect(afterUncheck.stats.tasksDone == initialDone)
    }

    // MARK: - addTask()

    @Test func addTaskInsertsSortedByDueDateWithoutChangingTasksDone() async throws {
        let viewModel = makeViewModel()
        await viewModel.load()
        let initial = try #require(viewModel.data)

        // 15:00 : entre « Design » (10:00) et « Workout » (18:00) dans les données mock.
        let afternoon = Self.date(atHour: 15)
        viewModel.addTask(TaskItem(title: "Review PRs", dueDate: afternoon))

        let updated = try #require(viewModel.data)
        #expect(updated.tasks.count == initial.tasks.count + 1)
        #expect(updated.tasks.map(\.title) == ["Design new UI screens", "Review PRs", "Workout", "Read a book"])
        #expect(updated.stats.tasksDone == initial.stats.tasksDone)
    }

    @Test func addTaskIsIgnoredBeforeDataIsLoaded() {
        let viewModel = makeViewModel()
        viewModel.addTask(TaskItem(title: "Too early", dueDate: .now))
        #expect(viewModel.data == nil)
    }

    // MARK: - focus

    @Test func nextTaskIsTheFirstNotCompletedOne() async {
        let viewModel = makeViewModel()
        #expect(viewModel.nextTask == nil)          // rien de chargé

        await viewModel.load()
        #expect(viewModel.nextTask?.title == "Workout")      // « Design » est déjà coché
    }

    @Test func addFocusTimeIncreasesTheTotal() async throws {
        let viewModel = makeViewModel()
        await viewModel.load()
        let before = try #require(viewModel.data).stats.focusTime

        viewModel.addFocusTime(25 * 60)
        #expect(viewModel.data?.stats.focusTime == before + 25 * 60)

        viewModel.addFocusTime(-10)                 // une valeur négative est ignorée
        #expect(viewModel.data?.stats.focusTime == before + 25 * 60)
    }

    // MARK: - greeting

    // ⚛️ React : ≈ `test.each([[8, '…'], …])` de Jest : un test exécuté pour chaque jeu d'arguments.
    @Test(arguments: [
        (8, "Good Morning"),
        (14, "Good Afternoon"),
        (21, "Good Evening")
    ])
    func greetingDependsOnHour(hour: Int, expected: String) {
        #expect(makeViewModel(hour: hour).greeting == expected)
    }

    // MARK: - échecs et refresh

    @Test func loadFailureSetsFailedState() async {
        let viewModel = HomeViewModel(provider: FlakyProvider(shouldFail: true))
        await viewModel.load()

        guard case .failed = viewModel.state else {
            Issue.record("expected .failed, got \(viewModel.state)")
            return
        }
        #expect(viewModel.data == nil)
    }

    @Test func refreshFailureKeepsExistingData() async {
        let provider = FlakyProvider()
        let viewModel = HomeViewModel(provider: provider)
        await viewModel.load()

        provider.shouldFail = true
        await viewModel.refresh()

        #expect(viewModel.state == .loaded)
        #expect(viewModel.data != nil)
    }

    @Test func refreshReplacesDataWithServerValues() async throws {
        let viewModel = makeViewModel()
        await viewModel.load()
        let initialDone = try #require(viewModel.data).stats.tasksDone
        let pending = try #require(viewModel.data?.tasks.first { !$0.isCompleted })

        viewModel.toggle(pending)
        #expect(viewModel.data?.stats.tasksDone == initialDone + 1)

        await viewModel.refresh()
        #expect(viewModel.data?.stats.tasksDone == initialDone)
    }

    // MARK: - UserStats

    @Test func focusTimeIsSplitIntoHoursAndMinutes() {
        let stats = UserStats(tasksDone: 0, focusTime: 23_040, streakDays: 0)
        #expect(stats.focusHours == 6)
        #expect(stats.focusMinutes == 24)
    }
}

// ⚛️ React : ≈ un `jest.fn()` / faux service dont on contrôle le comportement : il réussit, puis on peut le faire échouer.
private final class FlakyProvider: HomeDataProviding {
    struct Failure: Error {}
    var shouldFail: Bool

    init(shouldFail: Bool = false) {
        self.shouldFail = shouldFail
    }

    func fetchHomeData() async throws -> HomeData {
        if shouldFail { throw Failure() }
        return MockData.homeData
    }
}
