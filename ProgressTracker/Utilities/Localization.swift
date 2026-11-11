import Foundation

// Les deux langues de l'app. Le français est la langue PAR DÉFAUT ; l'anglais se choisit dans Profile > Language.
// ⚛️ React : ≈ un `i18n.language` (i18next) persisté : `AppLanguage.current` joue le rôle de `i18n.language`, `tr("clé")` celui de
// `t("clé")`. Différence : les textes littéraux des vues (`Text("Home")`) sont traduits tout seuls par SwiftUI, qui cherche la
// clé dans le catalogue `Localizable.xcstrings` (≈ `fr.json` / `en.json`) ; `tr` ne sert que pour les `String` calculés.
enum AppLanguage: String, CaseIterable, Identifiable, Hashable {
    case fr, en

    static let defaultLanguage: AppLanguage = .fr

    var id: String { rawValue }

    // Le nom d'une langue s'écrit toujours dans cette langue (comme dans les réglages d'iOS) : jamais traduit.
    var title: String {
        switch self {
        case .fr: "Français"
        case .en: "English"
        }
    }

    // Locale utilisée pour les dates et les nombres : en anglais on garde `en_US` (« 10:00 AM », comme la maquette).
    var locale: Locale {
        Locale(identifier: self == .fr ? "fr_FR" : "en_US")
    }

    // La langue active. Priorité : la variable d'environnement `PT_LANGUAGE` (fixée par le schéma de test, pour des tests
    // déterministes), puis le réglage de Profile, puis le français.
    static var current: AppLanguage {
        if let forced = ProcessInfo.processInfo.environment["PT_LANGUAGE"], let language = AppLanguage(rawValue: forced) {
            return language
        }
        return AppLanguage(storedValue: UserDefaults.standard.string(forKey: SettingsKey.language))
    }

    // Une valeur illisible retombe sur la langue par défaut (même principe que `AppearanceMode`).
    init(storedValue: String?) {
        self = storedValue.flatMap(AppLanguage.init(rawValue:)) ?? Self.defaultLanguage
    }

    // Le dossier `fr.lproj` / `en.lproj` qui contient les traductions compilées depuis le catalogue.
    var bundle: Bundle {
        guard let path = Bundle.main.path(forResource: rawValue, ofType: "lproj"), let bundle = Bundle(path: path) else {
            return .main
        }
        return bundle
    }
}

// ⚛️ React : ≈ `t("clé", { count })`. La clé est le texte anglais ; `%d` / `%@` se remplissent comme avec `String(format:)`.
// Les clés absentes du catalogue sont renvoyées telles quelles (jamais de texte vide à l'écran).
func tr(_ key: String, language: AppLanguage = .current, _ arguments: CVarArg...) -> String {
    let format = language.bundle.localizedString(forKey: key, value: key, table: nil)
    guard !arguments.isEmpty else { return format }
    return String(format: format, locale: language.locale, arguments: arguments)
}
