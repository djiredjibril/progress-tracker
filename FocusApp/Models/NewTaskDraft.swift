import Foundation

// Brouillon du formulaire « New Task » : l'état LOCAL de l'écran (≈ le `useState` d'un formulaire React), séparé du
// ViewModel. On ne crée une vraie `TaskItem` qu'à la validation, via `makeTask()`. Toute la logique (validation,
// combinaison jour + heure) vit ici, dans une `struct` pure : elle se teste sans aucune vue.
struct NewTaskDraft {
    // Durées proposées dans le menu, en minutes.
    static let durationOptions = [15, 30, 45, 60, 90, 120]

    var title = ""
    var day: Date               // seul le jour compte (l'heure est ignorée)
    var time: Date              // seules l'heure et les minutes comptent (le jour est ignoré)
    var durationMinutes = 60
    var category: TaskCategory = .work
    var priority: TaskPriority = .medium
    var remindsBeforeStart = true

    // Par défaut : la prochaine heure pleine (14:20 devient 15:00). Si elle passe minuit, le jour bascule aussi
    // sur demain, car `day` et `time` partent de la même date.
    init(now: Date = .now, calendar: Calendar = .current) {
        let nextHour = calendar.nextDate(
            after: now,
            matching: DateComponents(minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) ?? now
        day = nextHour
        time = nextHour
    }

    // ⚛️ React : une propriété calculée ≈ une valeur dérivée (`const isValid = title.trim().length > 0`) :
    // jamais stockée, donc jamais désynchronisée. Elle pilote le bouton « Create Task ».
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // Combine le jour choisi et l'heure choisie en une seule échéance.
    func dueDate(calendar: Calendar = .current) -> Date {
        let clock = calendar.dateComponents([.hour, .minute], from: time)
        return calendar.date(
            bySettingHour: clock.hour ?? 0,
            minute: clock.minute ?? 0,
            second: 0,
            of: day
        ) ?? day
    }

    func makeTask(calendar: Calendar = .current) -> TaskItem {
        TaskItem(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            dueDate: dueDate(calendar: calendar),
            category: category,
            priority: priority,
            durationMinutes: durationMinutes,
            reminderMinutes: remindsBeforeStart ? 15 : nil
        )
    }

    // « 15 min », « 1 h », « 1 h 30 » : libellé d'une durée en minutes.
    static func label(forMinutes minutes: Int) -> String {
        let hours = minutes / 60
        let rest = minutes % 60
        switch (hours, rest) {
        case (0, _): return "\(rest) min"
        case (_, 0): return "\(hours) h"
        default: return "\(hours) h \(rest)"
        }
    }
}
