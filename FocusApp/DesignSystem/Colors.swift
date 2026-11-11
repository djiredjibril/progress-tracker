import SwiftUI

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

    // MARK: - Accent

    // ⚛️ React : `static let` ≈ une constante exportée d'un fichier de thème (`export const colors = { … }`).
    // Elle se lit `Color.appPrimary`. `let` = constante (comme `const`), `var` = modifiable.
    static let appPrimary = Color(hex: 0x6C6CF5)
    static let appPrimaryLight = Color(hex: 0x8E8CF7)
    // Variantes plus foncées du canvas (contraste 4.5:1, D-029) : onglet actif, liens, bouton principal.
    static let appPrimaryStrong = Color(hex: 0x5552E0)
    static let appPrimaryDeep = Color(hex: 0x3F3BC0)        // texte d'une pastille sélectionnée
    static let buttonGradientStart = Color(hex: 0x6D6BEE)
    static let buttonGradientEnd = Color(hex: 0x4F4BD8)
    static let buttonShadow = Color.appPrimaryStrong.opacity(0.35)
    static let destructive = Color(hex: 0xB4322A)           // « Log out », actions de suppression

    // MARK: - Texte

    static let textPrimary = Color(hex: 0x0F1328)
    static let textSecondary = Color(hex: 0x5F6479)         // assombri depuis #6B7088 (D-029)
    static let textTertiary = Color(hex: 0x9A9EB2)
    static let textPlaceholder = Color(hex: 0x6E7389)

    // MARK: - Fond

    static let backgroundTop = Color(hex: 0xE6ECFB)
    static let backgroundBottom = Color(hex: 0xF3F1FC)
    static let glassFill = Color.white.opacity(0.55)
    static let glassStroke = Color.white.opacity(0.70)
    static let cardShadow = Color.appPrimary.opacity(0.08)

    // Texte et icônes posés sur un fond coloré (puces de stats, carte objectif)
    static let textOnAccent = Color.white
    static let textOnAccentSecondary = Color.white.opacity(0.85)    // sous-titre de la carte objectif
    static let progressTrack = Color.white.opacity(0.30)            // piste de la barre de progression
    static let goalShadow = Color.goalGradientStart.opacity(0.30)
    static let fabShadow = Color.appPrimaryStrong.opacity(0.40)     // ombre du bouton +
    static let tabPill = Color.appPrimary.opacity(0.14)             // pastille de l'onglet actif

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

    static let sheetTop = Color(hex: 0xF7F6FE)
    static let sheetBottom = Color(hex: 0xF1F0FC)
    static let fieldFill = Color.white
    static let fieldBorder = Color.textPrimary.opacity(0.10)
    static let focusRing = Color.appPrimary.opacity(0.12)
    static let segmentTrack = Color.textPrimary.opacity(0.05)
    static let closeFill = Color.textPrimary.opacity(0.06)
    static let selectedChipFill = Color.appPrimary.opacity(0.12)

    // MARK: - Notifications (non lue : plus opaque, avec ombre ; lue : plus discrète)

    static let notificationUnreadFill = Color.white.opacity(0.75)
    static let notificationUnreadStroke = Color.white.opacity(0.90)
    static let notificationReadFill = Color.white.opacity(0.50)

    // MARK: - Minuteur et catégories

    static let ringTrack = Color.appPrimary.opacity(0.15)
    static let ringGradientStart = Color(hex: 0xA58DF0)
    static let categoryWork = Color.appPrimaryStrong
    static let categoryHealth = Color.statStreakDark
    static let categoryLearning = Color.ringGradientStart
    static let categoryPersonal = Color.statFocusDark

    // MARK: - Analytics

    static let chartBarPast = Color.appPrimary.opacity(0.28)
    static let chartBarFuture = Color.textPrimary.opacity(0.08)
    static let categoryTrack = Color.textPrimary.opacity(0.07)
    static let miniRingTrack = Color.appPrimary.opacity(0.18)

    // MARK: - Profil et réglages

    static let avatarBorder = Color.white.opacity(0.90)
    static let avatarShadow = Color.appPrimary.opacity(0.25)
    static let rowDivider = Color.textPrimary.opacity(0.06)
    static let statDivider = Color.textPrimary.opacity(0.08)
    static let settingsBlueFill = Color.statFocusDark.opacity(0.18)
    static let settingsBlueForeground = Color(hex: 0x2E55B8)
    static let settingsCoralFill = Color.statStreakDark.opacity(0.18)
    static let settingsCoralForeground = Color(hex: 0xA63D28)
    static let settingsDestructiveFill = Color.destructive.opacity(0.10)
}
