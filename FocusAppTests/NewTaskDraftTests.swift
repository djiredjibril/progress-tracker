import Foundation
import Testing
@testable import FocusApp

struct NewTaskDraftTests {
    private let calendar = Calendar.current

    private func date(day: Int, hour: Int, minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 11, day: day, hour: hour, minute: minute))!
    }

    // MARK: - validation

    @Test func emptyOrBlankTitleIsInvalid() {
        var draft = NewTaskDraft()
        #expect(!draft.isValid)

        draft.title = "   \n  "
        #expect(!draft.isValid)

        draft.title = "Buy milk"
        #expect(draft.isValid)
    }

    // MARK: - valeurs par défaut

    @Test func defaultsToNextFullHour() {
        let draft = NewTaskDraft(now: date(day: 11, hour: 14, minute: 20), calendar: calendar)
        #expect(draft.dueDate(calendar: calendar) == date(day: 11, hour: 15))
        #expect(draft.durationMinutes == 60)
        #expect(draft.category == .work)
        #expect(draft.priority == .medium)
        #expect(draft.remindsBeforeStart)
    }

    @Test func defaultsRollOverToTomorrowAfterMidnight() {
        let draft = NewTaskDraft(now: date(day: 11, hour: 23, minute: 30), calendar: calendar)
        #expect(draft.dueDate(calendar: calendar) == date(day: 12, hour: 0))
    }

    // MARK: - makeTask()

    @Test func makeTaskCombinesDayAndTime() {
        var draft = NewTaskDraft(now: date(day: 11, hour: 9), calendar: calendar)
        draft.title = "  Dentist  "
        draft.day = date(day: 14, hour: 3)          // l'heure du jour est ignorée
        draft.time = date(day: 1, hour: 18, minute: 45)   // le jour de l'heure est ignoré
        draft.durationMinutes = 30
        draft.category = .health
        draft.priority = .high

        let task = draft.makeTask(calendar: calendar)

        #expect(task.title == "Dentist")
        #expect(task.dueDate == date(day: 14, hour: 18, minute: 45))
        #expect(task.durationMinutes == 30)
        #expect(task.category == .health)
        #expect(task.priority == .high)
        #expect(!task.isCompleted)
    }

    @Test func reminderDependsOnToggle() {
        var draft = NewTaskDraft()
        draft.title = "Call mom"
        #expect(draft.makeTask().reminderMinutes == 15)

        draft.remindsBeforeStart = false
        #expect(draft.makeTask().reminderMinutes == nil)
    }

    // MARK: - édition

    @Test func editingPrefillsTheFormAndKeepsIdentityAndDoneState() {
        let original = TaskItem(
            title: "Dentist",
            dueDate: date(day: 14, hour: 9, minute: 30),
            isCompleted: true,
            category: .health,
            priority: .high,
            durationMinutes: 45,
            reminderMinutes: nil
        )
        var draft = NewTaskDraft(editing: original)

        #expect(draft.isEditing)
        #expect(draft.title == "Dentist")
        #expect(draft.category == .health)
        #expect(draft.priority == .high)
        #expect(draft.durationMinutes == 45)
        #expect(!draft.remindsBeforeStart)
        #expect(draft.dueDate(calendar: calendar) == original.dueDate)

        draft.title = "Dentist (moved)"
        draft.time = date(day: 1, hour: 11)
        let saved = draft.makeTask(calendar: calendar)

        #expect(saved.id == original.id)                  // même tâche, pas une copie
        #expect(saved.isCompleted)                        // l'état « fait » est conservé
        #expect(saved.title == "Dentist (moved)")
        #expect(saved.dueDate == date(day: 14, hour: 11))
    }

    @Test func aNewDraftIsNotEditing() {
        #expect(!NewTaskDraft().isEditing)
    }

    // MARK: - libellés de durée

    @Test(arguments: [
        (15, "15 min"),
        (45, "45 min"),
        (60, "1 h"),
        (90, "1 h 30"),
        (120, "2 h")
    ])
    func durationLabels(minutes: Int, expected: String) {
        #expect(NewTaskDraft.label(forMinutes: minutes) == expected)
    }

    @Test func everyDurationOptionHasALabel() {
        for minutes in NewTaskDraft.durationOptions {
            #expect(!NewTaskDraft.label(forMinutes: minutes).isEmpty)
        }
    }
}
