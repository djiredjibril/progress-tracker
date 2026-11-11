import Foundation
import Testing
@testable import FocusApp

struct DateFormattingTests {
    private let calendar = Calendar.current

    private func date(day: Int, hour: Int, minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 11, day: day, hour: hour, minute: minute))!
    }

    // iOS récent insère une espace fine insécable (U+202F) avant AM/PM : on la normalise pour comparer.
    private func label(_ date: Date, now: Date) -> String {
        date.dueLabel(now: now, calendar: calendar).replacingOccurrences(of: "\u{202F}", with: " ")
    }

    @Test func sameDayIsToday() {
        let now = date(day: 11, hour: 9)
        #expect(label(date(day: 11, hour: 10), now: now) == "Today, 10:00 AM")
        #expect(label(date(day: 11, hour: 18), now: now) == "Today, 6:00 PM")
    }

    @Test func nextDayIsTomorrow() {
        #expect(label(date(day: 12, hour: 9, minute: 30), now: date(day: 11, hour: 9)) == "Tomorrow, 9:30 AM")
    }

    @Test func laterDateShowsMonthAndDay() {
        #expect(label(date(day: 14, hour: 14), now: date(day: 11, hour: 9)) == "Nov 14, 2:00 PM")
    }
}
