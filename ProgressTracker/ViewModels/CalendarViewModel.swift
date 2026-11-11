import Foundation
import Observation

// Un élément du planning d'une journée : une tâche, ou le repère « maintenant » inséré entre deux tâches.
// ⚛️ React : un `enum` avec valeurs associées ≈ une union discriminée `{ type: 'task', task } | { type: 'now', date }`.
enum ScheduleItem: Identifiable {
    case task(TaskItem)
    case now(Date)

    var id: String {
        switch self {
        case .task(let task): task.id.uuidString
        case .now: "now"
        }
    }
}

// État de l'écran Calendar : quel jour est sélectionné, quelle semaine est affichée, et les calculs qui en dépendent.
// Les tâches restent dans `HomeViewModel` (source unique) : elles sont passées aux méthodes, pas copiées ici.
@Observable
@MainActor
final class CalendarViewModel {
    private(set) var selectedDate: Date

    private let now: () -> Date
    private let calendar: Calendar

    // ⚛️ voir CONCEPTS.md#protocol : l'heure et le calendrier sont injectables (tests déterministes).
    init(now: @escaping () -> Date = { .now }, calendar: Calendar = .mondayFirst) {
        self.now = now
        self.calendar = calendar
        self.selectedDate = calendar.startOfDay(for: now())
    }

    // MARK: - Semaine

    var today: Date { calendar.startOfDay(for: now()) }

    // Les 7 jours (lundi → dimanche) de la semaine qui contient le jour sélectionné.
    var weekDays: [Date] {
        guard let week = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else { return [selectedDate] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: week.start) }
    }

    var monthTitle: String {
        selectedDate.formatted(.dateTime.month(.wide).year().locale(AppLanguage.current.locale)).capitalized
    }

    func isSelected(_ day: Date) -> Bool { calendar.isDate(day, inSameDayAs: selectedDate) }
    func isToday(_ day: Date) -> Bool { calendar.isDate(day, inSameDayAs: now()) }
    var isTodaySelected: Bool { isToday(selectedDate) }

    func select(_ day: Date) { selectedDate = calendar.startOfDay(for: day) }
    func previousWeek() { shift(days: -7) }
    func nextWeek() { shift(days: 7) }
    func goToToday() { selectedDate = today }

    private func shift(days: Int) {
        selectedDate = calendar.date(byAdding: .day, value: days, to: selectedDate) ?? selectedDate
    }

    // MARK: - Planning du jour sélectionné

    func tasks(on day: Date, in tasks: [TaskItem]) -> [TaskItem] {
        tasks.filter { calendar.isDate($0.dueDate, inSameDayAs: day) }.sorted { $0.dueDate < $1.dueDate }
    }

    func hasTasks(on day: Date, in tasks: [TaskItem]) -> Bool {
        tasks.contains { calendar.isDate($0.dueDate, inSameDayAs: day) }
    }

    // « Today's Schedule », « Tomorrow's Schedule », ou « Thu, Nov 12 » pour un autre jour.
    var scheduleTitle: String {
        if calendar.isDate(selectedDate, inSameDayAs: now()) { return tr("Today's Schedule") }
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now()),
           calendar.isDate(selectedDate, inSameDayAs: tomorrow) { return tr("Tomorrow's Schedule") }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now()),
           calendar.isDate(selectedDate, inSameDayAs: yesterday) { return tr("Yesterday's Schedule") }
        return selectedDate.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day().locale(AppLanguage.current.locale))
    }

    // « 4 tasks · 1 done », « 1 task · 0 done » ou « No tasks ».
    func summary(for dayTasks: [TaskItem]) -> String {
        guard !dayTasks.isEmpty else { return tr("No tasks") }
        let done = dayTasks.filter(\.isCompleted).count
        return tr(dayTasks.count == 1 ? "%lld task · %lld done" : "%lld tasks · %lld done", dayTasks.count, done)
    }

    // Les tâches du jour, avec le repère « maintenant » inséré au bon endroit quand le jour sélectionné est aujourd'hui.
    func scheduleItems(for dayTasks: [TaskItem]) -> [ScheduleItem] {
        var items = dayTasks.sorted { $0.dueDate < $1.dueDate }.map(ScheduleItem.task)
        guard isTodaySelected else { return items }

        let current = now()
        let index = dayTasks.sorted { $0.dueDate < $1.dueDate }.firstIndex { $0.dueDate > current } ?? items.count
        items.insert(.now(current), at: index)
        return items
    }
}
