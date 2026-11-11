import SwiftUI

// La couleur d'une catégorie vit dans la couche design, pas dans le modèle : `TaskCategory` ne connaît pas SwiftUI.
// ⚛️ voir CONCEPTS.md#extension : on ajoute une propriété à un type défini ailleurs (ici dans `Models/`).
extension TaskCategory {
    var tint: Color {
        switch self {
        case .work: Color.categoryWork
        case .health: Color.categoryHealth
        case .learning: Color.categoryLearning
        case .personal: Color.categoryPersonal
        }
    }
}
