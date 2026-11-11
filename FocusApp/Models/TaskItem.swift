import Foundation

// ⚛️ React : un protocole est une interface que le type promet de respecter.
// `Identifiable` exige une propriété `id` : c'est ce que `ForEach`/`List` utilisent comme `key` en React.
// `Hashable` permet de comparer et de mettre l'objet dans un `Set` (≈ pouvoir l'utiliser comme clé de `Map`).
struct TaskItem: Identifiable, Hashable {
    let id: UUID
    var title: String
    var dueDate: Date
    var isCompleted: Bool

    // ⚛️ React : on écrit l'`init` à la main pour donner des valeurs par défaut (`id` auto-généré,
    // `isCompleted` à faux). ≈ une factory `makeTask({ title, dueDate })` qui complète les champs manquants.
    init(id: UUID = UUID(), title: String, dueDate: Date, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.isCompleted = isCompleted
    }
}
