import SwiftUI

// ⚛️ React : un `enum` SANS case ne peut pas être instancié : c'est un simple espace de noms
// qui regroupe des constantes (≈ `export const Spacing = { screen: 20, … } as const`).
// On le préfère à une `struct` justement parce qu'on ne peut pas en créer par erreur.
enum Spacing {
    static let screen: CGFloat = 20
    static let section: CGFloat = 24
    static let m: CGFloat = 12
    static let s: CGFloat = 8
    static let xs: CGFloat = 4
    static let card: CGFloat = 20       // padding interne des grandes cartes
}

enum Radius {
    static let card: CGFloat = 24
    static let stat: CGFloat = 22
    static let task: CGFloat = 20
    static let tabBar: CGFloat = 28
    static let tabItem: CGFloat = 20    // pastille de l'onglet actif
}

enum Size {
    static let avatar: CGFloat = 120
    static let circleButton: CGFloat = 44
    static let statIcon: CGFloat = 36
    static let checkbox: CGFloat = 26
    static let fab: CGFloat = 64
    static let goalArrow: CGFloat = 44
    static let badge: CGFloat = 8           // point de notification
    static let blob: CGFloat = 320          // taches floues du fond d'écran
    static let blobBlur: CGFloat = 80
    static let avatarOverlap: CGFloat = 24  // de combien l'avatar descend sur les cartes de stats
    static let progressBar: CGFloat = 8
    static let menuButton: CGFloat = 32     // zone du menu ⋮ d'une tâche
    static let fabRaise: CGFloat = 20       // de combien le bouton + dépasse de la tab bar
}

// Ombres (voir DESIGN_SYSTEM.md > Ombres)
enum Shadow {
    static let cardRadius: CGFloat = 20     // cartes claires
    static let cardY: CGFloat = 8
    static let goalRadius: CGFloat = 24     // carte objectif
    static let goalY: CGFloat = 12
    static let fabRadius: CGFloat = 16      // bouton +
    static let fabY: CGFloat = 8
}
