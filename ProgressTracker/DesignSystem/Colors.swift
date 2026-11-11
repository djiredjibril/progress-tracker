import SwiftUI
import UIKit

// ⚛️ React : une `extension` ajoute des membres à un type existant (ici le `Color` d'Apple) sans le modifier.
// Proche d'une augmentation de module TypeScript, ou d'un `theme` branché sur un objet qu'on ne possède pas.
extension Color {
    // ⚛️ React : un `init` est un constructeur. `opacity: Double = 1` ≈ un paramètre par défaut (`opacity = 1`).
    // Différence : les noms d'arguments (`hex:`, `opacity:`) sont obligatoires à l'appel, comme un objet de props.
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }

    // ⚛️ React : ≈ un thème `{ light, dark }` résolu par `useColorScheme()`, mais calculé PAR iOS au moment du dessin :
    // la couleur se met à jour toute seule quand le mode change, sans re-render ni contexte à propager. Les couleurs
    // DÉRIVÉES (`Color.textPrimary.opacity(0.1)`) restent adaptatives : elles suivent leur base.
    static func adaptive(light: Color, dark: Color) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }

    // MARK: - Accent

    // ⚛️ React : `static let` ≈ une constante exportée d'un fichier de thème (`export const colors = { … }`).
    // Elle se lit `Color.appPrimary`. `let` = constante (comme `const`), `var` = modifiable.
    static let appPrimary = Color(hex: 0x6C6CF5)
    static let appPrimaryLight = Color(hex: 0x8E8CF7)
    // Variantes plus foncées du canvas (contraste 4.5:1, D-029) : onglet actif, liens, bouton principal.
    static let appPrimaryStrong = Color.adaptive(light: Color(hex: 0x5552E0), dark: Color(hex: 0x8E8CF7))
    static let appPrimaryDeep = Color.adaptive(light: Color(hex: 0x3F3BC0), dark: Color(hex: 0xC9C7FF))        // texte d'une pastille sélectionnée
    static let buttonGradientStart = Color(hex: 0x6D6BEE)
    static let buttonGradientEnd = Color(hex: 0x4F4BD8)
    static let buttonShadow = Color.appPrimaryStrong.opacity(0.35)
    static let destructive = Color.adaptive(light: Color(hex: 0xB4322A), dark: Color(hex: 0xFF8A80))           // « Log out », actions de suppression

    // MARK: - Texte

    static let textPrimary = Color.adaptive(light: Color(hex: 0x0F1328), dark: Color(hex: 0xF2F3FA))
    static let textSecondary = Color.adaptive(light: Color(hex: 0x5F6479), dark: Color(hex: 0xA9AEC6))         // assombri depuis #6B7088 (D-029)
    static let textTertiary = Color.adaptive(light: Color(hex: 0x9A9EB2), dark: Color(hex: 0x7C819A))
    static let textPlaceholder = Color.adaptive(light: Color(hex: 0x6E7389), dark: Color(hex: 0x8C91A8))

    // MARK: - Fond

    static let backgroundTop = Color.adaptive(light: Color(hex: 0xE6ECFB), dark: Color(hex: 0x12162B))
    static let backgroundBottom = Color.adaptive(light: Color(hex: 0xF3F1FC), dark: Color(hex: 0x1A1630))
    static let glassFill = Color.adaptive(light: Color.white.opacity(0.55), dark: Color.white.opacity(0.08))
    static let glassStroke = Color.adaptive(light: Color.white.opacity(0.70), dark: Color.white.opacity(0.14))
    static let cardShadow = Color.adaptive(light: Color(hex: 0x6C6CF5, opacity: 0.08), dark: Color.black.opacity(0.30))

    // Texte et icônes posés sur un fond coloré (puces de stats, carte objectif)
    static let textOnAccent = Color.white
    static let textOnAccentSecondary = Color.white.opacity(0.85)    // sous-titre de la carte objectif
    static let progressTrack = Color.white.opacity(0.30)            // piste de la barre de progression
    static let goalShadow = Color(hex: 0x4E60D9, opacity: 0.30)
    static let fabShadow = Color.appPrimaryStrong.opacity(0.40)     // ombre du bouton +
    static let tabPill = Color.adaptive(light: Color(hex: 0x6C6CF5, opacity: 0.14), dark: Color(hex: 0x8E8CF7, opacity: 0.28))             // pastille de l'onglet actif

    // MARK: - Carte objectif (dégradé du bas-gauche vers le haut-droite)

    static let goalGradientStart = Color(hex: 0x5A6FE4)
    static let goalGradientMid = Color(hex: 0x7F84F2)
    static let goalGradientEnd = Color(hex: 0xB59DF4)

    // MARK: - Puces d'icônes des stats (clair → foncé)

    static let statTasksLight = Color(hex: 0xD6CCFA)
    static let statTasksDark = Color(hex: 0xA493F2)
    static let statFocusLight = Color(hex: 0xA9C1FA)
    static let statFocusDark = Color(hex: 0x6E95F0)
    static let statStreakLight = Color(hex: 0xF9DDD7)
    static let statStreakDark = Color(hex: 0xF2846F)

    // MARK: - Formulaires et feuilles

    static let sheetTop = Color.adaptive(light: Color(hex: 0xF7F6FE), dark: Color(hex: 0x191C33))
    static let sheetBottom = Color.adaptive(light: Color(hex: 0xF1F0FC), dark: Color(hex: 0x151830))
    static let fieldFill = Color.adaptive(light: Color.white, dark: Color(hex: 0x1F2340))
    static let fieldBorder = Color.textPrimary.opacity(0.10)
    static let focusRing = Color.adaptive(light: Color(hex: 0x6C6CF5, opacity: 0.12), dark: Color(hex: 0x8E8CF7, opacity: 0.30))
    static let segmentTrack = Color.textPrimary.opacity(0.05)
    static let closeFill = Color.textPrimary.opacity(0.06)
    static let selectedChipFill = Color.adaptive(light: Color(hex: 0x6C6CF5, opacity: 0.12), dark: Color(hex: 0x8E8CF7, opacity: 0.26))

    // MARK: - Notifications (non lue : plus opaque, avec ombre ; lue : plus discrète)

    static let notificationUnreadFill = Color.adaptive(light: Color.white.opacity(0.75), dark: Color.white.opacity(0.12))
    static let notificationUnreadStroke = Color.adaptive(light: Color.white.opacity(0.90), dark: Color.white.opacity(0.18))
    static let notificationReadFill = Color.adaptive(light: Color.white.opacity(0.50), dark: Color.white.opacity(0.05))

    // MARK: - Minuteur et catégories

    static let ringTrack = Color.adaptive(light: Color(hex: 0x6C6CF5, opacity: 0.15), dark: Color(hex: 0x8E8CF7, opacity: 0.28))
    static let ringGradientStart = Color(hex: 0xA58DF0)
    static let categoryWork = Color.appPrimaryStrong
    static let categoryHealth = Color.statStreakDark
    static let categoryLearning = Color.ringGradientStart
    static let categoryPersonal = Color.statFocusDark

    // MARK: - Analytics

    static let chartBarPast = Color.adaptive(light: Color(hex: 0x6C6CF5, opacity: 0.28), dark: Color(hex: 0x8E8CF7, opacity: 0.42))
    static let chartBarFuture = Color.textPrimary.opacity(0.08)
    static let categoryTrack = Color.textPrimary.opacity(0.07)
    static let miniRingTrack = Color.adaptive(light: Color(hex: 0x6C6CF5, opacity: 0.18), dark: Color(hex: 0x8E8CF7, opacity: 0.30))

    // MARK: - Profil et réglages

    static let avatarBorder = Color.adaptive(light: Color.white.opacity(0.90), dark: Color.white.opacity(0.30))
    static let avatarShadow = Color.appPrimary.opacity(0.25)
    static let rowDivider = Color.textPrimary.opacity(0.06)
    static let statDivider = Color.textPrimary.opacity(0.08)
    static let settingsBlueFill = Color.statFocusDark.opacity(0.18)
    static let settingsBlueForeground = Color.adaptive(light: Color(hex: 0x2E55B8), dark: Color(hex: 0xB8CBFF))
    static let settingsCoralFill = Color.statStreakDark.opacity(0.18)
    static let settingsCoralForeground = Color.adaptive(light: Color(hex: 0xA63D28), dark: Color(hex: 0xFFB4A4))
    static let settingsDestructiveFill = Color.destructive.opacity(0.10)

    // MARK: - Marque (Splash, icône) et parcours d'entrée

    static let brandStart = Color.ringGradientStart                 // #A58DF0
    static let brandMid = Color(hex: 0x6B70E6)
    static let brandEnd = Color(hex: 0x4E60D9)
    static let splashHalo = Color.white.opacity(0.45)
    static let splashShade = Color(hex: 0x3C32BE, opacity: 0.35)
    static let onboardingBlobPlan = Color.appPrimary.opacity(0.22)
    static let onboardingBlobFocus = Color.statFocusDark.opacity(0.25)
    static let onboardingBlobProgress = Color.goalGradientEnd.opacity(0.30)
    static let pageDotInactive = Color.appPrimaryStrong.opacity(0.25)

    // MARK: - Conformité au canvas (Home)

    static let backgroundBlobPrimary = Color.appPrimary.opacity(0.16)
    static let backgroundBlobSecondary = Color.goalGradientEnd.opacity(0.18)
    static let eyebrowDisc = Color.white.opacity(0.9)
    static let tabBarFill = Color.adaptive(light: Color.white.opacity(0.78), dark: Color(hex: 0x1B1F36, opacity: 0.86))
    static let tabBarStroke = Color.adaptive(light: Color.white.opacity(0.90), dark: Color.white.opacity(0.12))
    static let tabBarShadow = Color.appPrimaryStrong.opacity(0.14)
    static let arrowShadow = Color.black.opacity(0.12)
}
