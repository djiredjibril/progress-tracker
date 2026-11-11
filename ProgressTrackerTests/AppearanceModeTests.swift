import SwiftUI
import Testing
import UIKit
@testable import ProgressTracker

struct AppearanceModeTests {
    @Test func titlesAndOrder() {
        #expect(AppearanceMode.allCases.map(\.title) == ["System", "Light", "Dark"])
    }

    @Test func colorSchemeMapping() {
        #expect(AppearanceMode.system.colorScheme == nil)        // nil : le système décide
        #expect(AppearanceMode.light.colorScheme == .light)
        #expect(AppearanceMode.dark.colorScheme == .dark)
    }

    @Test func unknownStoredValueFallsBackToSystem() {
        #expect(AppearanceMode(storedValue: "dark") == .dark)
        #expect(AppearanceMode(storedValue: "") == .system)
        #expect(AppearanceMode(storedValue: "sepia") == .system)
    }

    @Test func settingsKeysRemainUnique() {
        let keys = [SettingsKey.notificationsEnabled, SettingsKey.dailyGoal, SettingsKey.focusMinutes, SettingsKey.appearance]
        #expect(Set(keys).count == keys.count)
    }

    // Les couleurs de base changent VRAIMENT entre les deux modes (et la valeur claire n'a pas bougé).
    @Test func baseColorsResolveDifferentlyInDarkMode() {
        func resolved(_ color: Color, _ style: UIUserInterfaceStyle) -> UIColor {
            UIColor(color).resolvedColor(with: UITraitCollection(userInterfaceStyle: style))
        }
        func components(_ color: UIColor) -> [CGFloat] {
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            color.getRed(&r, green: &g, blue: &b, alpha: &a)
            return [r, g, b]
        }
        for color in [Color.textPrimary, Color.backgroundTop, Color.fieldFill, Color.appPrimaryStrong] {
            #expect(components(resolved(color, .light)) != components(resolved(color, .dark)))
        }
        // Le texte principal est foncé en mode clair et clair en mode sombre (contraste inversé).
        #expect(components(resolved(.textPrimary, .light)).reduce(0, +) < 1.0)
        #expect(components(resolved(.textPrimary, .dark)).reduce(0, +) > 2.0)
    }
}
