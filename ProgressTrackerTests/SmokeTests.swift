// ⚛️ React : `import Testing` ≈ importer Jest/Vitest. Swift Testing est fourni par le SDK, rien à installer.
import Testing

struct SmokeTests {
    // ⚛️ React : `@Test` ≈ `test("...", () => {})` ou `it(...)`. Pas de préfixe `test` dans le nom,
    // contrairement à XCTest : l'annotation suffit.
    @Test func swiftTestingIsWired() {
        // ⚛️ React : `#expect` ≈ `expect(x).toBe(y)`, mais c'est une macro : en cas d'échec,
        // elle affiche les valeurs de chaque côté de l'expression, sans matchers à apprendre.
        #expect(1 + 1 == 2)
    }
}
