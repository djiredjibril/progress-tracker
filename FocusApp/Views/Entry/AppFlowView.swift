import SwiftUI

// La racine de l'app : elle choisit entre le parcours d'ENTRÉE (Splash → Onboarding → Log In / Sign Up) et l'app elle-même
// (`RootView`, avec ses onglets), selon l'état de connexion.
// ⚛️ React : ≈ le navigateur racine d'une app RN avec « auth flow » : `isSignedIn ? <MainTabs /> : <AuthStack />`.
struct AppFlowView: View {
    // Les écrans du parcours d'entrée (l'app connectée n'en fait pas partie : elle dépend de `auth.isLoggedIn`).
    private enum Step { case splash, onboarding, logIn, signUp }

    @State private var auth: AuthViewModel
    @State private var step: Step = .splash
    // Identité de l'app connectée : elle change à CHAQUE connexion / déconnexion (donc l'app repart de zéro), mais pas quand
    // le profil est modifié.
    @State private var appID = UUID()

    // ⚛️ voir CONCEPTS.md#app-storage : le mode d'apparence choisi dans Profile, relu ici pour toute l'app.
    @AppStorage(SettingsKey.appearance) private var appearanceValue = AppearanceMode.system.rawValue

    // ⚛️ React : le ViewModel est créé DANS l'`init` (et non en valeur par défaut) : `AuthViewModel` est isolé au thread
    // principal, et une valeur par défaut serait évaluée ailleurs. `nil` = « utilise la vraie persistance ».
    // ⚛️ React : le stockage local est créé UNE fois pour toute l'app (≈ ouvrir la base au démarrage) puis passé à `RootView`.
    // Il survit aux déconnexions : les tâches restent sur l'appareil.
    private let store: DataStore

    init(auth: AuthViewModel? = nil, store: DataStore? = nil) {
        _auth = State(initialValue: auth ?? AuthViewModel())
        self.store = store ?? SwiftDataStore.makeDefault()
    }

    var body: some View {
        ZStack {
            if auth.isLoggedIn && step != .splash {
                mainApp
                    .transition(.opacity)
            } else {
                entry
                    .transition(.opacity)
            }
        }
        // ⚛️ voir CONCEPTS.md#transition-animation-value : les changements d'écran se font en fondu.
        .animation(.smooth, value: auth.isLoggedIn)
        .animation(.smooth, value: step)
        // ⚛️ React : ≈ `<ThemeProvider>` à la racine. `nil` (mode System) laisse iOS décider ; posé ici, il s'applique à TOUT :
        // onglets, feuilles, écrans empilés. Il remplace le mode clair forcé de D-014.
        .preferredColorScheme(AppearanceMode(storedValue: appearanceValue).colorScheme)
    }

    // MARK: - L'app connectée

    private var mainApp: some View {
        // ⚛️ React : `.id(valeur)` ≈ `key={valeur}` sur un composant : quand la valeur change (autre session), SwiftUI
        // DÉTRUIT et recrée `RootView`, donc ses `@State` (ViewModels, onglet) repartent de zéro.
        RootView(
            store: store,
            user: auth.currentUser,
            onLogOut: {
                auth.logOut()
                step = .logIn
            },
            onUpdateProfile: { auth.updateProfile($0) }
        )
        .id(appID)
        // Nouvelle connexion ou déconnexion : nouvelle identité, donc `RootView` est recréée.
        .onChange(of: auth.isLoggedIn) { appID = UUID() }
    }

    // MARK: - Le parcours d'entrée

    @ViewBuilder
    private var entry: some View {
        switch step {
        case .splash:
            SplashView(onFinished: finishSplash)
        case .onboarding:
            OnboardingView { exit in
                switch exit {
                case .signUp: step = .signUp
                case .logIn: step = .logIn
                }
            }
        case .logIn:
            LoginView(auth: auth, onShowSignUp: { step = .signUp })
        case .signUp:
            SignUpView(
                auth: auth,
                // Retour : l'onboarding tant qu'il n'a pas été terminé (comme le canvas), sinon Log In.
                onBack: { step = auth.hasSeenOnboarding ? .logIn : .onboarding },
                onShowLogIn: { step = .logIn }
            )
        }
    }

    // Appelée à la fin du Splash (ou au toucher) : l'app si déjà connecté, sinon l'onboarding la première fois, sinon Log In.
    private func finishSplash() {
        guard step == .splash else { return }       // un toucher ET la fin du minuteur : on n'avance qu'une fois
        step = auth.isLoggedIn ? .logIn : (auth.hasSeenOnboarding ? .logIn : .onboarding)
    }
}

#Preview {
    AppFlowView(auth: AuthViewModel(provider: MockAuthProvider(delay: .zero), defaults: UserDefaults(suiteName: "preview")!))
}
