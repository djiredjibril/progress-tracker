import Foundation
import Testing
@testable import FocusApp

@MainActor
struct CalendarViewModelTests {
    private let calendar = Calendar.mondayFirst

    private func date(day: Int, hour: Int = 0, minute: Int = 0, month: Int = 11) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day, hour: hour, minute: minute))!
    }

    // Mercredi 11 novembre 2026, 15:20.
    private var now: Date { date(day: 11, hour: 15, minute: 20) }

    private func makeViewModel() -> CalendarViewModel {
        CalendarViewModel(now: { now }, calendar: calendar)
    }

    private var tasks: [TaskItem] {
        [
            TaskItem(title: "Read", dueDate: date(day: 11, hour: 20), category: .learning, durationMinutes: 30),
            TaskItem(title: "Design", dueDate: date(day: 11, hour: 10), isCompleted: true, durationMinutes: 90),
            TaskItem(title: "Workout", dueDate: date(day: 11, hour: 18), category: .health),
            TaskItem(title: "Dentist", dueDate: date(day: 12, hour: 9), category: .personal)
        ]
    }

    // MARK: - semaine

    @Test func weekStartsOnMondayAndContainsToday() {
        let viewModel = makeViewModel()
        let days = viewModel.weekDays.map { calendar.component(.day, from: $0) }
        #expect(days == [9, 10, 11, 12, 13, 14, 15])
        #expect(viewModel.isSelected(now))
        #expect(viewModel.isToday(now))
        #expect(viewModel.monthTitle == "November 2026")
    }

    @Test func weekNavigationMovesByAWeekAndTodayComesBack() {
        let viewModel = makeViewModel()
        viewModel.previousWeek()
        #expect(viewModel.weekDays.map { calendar.component(.day, from: $0) } == [2, 3, 4, 5, 6, 7, 8])
        #expect(!viewModel.isTodaySelected)

        viewModel.nextWeek()
        viewModel.nextWeek()
        #expect(viewModel.weekDays.map { calendar.component(.day, from: $0) } == [16, 17, 18, 19, 20, 21, 22])

        viewModel.goToToday()
        #expect(viewModel.isTodaySelected)
        #expect(viewModel.weekDays.map { calendar.component(.day, from: $0) } == [9, 10, 11, 12, 13, 14, 15])
    }

    @Test func selectingADayChangesTitleAndMonth() {
        let viewModel = makeViewModel()
        viewModel.select(date(day: 12))
        #expect(viewModel.scheduleTitle == "Tomorrow's Schedule")

        viewModel.select(date(day: 10))
        #expect(viewModel.scheduleTitle == "Yesterday's Schedule")

        viewModel.select(date(day: 14))
        #expect(viewModel.scheduleTitle == "Sat, Nov 14")

        viewModel.select(date(day: 2, month: 12))
        #expect(viewModel.monthTitle == "December 2026")
    }

    // MARK: - tâches du jour

    @Test func tasksOfTheDayAreSortedAndFiltered() {
        let viewModel = makeViewModel()
        let today = viewModel.tasks(on: now, in: tasks)
        #expect(today.map(\.title) == ["Design", "Workout", "Read"])
        #expect(viewModel.hasTasks(on: date(day: 12), in: tasks))
        #expect(!viewModel.hasTasks(on: date(day: 13), in: tasks))
    }

    @Test func summaryCountsTasksAndDone() {
        let viewModel = makeViewModel()
        #expect(viewModel.summary(for: viewModel.tasks(on: now, in: tasks)) == "3 tasks · 1 done")
        #expect(viewModel.summary(for: viewModel.tasks(on: date(day: 12), in: tasks)) == "1 task · 0 done")
        #expect(viewModel.summary(for: []) == "No tasks")
    }

    // MARK: - repère « maintenant »

    @Test func nowMarkerIsInsertedBetweenPastAndFutureTasks() {
        let viewModel = makeViewModel()
        let items = viewModel.scheduleItems(for: viewModel.tasks(on: now, in: tasks))

        #expect(items.count == 4)
        guard case .task(let first) = items[0], case .now = items[1], case .task(let second) = items[2] else {
            Issue.record("expected task, now, task, task")
            return
        }
        #expect(first.title == "Design")
        #expect(second.title == "Workout")
    }

    @Test func nowMarkerIsAbsentOnOtherDays() {
        let viewModel = makeViewModel()
        viewModel.select(date(day: 12))
        let items = viewModel.scheduleItems(for: viewModel.tasks(on: date(day: 12), in: tasks))
        #expect(items.count == 1)
    }

    @Test func nowMarkerGoesLastWhenEveryTaskIsPast() {
        let viewModel = makeViewModel()
        let morning = [TaskItem(title: "Early", dueDate: date(day: 11, hour: 8))]
        let items = viewModel.scheduleItems(for: morning)
        guard case .task = items[0], case .now = items[1] else {
            Issue.record("expected task then now")
            return
        }
    }
}

struct TimeLabelTests {
    private func date(hour: Int, minute: Int = 0) -> Date {
        Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: 11, hour: hour, minute: minute))!
    }

    @Test func clockPartsSplitTimeAndPeriod() {
        #expect(date(hour: 10).clockParts().time == "10:00")
        #expect(date(hour: 10).clockParts().period == "AM")
        #expect(date(hour: 13).clockParts().time == "1:00")
        #expect(date(hour: 13).clockParts().period == "PM")
        #expect(date(hour: 15, minute: 20).clockLabel == "3:20 PM")
    }

    @Test func timeRangeShowsPeriodOnceWhenItDoesNotChange() {
        #expect(date(hour: 10).timeRangeLabel(to: date(hour: 11, minute: 30)) == "10:00 – 11:30 AM")
        #expect(date(hour: 18).timeRangeLabel(to: date(hour: 19)) == "6:00 – 7:00 PM")
    }

    @Test func timeRangeShowsBothPeriodsWhenTheyDiffer() {
        #expect(date(hour: 11, minute: 30).timeRangeLabel(to: date(hour: 12, minute: 30)) == "11:30 AM – 12:30 PM")
    }
}
