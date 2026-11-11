import Foundation

// ⚛️ React : un protocole est une interface que le type promet de respecter.
// `Identifiable` exige une propriété `id` : c'est ce que `ForEach`/`List` utilisent comme `key` en React.
// `Hashable` permet de comparer et de mettre l'objet dans un `Set` (≈ pouvoir l'utiliser comme clé de `Map`).
struct TaskItem: Identifiable, Hashable {
    let id: UUID
    var title: String
    var dueDate: Date
    var isCompleted: Bool
    var category: TaskCategory
    var priority: TaskPriority
    var durationMinutes: Int
    // ⚛️ voir CONCEPTS.md#optional : `nil` = pas de rappel, sinon le nombre de minutes avant l'échéance.
    var reminderMinutes: Int?

    // ⚛️ React : on écrit l'`init` à la main pour donner des valeurs par défaut (`id` auto-généré,
    // `isCompleted` à faux). ≈ une factory `makeTask({ title, dueDate })` qui complète les champs manquants.
    // Les champs ajoutés à l'étape 8 ont aussi une valeur par défaut : le code existant continue de compiler.
    init(
        id: UUID = UUID(),
        title: String,
        dueDate: Date,
        isCompleted: Bool = false,
        category: TaskCategory = .work,
        priority: TaskPriority = .medium,
        durationMinutes: Int = 60,
        reminderMinutes: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.category = category
        self.priority = priority
        self.durationMinutes = durationMinutes
        self.reminderMinutes = reminderMinutes
    }
}
