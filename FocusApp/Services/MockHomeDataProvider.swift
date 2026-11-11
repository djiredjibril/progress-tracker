// Implémentation du protocole qui simule un appel réseau.
struct MockHomeDataProvider: HomeDataProviding {
    // ⚛️ React : `Duration` est un type dédié aux durées (≈ un nombre de ms, mais typé : pas de confusion s/ms).
    // La valeur par défaut permet d'écrire `MockHomeDataProvider()` ou `MockHomeDataProvider(delay: .zero)` en test.
    var delay: Duration = .milliseconds(400)
    // La personne connectée : si elle est fournie, elle remplace l'utilisateur mock (« Hello, Sam » après une inscription).
    var user: User?

    func fetchHomeData() async throws -> HomeData {
        // ⚛️ React : `await` ≈ `await` JS : la fonction se suspend sans bloquer l'interface.
        // `Task.sleep` ≈ `await new Promise(r => setTimeout(r, ms))`.
        try await Task.sleep(for: delay)
        var data = MockData.homeData
        if let user { data.user = user }
        return data
    }
}
