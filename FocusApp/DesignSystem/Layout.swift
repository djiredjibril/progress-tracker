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
}

enum Radius {
    static let card: CGFloat = 24
    static let stat: CGFloat = 22
    static let task: CGFloat = 20
    static let tabBar: CGFloat = 28
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
}
