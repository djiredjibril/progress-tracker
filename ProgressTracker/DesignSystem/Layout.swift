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
    static let logoTile: CGFloat = 18   // tuile du logo sur Log In
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
    static let progressBar: CGFloat = 8
    static let fabRaise: CGFloat = 16       // de combien le bouton + dépasse de la tab bar (canvas)
    static let tabBarHeight: CGFloat = 72
    static let tabIconWidth: CGFloat = 48   // pastille de l'onglet actif : derrière l'icône seule
    static let tabIconHeight: CGFloat = 30
    static let goalCardHeight: CGFloat = 164
    static let goalMountain: CGFloat = 128
    static let goalProgressBar: CGFloat = 10
    static let badgeRing: CGFloat = 12      // point de notification + anneau blanc de 2 pt
    static let backgroundBlobPrimary: CGFloat = 280
    static let backgroundBlobSecondary: CGFloat = 260
    static let backgroundBlobBlur: CGFloat = 70
    static let taskMenuWidth: CGFloat = 36
    static let taskMenuHeight: CGFloat = 44
    static let eyebrowIcon: CGFloat = 24    // disque blanc derrière la cible de « Today's Goal »
    static let fabRing: CGFloat = 4         // liseré du bouton + (couleur du fond)
    static let field: CGFloat = 52          // hauteur d'un champ de formulaire
    static let chip: CGFloat = 40           // hauteur d'une pastille de choix
    static let primaryButton: CGFloat = 56
    static let segmentHeight: CGFloat = 38
    static let notificationIcon: CGFloat = 40
    static let dayDot: CGFloat = 5          // point « il y a des tâches ce jour-là »
    static let chartHeight: CGFloat = 140
    static let profileAvatar: CGFloat = 92
    static let splashLogo: CGFloat = 140
    static let logoTile: CGFloat = 64
    static let onboardingArt: CGFloat = 340
    static let pageDot: CGFloat = 8
    static let pageDotActiveWidth: CGFloat = 24
    static let settingsRow: CGFloat = 52
    static let settingsIcon: CGFloat = 32
    static let miniRing: CGFloat = 56       // anneau « Tasks done »
    static let miniRingStroke: CGFloat = 8
    static let streakIcon: CGFloat = 44
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
    static let avatarRadius: CGFloat = 14   // avatar de la page Profil
    static let avatarY: CGFloat = 8
    static let heroAvatarY: CGFloat = 12    // avatar de Home (plus haut que celui du profil)
    static let arrowRadius: CGFloat = 7     // bouton › de la carte objectif
    static let arrowY: CGFloat = 6
    static let tabBarRadius: CGFloat = 15
    static let tabBarY: CGFloat = 10
    static let controlY: CGFloat = 12
}
