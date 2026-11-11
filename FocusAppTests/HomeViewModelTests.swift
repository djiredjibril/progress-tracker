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

    // MARK: - UserStats

    @Test func focusTimeIsSplitIntoHoursAndMinutes() {
        let stats = UserStats(tasksDone: 0, focusTime: 23_040, streakDays: 0)
        #expect(stats.focusHours == 6)
        #expect(stats.focusMinutes == 24)
    }
}
