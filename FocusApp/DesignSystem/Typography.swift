import SwiftUI

// ⚛️ voir CONCEPTS.md#extension
// Les noms sont préfixés `app` : `Font.body` et `Font.largeTitle` existent déjà dans SwiftUI,
// les redéfinir sous le même nom créerait une ambiguïté (voir D-019).
extension Font {
    static let appGreeting = Font.system(size: 15, weight: .regular)
    static let appLargeTitle = Font.system(size: 30, weight: .bold)
    static let appBody = Font.system(size: 15, weight: .regular)

    static let appStatValue = Font.system(size: 22, weight: .bold)
    static let appStatUnit = Font.system(size: 14, weight: .semibold)
    static let appStatLabel = Font.system(size: 13, weight: .regular)

    static let appCardEyebrow = Font.system(size: 13, weight: .medium)
    static let appCardTitle = Font.system(size: 24, weight: .bold)
    static let appCardBody = Font.system(size: 14, weight: .regular)

    static let appSectionTitle = Font.system(size: 20, weight: .semibold)
    static let appLink = Font.system(size: 14, weight: .medium)
    static let appTaskTitle = Font.system(size: 16, weight: .semibold)
    static let appTaskSubtitle = Font.system(size: 13, weight: .regular)
    static let appTabLabel = Font.system(size: 11, weight: .medium)

    static let appIconButton = Font.system(size: 18, weight: .medium)   // icône des boutons ronds
    static let appStatIcon = Font.system(size: 16, weight: .semibold)   // icône dans la puce d'une stat
}
