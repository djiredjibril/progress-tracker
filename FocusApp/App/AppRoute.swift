// Les écrans qu'on peut EMPILER par-dessus les onglets (les onglets eux-mêmes sont `AppTab`).
// ⚛️ React : ≈ le type des routes d'un stack navigator (`type RootStackParamList = { Notifications: undefined; … }`
// avec React Navigation). Chaque `case` est un écran ; un `case` pourrait porter des paramètres
// (`case task(TaskItem)`), comme les `params` d'une route. `Hashable` est exigé par `NavigationStack`.
enum AppRoute: Hashable {
    case notifications
    case focusSession
    case search
}
