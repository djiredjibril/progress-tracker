import Foundation
import Testing
@testable import ProgressTracker

struct TaskSearchTests {
    private func task(_ title: String, hour: Int, category: TaskCategory = .work) -> TaskItem {
        TaskItem(
            title: title,
            dueDate: Calendar.current.date(from: DateComponents(year: 2026, month: 11, day: 11, hour: hour))!,
            category: category
        )
    }

    private var tasks: [TaskItem] {
        [
            task("Réunion d'équipe", hour: 15),
            task("Workout", hour: 18, category: .health),
            task("Read a book", hour: 20, category: .learning),
            task("Design new UI screens", hour: 10)
        ]
    }

    @Test func emptyOrBlankQueryReturnsNothing() {
        #expect(TaskSearch.results(for: "", in: tasks).isEmpty)
        #expect(TaskSearch.results(for: "   \n ", in: tasks).isEmpty)
    }

    @Test func matchingIgnoresCaseAndAccents() {
        #expect(TaskSearch.results(for: "reunion", in: tasks).map(\.title) == ["Réunion d'équipe"])
        #expect(TaskSearch.results(for: "RÉUNION", in: tasks).map(\.title) == ["Réunion d'équipe"])
        // « wORk » : titre de « Workout » ET catégorie Work des deux autres, triés par échéance.
        #expect(TaskSearch.results(for: "wORk", in: tasks).map(\.title) == ["Design new UI screens", "Réunion d'équipe", "Workout"])
    }

    @Test func aWordCanMatchTheCategory() {
        // « health » n'est dans aucun titre mais c'est la catégorie de « Workout ».
        #expect(TaskSearch.results(for: "health", in: tasks).map(\.title) == ["Workout"])
    }

    @Test func everyWordMustMatch() {
        #expect(TaskSearch.results(for: "read book", in: tasks).map(\.title) == ["Read a book"])
        #expect(TaskSearch.results(for: "read workout", in: tasks).isEmpty)
    }

    @Test func resultsAreSortedByDueDate() {
        // « e » apparaît dans les quatre tâches (« Workout » via sa catégorie « Health ») : l'ordre doit suivre
        // l'échéance, pas l'ordre de la liste d'origine.
        let titles = TaskSearch.results(for: "e", in: tasks).map(\.title)
        #expect(titles == ["Design new UI screens", "Réunion d'équipe", "Workout", "Read a book"])
    }

    @Test func noMatchReturnsAnEmptyList() {
        #expect(TaskSearch.results(for: "zzz", in: tasks).isEmpty)
    }
}
