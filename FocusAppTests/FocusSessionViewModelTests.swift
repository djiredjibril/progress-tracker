import Foundation
import Testing
@testable import FocusApp

// ⚛️ React : ≈ `jest.useFakeTimers()` : on contrôle l'horloge à la main. Le minuteur ne dépend que de `now`, donc on
// « avance le temps » en modifiant `clock.current`, puis on appelle `tick()` : aucun test n'attend pour de vrai.
private final class TestClock {
    var current = Date(timeIntervalSince1970: 1_800_000_000)
    func advance(_ seconds: TimeInterval) { current = current.addingTimeInterval(seconds) }
}

@MainActor
struct FocusSessionViewModelTests {
    private let clock = TestClock()

    private func makeViewModel(
        config: FocusSessionConfig = FocusSessionConfig(),
        base: TimeInterval = 0,
        onLogged: @escaping (TimeInterval) -> Void = { _ in }
    ) -> FocusSessionViewModel {
        FocusSessionViewModel(
            task: nil,
            config: config,
            baseFocusToday: base,
            now: { [clock] in clock.current },
            onFocusLogged: onLogged
        )
    }

    // MARK: - état initial et décompte

    @Test func startsIdleWithFullFocusDuration() {
        let viewModel = makeViewModel()
        #expect(viewModel.runState == .idle)
        #expect(viewModel.phase == .focus)
        #expect(viewModel.timeText == "25:00")
        #expect(viewModel.progress == 0)
        #expect(viewModel.sessionIndex == 1)
    }

    @Test func countsDownFromTheClock() {
        let viewModel = makeViewModel()
        viewModel.start()
        clock.advance(10 * 60)
        viewModel.tick()

        #expect(viewModel.timeText == "15:00")
        #expect(viewModel.progress == 0.4)
        #expect(viewModel.durationLabel == "of 25 min")
    }

    @Test func timeTextRoundsUp() {
        let viewModel = makeViewModel()
        viewModel.start()
        clock.advance(25 * 60 - 14.2)          // 14,2 s restantes
        viewModel.tick()
        #expect(viewModel.timeText == "0:15")
    }

    // MARK: - pause

    @Test func pauseFreezesTheTimerAndResumeContinues() {
        let viewModel = makeViewModel()
        viewModel.start()
        clock.advance(60)
        viewModel.pause()
        #expect(viewModel.runState == .paused)
        #expect(viewModel.timeText == "24:00")

        clock.advance(5 * 60)                   // temps passé en pause : ne compte pas
        viewModel.tick()
        #expect(viewModel.timeText == "24:00")

        viewModel.toggle()                      // reprend
        clock.advance(60)
        viewModel.tick()
        #expect(viewModel.runState == .running)
        #expect(viewModel.timeText == "23:00")
    }

    // MARK: - enchaînement des phases

    @Test func finishingFocusLogsItAndStartsTheBreakAutomatically() {
        var logged: [TimeInterval] = []
        let viewModel = makeViewModel { logged.append($0) }
        viewModel.start()
        clock.advance(25 * 60)
        viewModel.tick()

        #expect(logged == [25 * 60])
        #expect(viewModel.phase == .rest)
        #expect(viewModel.runState == .running)
        #expect(viewModel.timeText == "5:00")
        #expect(viewModel.durationLabel == "of 5 min")
        #expect(viewModel.nextLabel == "Next focus")
    }

    @Test func finishingTheBreakWaitsForTheNextFocus() {
        let viewModel = makeViewModel()
        viewModel.start()
        clock.advance(25 * 60); viewModel.tick()        // fin du focus 1
        clock.advance(5 * 60); viewModel.tick()         // fin de la pause

        #expect(viewModel.phase == .focus)
        #expect(viewModel.runState == .idle)
        #expect(viewModel.sessionIndex == 2)
        #expect(viewModel.timeText == "25:00")
    }

    @Test func lastFocusSessionFinishesTheSeries() {
        let config = FocusSessionConfig(focusDuration: 60, breakDuration: 30, sessionCount: 2)
        let viewModel = makeViewModel(config: config)

        viewModel.start()
        clock.advance(60); viewModel.tick()             // focus 1
        clock.advance(30); viewModel.tick()             // pause
        viewModel.start()
        clock.advance(60); viewModel.tick()             // focus 2 (dernier)

        #expect(viewModel.runState == .finished)
        #expect(viewModel.phaseLabel == "Complete")
        #expect(viewModel.progress == 1)
        #expect(viewModel.loggedFocusSeconds == 120)
    }

    // MARK: - skip et reset

    @Test func skipDuringFocusLogsOnlyTheElapsedTime() {
        var logged: [TimeInterval] = []
        let viewModel = makeViewModel { logged.append($0) }
        viewModel.start()
        clock.advance(5 * 60)
        viewModel.skip()

        #expect(logged == [5 * 60])
        #expect(viewModel.phase == .rest)
        #expect(viewModel.runState == .running)
    }

    @Test func skipDuringBreakLogsNothingAndMovesToNextFocus() {
        var logged: [TimeInterval] = []
        let viewModel = makeViewModel { logged.append($0) }
        viewModel.start()
        clock.advance(25 * 60); viewModel.tick()
        logged.removeAll()

        viewModel.skip()

        #expect(logged.isEmpty)
        #expect(viewModel.phase == .focus)
        #expect(viewModel.sessionIndex == 2)
    }

    @Test func resetRestoresDurationWithoutLogging() {
        var logged: [TimeInterval] = []
        let viewModel = makeViewModel { logged.append($0) }
        viewModel.start()
        clock.advance(10 * 60)
        viewModel.reset()

        #expect(viewModel.runState == .idle)
        #expect(viewModel.timeText == "25:00")
        #expect(logged.isEmpty)
    }

    @Test func leavingLogsTheElapsedFocusAndStops() {
        var logged: [TimeInterval] = []
        let viewModel = makeViewModel { logged.append($0) }
        viewModel.start()
        clock.advance(3 * 60)
        viewModel.leave()

        #expect(logged == [3 * 60])
        #expect(viewModel.runState == .idle)
    }

    // MARK: - indicateurs

    @Test func sessionDotsFollowTheProgress() {
        let viewModel = makeViewModel()
        #expect((1...4).map(viewModel.dot(at:)) == [.current, .upcoming, .upcoming, .upcoming])

        viewModel.start()
        clock.advance(25 * 60); viewModel.tick()        // pause après la session 1
        #expect((1...4).map(viewModel.dot(at:)) == [.done, .upcoming, .upcoming, .upcoming])

        clock.advance(5 * 60); viewModel.tick()         // session 2 en attente
        #expect((1...4).map(viewModel.dot(at:)) == [.done, .current, .upcoming, .upcoming])
    }

    @Test func focusTodayAddsBaseLoggedAndCurrent() {
        let viewModel = makeViewModel(base: 3600)
        #expect(viewModel.focusToday == 3600)

        viewModel.start()
        clock.advance(10 * 60)
        viewModel.tick()
        #expect(viewModel.focusToday == 3600 + 10 * 60)
    }
}

struct DurationLabelTests {
    @Test(arguments: [
        (0.0, "0m"),
        (45 * 60.0, "45m"),
        (3600.0, "1h 0m"),
        (23_040.0, "6h 24m")
    ])
    func shortDurationLabel(seconds: TimeInterval, expected: String) {
        #expect(seconds.shortDurationLabel == expected)
    }
}
