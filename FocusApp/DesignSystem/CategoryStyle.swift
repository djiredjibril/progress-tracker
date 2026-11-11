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
        case .work: .adaptive(light: Color(hex: 0xD6CCFA, opacity: 0.55), dark: Color(hex: 0x8E8CF7, opacity: 0.26))
        case .health: .adaptive(light: Color(hex: 0xF9DDD7, opacity: 0.60), dark: Color(hex: 0xF2846F, opacity: 0.24))
        case .learning: .adaptive(light: Color.white.opacity(0.55), dark: Color.white.opacity(0.07))
        case .personal: .adaptive(light: Color(hex: 0xA9C1FA, opacity: 0.45), dark: Color(hex: 0x6E95F0, opacity: 0.26))
        }
    }

    var tagFill: Color {
        self == .learning
            ? .adaptive(light: Color(hex: 0xD6CCFA, opacity: 0.60), dark: Color(hex: 0x8E8CF7, opacity: 0.30))
            : .adaptive(light: Color.white.opacity(0.70), dark: Color.white.opacity(0.12))
    }

    var tagForeground: Color {
        switch self {
        case .work, .learning: .adaptive(light: Color(hex: 0x4A3FB8), dark: Color(hex: 0xC9C7FF))
        case .health: .adaptive(light: Color(hex: 0xA63D28), dark: Color(hex: 0xFFB4A4))
        case .personal: .adaptive(light: Color(hex: 0x2E55B8), dark: Color(hex: 0xB8CBFF))
        }
    }
}
