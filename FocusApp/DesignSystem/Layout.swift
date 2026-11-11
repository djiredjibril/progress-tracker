import SwiftUI

// ⚛️ React : un `enum` SANS case ne peut pas être instancié : c'est un simple espace de noms
// qui regroupe des constantes (≈ `export const Spacing = { screen: 20, … } as const`).
// On le préfère à une `struct` justement parce qu'on ne peut pas en créer par erreur.
enum Spacing {
    static let screen: CGFloat = 20
    static let section: CGFloat = 24
    static let row: CGFloat = 14        // padding d'une ligne riche (notification)
    static let l: CGFloat = 16          // padding horizontal d'un champ de formulaire
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
    static let day: CGFloat = 16        // jour sélectionné du bandeau de semaine
    static let tag: CGFloat = 10        // pastille de catégorie
    static let field: CGFloat = 16      // champs de formulaire
    static let button: CGFloat = 18     // bouton principal
    static let segment: CGFloat = 12    // pastille d'un contrôle segmenté
    static let sheet: CGFloat = 32      // coins hauts d'une feuille
}

enum Size {
    static let avatar: CGFloat = 112        // 120 dans la maquette, 112 dans le canvas (D-031)
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
    static let eyebrowIcon: CGFloat = 22    // disque blanc derrière la cible de « Today's Goal »
    static let fabRing: CGFloat = 4         // liseré du bouton + (couleur du fond)
    static let field: CGFloat = 52          // hauteur d'un champ de formulaire
    static let chip: CGFloat = 40           // hauteur d'une pastille de choix
    static let primaryButton: CGFloat = 56
    static let segmentHeight: CGFloat = 38
    static let notificationIcon: CGFloat = 40
    static let dayDot: CGFloat = 5          // point « il y a des tâches ce jour-là »
    static let timeColumn: CGFloat = 52     // colonne des heures du planning
    static let nowLine: CGFloat = 2
    static let focusRing: CGFloat = 264     // anneau du minuteur
    static let ringStroke: CGFloat = 16
    static let controlSecondary: CGFloat = 56
    static let controlPrimary: CGFloat = 84
    static let sessionDot: CGFloat = 10
}

// Ombres (voir DESIGN_SYSTEM.md > Ombres)
enum Shadow {
    static let cardRadius: CGFloat = 20     // cartes claires
    static let cardY: CGFloat = 8
    static let goalRadius: CGFloat = 24     // carte objectif
    static let goalY: CGFloat = 12
    static let fabRadius: CGFloat = 16      // bouton + et bouton principal
    static let fabY: CGFloat = 8
    static let segmentRadius: CGFloat = 5   // pastille sélectionnée d'un contrôle segmenté
    static let segmentY: CGFloat = 4
    static let controlRadius: CGFloat = 20  // bouton principal du minuteur
    static let controlY: CGFloat = 12
}
