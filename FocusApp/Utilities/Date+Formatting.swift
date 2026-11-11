import Foundation

extension Date {
    // Formate une échéance : « Today, 10:00 AM », « Tomorrow, 9:30 AM » ou « Nov 14, 2:00 PM ».
    // `now` et `calendar` sont injectables pour pouvoir tester sans dépendre de l'horloge réelle.
    func dueLabel(now: Date = .now, calendar: Calendar = .current) -> String {
        // ⚛️ React : `Date.FormatStyle` ≈ `Intl.DateTimeFormat` / `date-fns` : on compose les champs voulus
        // (`.hour().minute()`). Différence : le format s'adapte à la locale. On la force en `en_US` pour coller
        // à la maquette (« 10:00 AM »).
        let locale = Locale(identifier: "en_US")
        let time = formatted(.dateTime.hour().minute().locale(locale))

        if calendar.isDate(self, inSameDayAs: now) {
            return "Today, \(time)"
        }
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
           calendar.isDate(self, inSameDayAs: tomorrow) {
            return "Tomorrow, \(time)"
        }
        return "\(formatted(.dateTime.month(.abbreviated).day().locale(locale))), \(time)"
    }
}

extension Date {
    // Âge d'une notification : « Just now », « 12m ago », « 2h ago » (même jour), « Yesterday », puis « Mon ».
    // `now` et `calendar` sont injectables, comme pour `dueLabel`.
    func relativeLabel(now: Date = .now, calendar: Calendar = .current) -> String {
        let seconds = now.timeIntervalSince(self)
        if seconds < 60 { return "Just now" }

        if calendar.isDate(self, inSameDayAs: now) {
            let minutes = Int(seconds / 60)
            return minutes < 60 ? "\(minutes)m ago" : "\(minutes / 60)h ago"
        }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           calendar.isDate(self, inSameDayAs: yesterday) {
            return "Yesterday"
        }
        return formatted(.dateTime.weekday(.abbreviated).locale(Locale(identifier: "en_US")))
    }
}

extension TimeInterval {
    // « 6h 24m », « 45m », « 0m » : durée courte pour les statistiques de focus.
    var shortDurationLabel: String {
        let totalMinutes = Int(self) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }
}
