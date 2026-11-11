import SwiftUI

// Le mode d'apparence choisi dans Profile > Appearance.
// ⚛️ React : ≈ le réglage « thème » d'une app (`'light' | 'dark' | 'system'`) : `system` suit le téléphone, les deux autres
// forcent un mode. `colorScheme` est ce qu'on passe à `.preferredColorScheme(_:)` : `nil` veut dire « laisse le système décider ».
enum AppearanceMode: String, CaseIterable, Identifiable, Hashable {
    case system, light, dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: tr("System")
        case .light: tr("Light")
        case .dark: tr("Dark")
        }
    }

    var systemImage: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max"
        case .dark: "moon"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    // Une valeur illisible dans les réglages (ancienne version, fichier corrompu) retombe sur « System ».
    init(storedValue: String) {
        self = AppearanceMode(rawValue: storedValue) ?? .system
    }
}
