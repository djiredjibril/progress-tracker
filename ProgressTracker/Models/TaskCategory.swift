// ⚛️ React : un `enum` avec `String` comme type brut ≈ `type Category = 'work' | 'health' | …`, avec en plus
// la liste de toutes les valeurs (`allCases`, via `CaseIterable`) et une propriété calculée pour l'affichage.
// Voir CONCEPTS.md#enum-caseiterable.
enum TaskCategory: String, CaseIterable, Identifiable, Hashable {
    case work
    case health
    case learning
    case personal

    var id: String { rawValue }

    var title: String {
        switch self {
        case .work: "Work"
        case .health: "Health"
        case .learning: "Learning"
        case .personal: "Personal"
        }
    }
}
