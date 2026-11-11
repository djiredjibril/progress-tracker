import Foundation

struct UserStats {
    var tasksDone: Int
    var focusTime: TimeInterval     // en secondes (`TimeInterval` est un alias de `Double`)
    var streakDays: Int

    // ⚛️ React : une *computed property* se recalcule à chaque lecture, sans être stockée.
    // ≈ un `get focusHours()` de classe JS, ou une valeur dérivée plutôt qu'un `useState` en plus.
    var focusHours: Int { Int(focusTime) / 3600 }
    var focusMinutes: Int { (Int(focusTime) % 3600) / 60 }
}
