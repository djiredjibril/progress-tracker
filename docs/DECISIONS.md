# Journal des décisions

Chaque décision a un identifiant. Claude Code ajoute les nouvelles à la suite (format identique) et ne contredit pas une décision existante sans demander.

---

### D-001 · SwiftUI comme framework UI
**Choix :** SwiftUI, sans UIKit (sauf impossibilité technique, à signaler).
**Pourquoi :** c'est un framework déclaratif, au modèle mental proche de React (UI = f(state)). C'est aujourd'hui le standard pour les nouvelles apps Apple.

### D-002 · Mode d'apprentissage
**Choix :** Claude Code écrit le code et le commente avec des comparaisons React/RN (préfixe `// ⚛️ React :`), selon les règles de `CLAUDE.md`. Les concepts déjà expliqués sont tenus à jour dans `docs/CONCEPTS.md` pour ne pas les répéter.

### D-003 · Cible iOS 17 minimum
**Choix :** `deploymentTarget` iOS 17.0.
**Pourquoi :** donne accès à la macro `@Observable` (framework Observation), bien plus simple que `ObservableObject` / `@Published`, et à `#Preview`. iOS 17 couvre la grande majorité des appareils actifs.

### D-004 · Swift 5 language mode
**Choix :** `SWIFT_VERSION = 5.0` (le compilateur reste celui de Xcode).
**Pourquoi :** le mode Swift 6 impose une vérification stricte de la concurrence, qui produit des erreurs difficiles à comprendre en début d'apprentissage. On reste néanmoins propre : le ViewModel est annoté `@MainActor`. Le passage en Swift 6 est une étape bonus.

### D-005 · Architecture MVVM
**Choix :** Model, View, ViewModel, avec une couche Service derrière un protocole.
- Les **Views** affichent l'état et envoient des intentions (`viewModel.toggle(task)`).
- Le **ViewModel** (`@Observable @MainActor final class`) détient l'état de l'écran et la logique.
- Le **Service** (`HomeDataProviding`, un protocole) fournit les données. Pour l'instant, une implémentation mock (`MockHomeDataProvider`) simule un appel réseau asynchrone.

**Pourquoi :** c'est la séparation standard en SwiftUI. Côté React, c'est l'équivalent de composants + custom hook ou store + `services/api.ts`.

### D-006 · Composants présentationnels
**Choix :** les composants de `Views/Home/Components/` reçoivent des valeurs simples et des closures (`onToggle: () -> Void`), jamais le ViewModel.
**Pourquoi :** ils sont réutilisables et prévisualisables isolément, comme les composants « dumb » en React.

### D-007 · Nommage `TaskItem`
**Choix :** le modèle de tâche s'appelle `TaskItem`, pas `Task`.
**Pourquoi :** `Task` est un type de la concurrence Swift (`Task { await … }`). Le réutiliser créerait des conflits, un peu comme nommer un type `Promise` en TypeScript.

### D-008 · Modèles en `struct`
**Choix :** tous les modèles sont des `struct` (types valeur), avec `Identifiable` quand ils apparaissent dans une liste.
**Pourquoi :** la copie à l'assignation donne l'immutabilité gratuitement, alors qu'en React on se l'impose avec `{...obj}`. Seul le ViewModel est une `class`, car il doit être partagé par référence et observé.

### D-009 · Données mock centralisées
**Choix :** un `enum MockData` (sans case, utilisé comme namespace) qui expose des `static let`. Il est utilisé par `MockHomeDataProvider` et par tous les `#Preview`.

### D-010 · XcodeGen pour le projet
**Choix :** le `.xcodeproj` est généré par XcodeGen depuis `project.yml` et n'est pas commité.
**Pourquoi :** Claude Code ne peut pas éditer un `.pbxproj` de façon fiable. Avec `project.yml`, la config est lisible, versionnable et modifiable par l'IA. Voir `SETUP.md`.

### D-011 · Zéro dépendance tierce
**Choix :** pas de SPM, de Pods ni de Carthage. Les tests utilisent **Swift Testing** (`import Testing`, `@Test`, `#expect`), plus proche de Jest que XCTest.

### D-012 · Assets extraits de la maquette
**Choix :** `Avatar` (avatar 3D, détouré en cercle) et `GoalMountain` (montagne de la carte objectif, bouton effacé, bords gauche et bas en fondu transparent) sont extraits de la maquette et fournis dans `Assets.xcassets`.
**Limite connue :** ce sont des recadrages d'une image en perspective, donc leur résolution est modeste (avatar 600×600, montagne 608×428). Ils sont suffisants pour l'apprentissage et à remplacer par des sources HD plus tard.
Toutes les icônes utilisent SF Symbols.

### D-013 · Police système
**Choix :** police système (SF Pro) avec les tailles et graisses de `DESIGN_SYSTEM.md`. Pas de police custom.
**Pourquoi :** la maquette en est très proche, et cela donne gratuitement le support du Dynamic Type.

### D-014 · Mode clair uniquement (pour l'instant)
**Choix :** `.preferredColorScheme(.light)` sur `RootView`. Le dark mode est une étape bonus.

### D-015 · Effet « verre » (glassmorphism)
**Choix :** les cartes claires combinent `.ultraThinMaterial`, un fond blanc semi-transparent et un liseré blanc, encapsulés dans un `ViewModifier` réutilisable `.glassCard()`.
**Pourquoi :** c'est compatible iOS 17. L'API Liquid Glass des versions récentes d'iOS n'est pas utilisée, car elle ne correspond pas au rendu doux de la maquette et exigerait des `#available`.

### D-016 · Tab bar custom
**Choix :** une tab bar dessinée en SwiftUI (`CustomTabBar`) avec un bouton central « + » flottant, plutôt que `TabView` natif.
**Pourquoi :** le bouton central surélevé n'est pas faisable proprement avec `TabView`. Les onglets autres que Home affichent un écran placeholder.

### D-017 · Nom provisoire
**Choix :** l'app s'appelle `FocusApp`, avec le bundle id `com.example.focusapp`. Le développeur pourra les changer dans `project.yml`.

### D-018 · Simulateur de référence et outils installés
**Choix :** `iPhone 17 Pro` comme simulateur pour build, tests et captures. `xcodegen` et `xcbeautify` installés via Homebrew (avec l'accord du développeur).
**Pourquoi :** modèle récent, non « Plus/Max », aux proportions proches de la maquette (SETUP.md §6).

### D-019 · Tokens de police préfixés `app`
**Choix :** `Font.appGreeting`, `appLargeTitle`, `appBody`, `appStatValue`, etc. (au lieu de `greetingSmall`, `largeTitle`, `body`…).
**Pourquoi :** `Font.body` et `Font.largeTitle` existent déjà dans SwiftUI. Les redéfinir sous le même nom créerait une ambiguïté à l'usage. Les couleurs gardent les noms de `DESIGN_SYSTEM.md` (aucun conflit).

### D-020 · `HomeView` reçoit un provider, pas un ViewModel
**Choix :** `HomeView(provider: HomeDataProviding = MockHomeDataProvider())` crée son `@State HomeViewModel` dans son `init`.
**Pourquoi :** les `#Preview` peuvent injecter un service sans délai (`delay: .zero`), tout en gardant le ViewModel détenu par la vue (`ARCHITECTURE.md`).

### D-021 · Périmètre de l'étape 1
**Choix :** `GlassCard.swift` est repoussé à l'étape 3 (là où `.glassCard()` est introduit, selon la roadmap). `Date+Formatting.swift` est fait dès l'étape 1, car la vue brute affiche déjà « Today, 10:00 AM ». La bascule `.preferredColorScheme(.light)` (D-014) est faite à l'étape 2 avec le fond d'écran.
**Aussi :** `ARCHITECTURE.md` laisse le choix entre `data: HomeData?` et des propriétés séparées. J'ai retenu `data: HomeData?`.

### D-022 · Étape 2 : choix de mise en page
**Choix :**
- Le fond est un composant `Views/Shared/AppBackground.swift` (absent de l'arborescence d'`ARCHITECTURE.md`), appliqué par `HomeView` via `.background`.
- Tokens ajoutés : `Size.badge` (8), `Size.blob` (320), `Size.blobBlur` (80) et `Font.appIconButton` (18 medium).
- Le sous-titre du header utilise un saut de ligne explicite pour reproduire la coupe en 2 lignes de la maquette.
- Le point de notification est piloté par `hasUnreadNotifications`, fixé à `true` dans `HomeView` : le modèle `User` n'a pas ce champ.
- Les boutons ronds n'ont ni matériau ni ombre pour l'instant : l'effet verre arrive avec `.glassCard()` à l'étape 3.

### D-023 · Étape 3 : cartes de stats
**Choix :**
- `StatCardView` reçoit `value: AttributedString` (plutôt que des `Text`) et `iconColors: [Color]`. Le formatage « 6h 24m » est un helper `AttributedString.stat(_:)`, couvert par `StatValueFormattingTests`. `Text + Text` est évité car déprécié dans les SDK récents.
- `.glassCard(cornerRadius:)` prend le rayon en paramètre (défaut `Radius.card`) : les cartes de stats passent `Radius.stat`.
- Tokens ajoutés : `Color.cardShadow`, `Color.textOnAccent`, `Font.appStatIcon`, `Size.avatarOverlap` (24) et `enum Shadow` (rayon 20, y 8).
- Le chevauchement de l'avatar est un `offset` dans `HomeHeaderView` plus un `zIndex(1)` sur le header dans `HomeView`.
- Les boutons ronds du header gardent leur fond simple : `glassCard` est un modifier à coins arrondis, pas un cercle.

### D-024 · Étape 4 : carte objectif
**Choix :**
- `GoalCardView` reçoit `title`, `progress`, `percent` et `onTap`. La phrase « You're 70% closer… » est dérivée de `percent` dans la carte.
- `ProgressBarView` borne `progress` à 0...1 et expose `accessibilityLabel/Value`.
- La montagne mesure 75 % de la hauteur de la carte à 0,9 d'opacité (constantes privées de la vue, tirées de `DESIGN_SYSTEM.md`). Elle est clippée aux coins de la carte, alors que l'ombre est posée sur la forme pour ne pas être coupée.
- Tokens ajoutés : `Color.textOnAccentSecondary`, `progressTrack`, `goalShadow`, `Spacing.card` (20), `Size.progressBar` (8), `Shadow.goalRadius` (24) et `goalY` (12).
- Écart accepté : l'eyebrow utilise `Label` avec l'icône `target` seule, alors que la maquette l'entoure d'un petit disque blanc.
