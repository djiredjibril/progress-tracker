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

// Couleurs du planning (écran Calendar) : fond de la carte, fond et texte de la pastille de catégorie.
// Le canvas colore « Team stand-up » (Work) en bleu et « Design » (Work) en violet : ici la couleur suit la CATÉGORIE,
// pas la tâche (D-037). `Personal` n'est pas dans le canvas : il reprend le bleu.
extension TaskCategory {
    var scheduleFill: Color {
        switch self {
        case .work: Color(hex: 0xD6CCFA, opacity: 0.55)
        case .health: Color(hex: 0xF9DDD7, opacity: 0.60)
        case .learning: Color.white.opacity(0.55)
        case .personal: Color(hex: 0xA9C1FA, opacity: 0.45)
        }
    }

    var tagFill: Color {
        self == .learning ? Color(hex: 0xD6CCFA, opacity: 0.60) : Color.white.opacity(0.70)
    }

    var tagForeground: Color {
        switch self {
        case .work, .learning: Color(hex: 0x4A3FB8)
        case .health: Color(hex: 0xA63D28)
        case .personal: Color(hex: 0x2E55B8)
        }
    }
}
