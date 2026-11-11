import Foundation

// Toutes les statistiques sont CALCULÉES à partir des tâches et des sessions de focus (D-047) : des fonctions pures,
// sans état ni stockage, donc testables avec de simples tableaux.
// ⚛️ React : ≈ des *selectors* (Reselect) : `selectStreak(state)`. On ne stocke jamais une valeur dérivée, ce qui évite
// qu'elle se désynchronise des données (le piège classique du `useState` qu'on oublie de mettre à jour).
enum LocalStats {
    // MARK: - Home

    // Tâches faites aujourd'hui, temps de focus d'aujourd'hui, série en cours.
    static func stats(tasks: [TaskItem], sessions: [FocusSession], now: Date, calendar: Calendar = .current) -> UserStats {
        let today = tasks.filter { calendar.isDate($0.dueDate, inSameDayAs: now) }
        let focus = sessions.filter { calendar.isDate($0.date, inSameDayAs: now) }.reduce(0) { $0 + $1.seconds }
        return UserStats(
            tasksDone: today.filter(\.isCompleted).count,
            focusTime: focus,
            streakDays: streak(activeDays: activeDays(tasks: tasks, sessions: sessions, calendar: calendar), now: now, calendar: calendar)
        )
    }

    // L'objectif du jour : la part des tâches d'aujourd'hui qui sont faites.
    static func goal(tasks: [TaskItem], now: Date, calendar: Calendar = .current) -> DailyGoal {
        let today = tasks.filter { calendar.isDate($0.dueDate, inSameDayAs: now) }
        guard !today.isEmpty else { return DailyGoal(title: tr("Plan your day"), progress: 0) }
        let progress = Double(today.filter(\.isCompleted).count) / Double(today.count)
        switch progress {
        case 0: return DailyGoal(title: tr("Let's Go!"), progress: 0)
        case 1: return DailyGoal(title: tr("Goal Reached!"), progress: 1)
        default: return DailyGoal(title: tr("Keep Going!"), progress: progress)
        }
    }

    // MARK: - Séries

    // Un jour est « actif » s'il compte une tâche faite (à son échéance) ou une session de focus.
    static func activeDays(tasks: [TaskItem], sessions: [FocusSession], calendar: Calendar = .current) -> Set<Date> {
        var days = Set(tasks.filter(\.isCompleted).map { calendar.startOfDay(for: $0.dueDate) })
        days.formUnion(sessions.filter { $0.seconds > 0 }.map { calendar.startOfDay(for: $0.date) })
        return days
    }

    // Jours actifs consécutifs jusqu'à aujourd'hui. Si aujourd'hui n'est pas (encore) actif, la série d'hier reste vivante :
    // elle ne se brise qu'à la fin d'une journée vide.
    static func streak(activeDays: Set<Date>, now: Date, calendar: Calendar = .current) -> Int {
        var day = calendar.startOfDay(for: now)
        if !activeDays.contains(day), let yesterday = calendar.date(byAdding: .day, value: -1, to: day) {
            day = yesterday
        }
        var count = 0
        while activeDays.contains(day) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return count
    }

    // La plus longue série de jours actifs consécutifs de tout l'historique.
    static func bestStreak(activeDays: Set<Date>, calendar: Calendar = .current) -> Int {
        var best = 0
        var run = 0
        var previous: Date?
        for day in activeDays.sorted() {
            if let previous, calendar.date(byAdding: .day, value: 1, to: previous) == day {
                run += 1
            } else {
                run = 1
            }
            best = max(best, run)
            previous = day
        }
        return best
    }

    // MARK: - Analytics

    static func analytics(tasks: [TaskItem], sessions: [FocusSession], now: Date, calendar: Calendar = .mondayFirst) -> AnalyticsData {
        // Une ligne par jour : on additionne les sessions d'un même jour.
        let byDay = Dictionary(grouping: sessions) { calendar.startOfDay(for: $0.date) }
        let history = byDay
            .map { FocusDay(date: $0.key, seconds: $0.value.reduce(0) { $0 + $1.seconds }) }
            .sorted { $0.date < $1.date }

        let best = bestStreak(activeDays: activeDays(tasks: tasks, sessions: sessions, calendar: calendar), calendar: calendar)
        var summaries: [AnalyticsPeriod: AnalyticsSummary] = [:]
        for period in AnalyticsPeriod.allCases {
            summaries[period] = summary(for: period, tasks: tasks, bestStreak: best, now: now, calendar: calendar)
        }
        return AnalyticsData(history: history, summaries: summaries)
    }

    private static func summary(
        for period: AnalyticsPeriod, tasks: [TaskItem], bestStreak: Int, now: Date, calendar: Calendar
    ) -> AnalyticsSummary {
        let component: Calendar.Component = switch period {
        case .week: .weekOfYear
        case .month: .month
        case .year: .year
        }
        guard let interval = calendar.dateInterval(of: component, for: now) else { return .empty }
        let inPeriod = tasks.filter { interval.contains($0.dueDate) }
        let done = inPeriod.filter(\.isCompleted)

        // Répartition : le temps des tâches faites, par catégorie (en %), de la plus grosse à la plus petite.
        let minutes = Dictionary(grouping: done, by: \.category).mapValues { $0.reduce(0) { $0 + $1.durationMinutes } }
        let total = minutes.values.reduce(0, +)
        let shares = total == 0 ? [] : minutes
            .map { CategoryShare(category: $0.key, percent: Int((Double($0.value) / Double(total) * 100).rounded())) }
            .sorted { ($0.percent, $1.category.rawValue) > ($1.percent, $0.category.rawValue) }

        return AnalyticsSummary(tasksDone: done.count, tasksPlanned: inPeriod.count, bestStreakDays: bestStreak, shares: shares)
    }
}
