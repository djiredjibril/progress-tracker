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
