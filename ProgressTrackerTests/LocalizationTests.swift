import Foundation
import Testing
@testable import ProgressTracker

struct LocalizationTests {
    @Test func frenchIsTheDefaultLanguage() {
        #expect(AppLanguage.defaultLanguage == .fr)
        #expect(AppLanguage(storedValue: nil) == .fr)
        #expect(AppLanguage(storedValue: "klingon") == .fr)      // valeur illisible : retombe sur le français
        #expect(AppLanguage(storedValue: "en") == .en)
    }

    @Test func eachLanguageHasItsLocale() {
        #expect(AppLanguage.fr.locale.identifier == "fr_FR")
        #expect(AppLanguage.en.locale.identifier == "en_US")
    }

    @Test func translatesInBothLanguages() {
        #expect(tr("Today", language: .en) == "Today")
        #expect(tr("Today", language: .fr) == "Aujourd'hui")
        #expect(tr("Good Morning", language: .fr) == "Bonjour")
    }

    @Test func fillsPlaceholders() {
        #expect(tr("%lld tasks", language: .en, 3) == "3 tasks")
        #expect(tr("%lld tasks", language: .fr, 3) == "3 tâches")
        #expect(tr("You focused %lld min on %@.", language: .fr, 25, "Lecture") == "Vous avez travaillé 25 min sur Lecture.")
    }

    @Test func anUnknownKeyIsReturnedAsIs() {
        #expect(tr("Not in the catalog", language: .fr) == "Not in the catalog")
    }

    // Les deux langues ont exactement les mêmes clés, et chaque traduction garde les mêmes champs (%@, %lld) que la clé.
    @Test func catalogsAreComplete() throws {
        func table(_ language: AppLanguage) throws -> [String: String] {
            let path = try #require(language.bundle.path(forResource: "Localizable", ofType: "strings"))
            return try #require(NSDictionary(contentsOfFile: path) as? [String: String])
        }
        func placeholders(_ text: String) -> [String] {
            text.components(separatedBy: "%").dropFirst().map { String($0.prefix { !$0.isWhitespace }.prefix(while: { $0 == "@" || $0 == "l" || $0 == "d" || $0 == "%" })) }
        }
        let english = try table(.en)
        let french = try table(.fr)
        #expect(!french.isEmpty)
        #expect(Set(english.keys) == Set(french.keys))
        for (key, value) in french {
            #expect(placeholders(key) == placeholders(value), "Champs différents pour « \(key) »")
            #expect(!value.isEmpty)
        }
    }

    @Test func titlesOfEnumsFollowTheLanguage() {
        // La langue des tests est fixée à l'anglais par le schéma (voir project.yml) ; le français passe par `tr`.
        #expect(TaskCategory.work.title == "Work")
        #expect(tr("Work", language: .fr) == "Travail")
        #expect(AppTab.home.title == "Home")
    }
}
