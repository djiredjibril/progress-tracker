// ⚛️ React : un `enum` Swift est une union de littéraux TypeScript (`type Tab = 'home' | 'calendar' | …`), en plus
// puissant : il peut porter des propriétés calculées (`title`, `systemImage`), donc pas besoin d'un objet de config à côté.
// `CaseIterable` génère `AppTab.allCases` (≈ `Object.values(Tab)`), dans l'ordre de déclaration.
// `String` comme type brut donne un `rawValue` ("home") qui sert d'`id` pour `Identifiable` (voir CONCEPTS.md#identifiable).
enum AppTab: String, CaseIterable, Identifiable {
    case home
    case calendar
    case analytics
    case profile

    var id: String { rawValue }

    var title: String {
        // ⚛️ React : ce `switch` doit couvrir TOUS les cas : si on ajoute un onglet, le compilateur signale
        // chaque `switch` à compléter (un `Record<Tab, string>` TypeScript fait la même vérification).
        switch self {
        case .home: tr("Home")
        case .calendar: tr("Calendar")
        case .analytics: tr("Analytics")
        case .profile: tr("Profile")
        }
    }

    var systemImage: String {
        switch self {
        case .home: "house.fill"
        case .calendar: "calendar"
        case .analytics: "chart.bar"
        case .profile: "person"
        }
    }
}
