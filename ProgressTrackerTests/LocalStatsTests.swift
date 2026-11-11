import Foundation
import Testing
@testable import ProgressTracker

struct LocalStatsTests {
    private var calendar: Calendar { .mondayFirst }

    private func date(day: Int, hour: Int = 10, month: Int = 11) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour))!
    }

    private var now: Date { date(day: 11, hour: 14) }     // mercredi 11 novembre 2026

    private func task(_ title: String, day: Int, done: Bool, category: TaskCategory = .work, minutes: Int = 60) -> TaskItem {
        TaskItem(title: title, dueDate: date(day: day), isCompleted: done, category: category, durationMinutes: minutes)
    }

    // MARK: - Home

    @Test func emptyDataGivesZeroEverywhere() {
        let stats = LocalStats.stats(tasks: [], sessions: [], now: now, calendar: calendar)
        #expect(stats.tasksDone == 0)
        #expect(stats.focusTime == 0)
        #expect(stats.streakDays == 0)
        #expect(LocalStats.goal(tasks: [], now: now, calendar: calendar).progress == 0)
    }

    @Test func statsOnlyCountToday() {
        let tasks = [task("A", day: 11, done: true), task("B", day: 11, done: false), task("C", day: 10, done: true)]
        let sessions = [FocusSession(date: date(day: 11), seconds: 1500), FocusSession(date: date(day: 11, hour: 16), seconds: 300),
                        FocusSession(date: date(day: 10), seconds: 9000)]
        let stats = LocalStats.stats(tasks: tasks, sessions: sessions, now: now, calendar: calendar)
        #expect(stats.tasksDone == 1)
        #expect(stats.focusTime == 1800)
    }

    @Test func goalFollowsTheShareOfTodayTasksDone() {
        func goal(_ tasks: [TaskItem]) -> DailyGoal { LocalStats.goal(tasks: tasks, now: now, calendar: calendar) }
        #expect(goal([]).title == "Plan your day")
        #expect(goal([task("A", day: 11, done: false)]).title == "Let's Go!")
        let half = goal([task("A", day: 11, done: true), task("B", day: 11, done: false)])
        #expect(half.progressPercent == 50)
        #expect(half.title == "Keep Going!")
        let all = goal([task("A", day: 11, done: true)])
        #expect(all.progress == 1)
        #expect(all.title == "Goal Reached!")
        // Une tâche d'un autre jour ne compte pas.
        #expect(goal([task("A", day: 12, done: false)]).title == "Plan your day")
    }

    // MARK: - Séries

    @Test func streakCountsConsecutiveActiveDaysUpToToday() {
        let days: Set = [date(day: 11), date(day: 10), date(day: 9), date(day: 7)]
            .reduce(into: Set<Date>()) { $0.insert(calendar.startOfDay(for: $1)) }
        #expect(LocalStats.streak(activeDays: days, now: now, calendar: calendar) == 3)
    }

    @Test func streakSurvivesAnInactiveToday() {
        // Rien aujourd'hui, mais hier et avant-hier : la série vaut 2 (elle ne se brise qu'à la fin de la journée).
        let days = Set([date(day: 10), date(day: 9)].map { calendar.startOfDay(for: $0) })
        #expect(LocalStats.streak(activeDays: days, now: now, calendar: calendar) == 2)
    }

    @Test func streakIsBrokenAfterAMissedDay() {
        let days = Set([date(day: 9), date(day: 8)].map { calendar.startOfDay(for: $0) })
        #expect(LocalStats.streak(activeDays: days, now: now, calendar: calendar) == 0)
    }

    @Test func bestStreakIsTheLongestRun() {
        let days = Set([1, 2, 3, 4, 8, 9].map { calendar.startOfDay(for: date(day: $0)) })
        #expect(LocalStats.bestStreak(activeDays: days, calendar: calendar) == 4)
        #expect(LocalStats.bestStreak(activeDays: [], calendar: calendar) == 0)
    }

    @Test func aDayIsActiveWithADoneTaskOrAFocusSession() {
        let tasks = [task("Done", day: 5, done: true), task("Todo", day: 6, done: false)]
        let sessions = [FocusSession(date: date(day: 7), seconds: 600), FocusSession(date: date(day: 8), seconds: 0)]
        let days = LocalStats.activeDays(tasks: tasks, sessions: sessions, calendar: calendar)
        #expect(days == Set([5, 7].map { calendar.startOfDay(for: date(day: $0)) }))
    }

    // MARK: - Analytics

    @Test func analyticsSumsSessionsPerDayAndSummarisesThePeriod() {
        let tasks = [
            task("A", day: 9, done: true, category: .work, minutes: 90),
            task("B", day: 10, done: true, category: .health, minutes: 30),
            task("C", day: 11, done: false),
            task("D", day: 20, done: true, category: .work, minutes: 60)      // même mois, autre semaine
        ]
        let sessions = [FocusSession(date: date(day: 9), seconds: 600), FocusSession(date: date(day: 9, hour: 15), seconds: 900)]
        let data = LocalStats.analytics(tasks: tasks, sessions: sessions, now: now, calendar: calendar)

        #expect(data.history.count == 1)
        #expect(data.history.first?.seconds == 1500)

        let week = data.summaries[.week]
        #expect(week?.tasksDone == 2)
        #expect(week?.tasksPlanned == 3)
        // 90 min de travail et 30 min de santé : 75 % / 25 %.
        #expect(week?.shares.map(\.percent) == [75, 25])
        #expect(week?.shares.first?.category == .work)

        let month = data.summaries[.month]
        #expect(month?.tasksDone == 3)
        #expect(month?.tasksPlanned == 4)
    }

    @Test func analyticsWithoutDataHasNoShares() {
        let data = LocalStats.analytics(tasks: [], sessions: [], now: now, calendar: calendar)
        #expect(data.history.isEmpty)
        #expect(data.summaries[.week]?.shares.isEmpty == true)
        #expect(data.summaries[.week]?.tasksProgress == 0)
    }
}
