// ⚛️ React : un `protocol` ≈ une `interface` TypeScript (`interface HomeDataProviding { fetchHomeData(): Promise<HomeData> }`).
// On dépend du protocole, jamais de l'implémentation : on peut donc brancher le mock, ou plus tard un vrai réseau.
@MainActor
protocol HomeDataProviding {
    // ⚛️ React : `async throws` ≈ `async function … : Promise<HomeData>` qui peut rejeter.
    // Différence : `throws` est visible dans la signature, et l'appelant DOIT écrire `try` (le compilateur l'impose).
    func fetchHomeData() async throws -> HomeData
}
