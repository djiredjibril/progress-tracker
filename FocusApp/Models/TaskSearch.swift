import Foundation

// Moteur de recherche des tâches : une fonction PURE (liste + saisie → résultats), donc testable sans aucune vue.
// ⚛️ React : ≈ un `filter` mémoïsé (`useMemo(() => tasks.filter(…), [query, tasks])`) sorti du composant.
enum TaskSearch {
    // Chaque mot saisi doit se retrouver dans le titre OU la catégorie (« gym health » = les deux mots). La comparaison
    // ignore la casse et les accents : « RÉUNION » trouve « reunion ». Les résultats sont triés par échéance.
    static func results(for query: String, in tasks: [TaskItem]) -> [TaskItem] {
        let terms = query
            .split(whereSeparator: \.isWhitespace)
            .map(String.init)
        guard !terms.isEmpty else { return [] }

        return tasks
            .filter { task in
                terms.allSatisfy { term in
                    // ⚛️ React : `localizedStandardContains` ≈ `normalize('NFD').replace(/\p{Diacritic}/gu, '').toLowerCase()
                    // .includes(…)` : insensible à la casse et aux accents, et adapté à la langue de l'appareil.
                    task.title.localizedStandardContains(term) || task.category.title.localizedStandardContains(term)
                }
            }
            .sorted { $0.dueDate < $1.dueDate }
    }
}
