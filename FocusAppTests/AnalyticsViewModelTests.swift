import Foundation
import Testing
@testable import FocusApp

@MainActor
struct AnalyticsViewModelTests {
    private let calendar = Calendar.mondayFirst

    private func date(day: Int, month: Int = 11, hour: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour))!
    }

    // Mercredi 11 novembre 2026, 15:00. L'historique vaut « numéro du jour × 60 s » pour chaque jour passé de l'année.
    private var now: Date { date(day: 11, hour: 15) }

    // Somme de l'historique mock pour des jours du mois : chaque jour vaut « numéro du jour × 60 s ».
    private func historySeconds(_ days: ClosedRange<Int>) -> TimeInterval {
        var total: TimeInterval = 0
        for day in days { total += TimeInterval(day) * 60 }
        return total
    }

    private func makeViewModel(period: AnalyticsPeriod = .week) -> AnalyticsViewModel {
        var history: [FocusDay] = []
        var day = date(day: 1, month: 1)
        while day < date(day: 11) {
            history.append(FocusDay(date: day, seconds: TimeInterval(calendar.component(.day, from: day)) * 60))
            day = calendar.date(byAdding: .day, value: 1, to: day)!
        }
        let viewModel = AnalyticsViewModel(
            data: AnalyticsData(
                history: history,
                summaries: [.week: AnalyticsSummary(tasksDone: 9, tasksPlanned: 12, bestStreakDays: 12, shares: [])]
            ),
            now: { now },
            calendar: calendar
        )
        viewModel.period = period
        return viewModel
    }

    // MARK: - semaine

    @Test func weekHasSevenBarsMondayToSunday() {
        let bars = makeViewModel().bars(todayFocus: 3600)
        #expect(bars.map(\.label) == ["M", "T", "W", "T", "F", "S", "S"])
        #expect(bars.map(\.name).first == "Monday")
    }

    @Test func weekUsesHistoryForPastTodayFocusForTodayAndZeroForFuture() {
        let bars = makeViewModel().bars(todayFocus: 3600)
        #expect(bars[0].seconds == 9 * 60)            // lundi 9
        #expect(bars[1].seconds == 10 * 60)           // mardi 10
        #expect(bars[2].seconds == 3600)              // aujourd'hui : la valeur fournie
        #expect(bars[3...].allSatisfy { $0.seconds == 0 })
    }

    @Test func weekFlagsCurrentAndFutureBars() {
        let bars = makeViewModel().bars(todayFocus: 0)
        #expect(bars.map(\.isCurrent) == [false, false, true, false, false, false, false])
        #expect(bars.map(\.isFuture) == [false, false, false, true, true, true, true])
    }

    @Test func weekTotalAddsEveryBar() {
        #expect(makeViewModel().totalFocus(todayFocus: 3600) == 9 * 60 + 10 * 60 + 3600)
    }

    // MARK: - mois

    @Test func monthGroupsDaysBySevenAndSumsThem() {
        let viewModel = makeViewModel(period: .month)
        let bars = viewModel.bars(todayFocus: 3600)

        #expect(bars.map(\.label) == ["W1", "W2", "W3", "W4", "W5"])            // novembre : 30 jours
        #expect(bars[0].seconds == historySeconds(1...7))
        #expect(bars[1].seconds == historySeconds(8...10) + 3600)               // 8 à 10 passés + aujourd'hui (11)
        #expect(bars[1].isCurrent)
        #expect(bars[2...].allSatisfy { $0.isFuture && $0.seconds == 0 })
        #expect(bars[1].name == "Nov 8–14")
    }

    // MARK: - année

    @Test func yearHasTwelveMonthsAndTheCurrentOneIncludesToday() {
        let viewModel = makeViewModel(period: .year)
        let bars = viewModel.bars(todayFocus: 3600)

        #expect(bars.count == 12)
        #expect(Array(bars.map(\.label).prefix(3)) == ["J", "F", "M"])
        #expect(bars[10].isCurrent)                                              // novembre
        #expect(bars[10].seconds == historySeconds(1...10) + 3600)
        #expect(bars[11].isFuture && bars[11].seconds == 0)
        // Janvier : 31 jours à « numéro du jour × 60 s ».
        #expect(bars[0].seconds == historySeconds(1...31))
    }

    // MARK: - résumé

    @Test func summaryFollowsThePeriod() {
        let viewModel = makeViewModel()
        #expect(viewModel.summary.tasksDone == 9)
        #expect(viewModel.summary.tasksProgress == 0.75)

        viewModel.period = .year                      // pas de résumé pour cette période dans ce jeu de test
        #expect(viewModel.summary.tasksDone == 0)
        #expect(viewModel.summary.tasksProgress == 0)
    }

    @Test func periodTitles() {
        #expect(AnalyticsPeriod.allCases.map(\.title) == ["Week", "Month", "Year"])
        #expect(AnalyticsPeriod.week.focusTitle == "Focus time this week")
    }
}
