import Foundation
import Observation

// Agrège l'historique de focus pour la période choisie. L'heure et le calendrier sont injectables (tests déterministes).
// Le temps de focus d'AUJOURD'HUI n'est pas dans l'historique : il est fourni à chaque appel (`todayFocus`), car il vient de
// Home et change quand on termine une session de focus.
@Observable
@MainActor
final class AnalyticsViewModel {
    // ⚛️ voir CONCEPTS.md#binding : `period` est modifié par le contrôle segmenté (via `@Bindable` dans la vue).
    var period: AnalyticsPeriod = .week

    private var data: AnalyticsData
    private var focusByDay: [Date: TimeInterval]
    private let now: () -> Date
    private let calendar: Calendar

    init(data: AnalyticsData = MockData.analytics, now: @escaping () -> Date = { .now }, calendar: Calendar = .mondayFirst) {
        self.data = data
        self.now = now
        self.calendar = calendar
        // Un dictionnaire par jour : retrouver une journée est immédiat (≈ un `Map` indexé par date).
        self.focusByDay = Self.index(data.history, calendar: calendar)
    }

    // Remplace les données (l'historique change quand on coche une tâche ou qu'on termine une session) : `RootView` l'appelle
    // à l'ouverture de l'onglet. ⚛️ React : ≈ `queryClient.invalidateQueries` puis le re-render avec les nouvelles données.
    func update(_ data: AnalyticsData) {
        self.data = data
        focusByDay = Self.index(data.history, calendar: calendar)
    }

    private static func index(_ history: [FocusDay], calendar: Calendar) -> [Date: TimeInterval] {
        Dictionary(history.map { (calendar.startOfDay(for: $0.date), $0.seconds) }, uniquingKeysWith: +)
    }

    var summary: AnalyticsSummary { data.summaries[period] ?? .empty }

    func totalFocus(todayFocus: TimeInterval) -> TimeInterval {
        bars(todayFocus: todayFocus).reduce(0) { $0 + $1.seconds }
    }

    // MARK: - Barres

    func bars(todayFocus: TimeInterval) -> [FocusBar] {
        switch period {
        case .week: weekBars(todayFocus)
        case .month: monthBars(todayFocus)
        case .year: yearBars(todayFocus)
        }
    }

    // Temps de focus d'un jour : l'historique pour le passé, `todayFocus` pour aujourd'hui, 0 pour le futur.
    private func seconds(on day: Date, todayFocus: TimeInterval) -> TimeInterval {
        let start = calendar.startOfDay(for: day)
        let today = calendar.startOfDay(for: now())
        if start == today { return todayFocus }
        if start > today { return 0 }
        return focusByDay[start] ?? 0
    }

    private var today: Date { calendar.startOfDay(for: now()) }
    private func format(_ date: Date, _ style: Date.FormatStyle) -> String {
        date.formatted(style.locale(AppLanguage.current.locale))
    }

    // Semaine : 7 barres, lundi → dimanche.
    private func weekBars(_ todayFocus: TimeInterval) -> [FocusBar] {
        guard let week = calendar.dateInterval(of: .weekOfYear, for: today) else { return [] }
        return (0..<7).compactMap { index in
            guard let day = calendar.date(byAdding: .day, value: index, to: week.start) else { return nil }
            return FocusBar(
                id: index,
                label: format(day, .dateTime.weekday(.narrow)),
                name: format(day, .dateTime.weekday(.wide)),
                seconds: seconds(on: day, todayFocus: todayFocus),
                isCurrent: day == today,
                isFuture: day > today
            )
        }
    }

    // Mois : des paquets de 7 jours (1–7, 8–14, …), notés W1, W2…
    private func monthBars(_ todayFocus: TimeInterval) -> [FocusBar] {
        guard let month = calendar.dateInterval(of: .month, for: today),
              let dayCount = calendar.range(of: .day, in: .month, for: today)?.count else { return [] }

        return stride(from: 1, through: dayCount, by: 7).enumerated().compactMap { index, firstDay in
            let lastDay = min(firstDay + 6, dayCount)
            let days = (firstDay...lastDay).compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: month.start) }
            guard let first = days.first else { return nil }
            let rangeName = "\(format(first, .dateTime.month(.abbreviated))) \(firstDay)–\(lastDay)"
            return FocusBar(
                id: index,
                label: tr("W%lld", index + 1),
                name: rangeName,
                seconds: days.reduce(0) { $0 + seconds(on: $1, todayFocus: todayFocus) },
                isCurrent: days.contains(today),
                isFuture: first > today
            )
        }
    }

    // Année : 12 barres, une par mois.
    private func yearBars(_ todayFocus: TimeInterval) -> [FocusBar] {
        let year = calendar.component(.year, from: today)
        return (1...12).compactMap { monthNumber in
            guard let start = calendar.date(from: DateComponents(year: year, month: monthNumber)),
                  let dayCount = calendar.range(of: .day, in: .month, for: start)?.count else { return nil }
            let total = (0..<dayCount).reduce(0.0) { sum, offset in
                guard let day = calendar.date(byAdding: .day, value: offset, to: start) else { return sum }
                return sum + seconds(on: day, todayFocus: todayFocus)
            }
            return FocusBar(
                id: monthNumber - 1,
                label: format(start, .dateTime.month(.narrow)),
                name: format(start, .dateTime.month(.wide)),
                seconds: total,
                isCurrent: calendar.component(.month, from: today) == monthNumber,
                isFuture: start > today
            )
        }
    }
}
