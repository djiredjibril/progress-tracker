import Foundation

extension Calendar {
    // Le calendrier du canvas commence la semaine le LUNDI (Mon … Sun), quelle que soit la locale du téléphone.
    // ⚛️ React : ≈ `date-fns` `startOfWeek(date, { weekStartsOn: 1 })`, mais fixé une fois pour toute l'app.
    static var mondayFirst: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        return calendar
    }
}
