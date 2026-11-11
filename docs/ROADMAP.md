# Roadmap

Une étape à la fois. À la fin de chaque étape : build sans warning, tests verts, capture comparée à la maquette, case cochée, récap pédagogique dans le chat, puis **pause pour validation**.

---

## [x] Étape 0 — Setup
Suivre `SETUP.md` : vérifier les outils, créer `project.yml`, `.gitignore`, `App/FocusApp.swift`, `App/RootView.swift` et `FocusAppTests/SmokeTests.swift`, puis générer et compiler.
- **Concepts :** `@main`, protocole `App`, `Scene`, `WindowGroup`, protocole `View`, `body`, `some View`, `#Preview`, `import Testing`
- **Fini quand :** l'app se lance dans le simulateur et affiche « FocusApp », et `xcodebuild test` passe.

## [x] Étape 1 — Fondations : design system, modèles, service, ViewModel, tests
Fichiers de `DesignSystem/`, `Models/`, `Mock/`, `Services/`, `ViewModels/`, `Utilities/`, ainsi que `HomeViewModelTests`.
`HomeView` affiche pour l'instant une version brute (textes empilés) pour prouver que les données circulent, avec un `ProgressView()` pendant le chargement.
- **Concepts :** `struct` vs `class` (types valeur et référence), `let` / `var`, `Identifiable`, computed properties, `enum` comme namespace, enums avec valeurs associées (`LoadState`), `protocol`, injection de dépendance via `init`, `async` / `await`, `.task {}`, `@Observable`, `@MainActor`, `@State` qui détient un objet, extensions (`Color`, `Font`), `#expect`
- **Fini quand :** les données mock s'affichent après le chargement simulé, et les 4 groupes de tests d'`ARCHITECTURE.md` passent.

## [x] Étape 2 — Header
Fond d'écran (dégradé + taches floues), `CircleIconButton` (recherche, notification avec point), salutation, titre + 👋, sous-titre, avatar.
- **Concepts :** `VStack` / `HStack` / `ZStack`, `Spacer`, `alignment`, `padding`, `frame`, `clipShape`, `overlay` vs `background`, ordre des modifiers, `Image(systemName:)`, `Image("Asset")`, `Button`, `.accessibilityLabel`
- **Fini quand :** le header ressemble à la maquette sur la capture.

## [x] Étape 3 — Cartes de stats
`StatCardView` réutilisable, modifier `.glassCard()`, trois cartes dans un `HStack` de même largeur, valeur « 6h 24m » en typo mixte, chevauchement de l'avatar.
- **Concepts :** composant paramétré (≈ props), `ViewModifier` et extension `View` (≈ HOC ou composant wrapper), `.ultraThinMaterial`, `frame(maxWidth: .infinity)`, concaténation de `Text` ou `AttributedString`, `zIndex` et offset
- **Fini quand :** les trois cartes sont égales, l'effet verre est visible et l'avatar chevauche correctement.

## [x] Étape 4 — Carte « Today's Goal »
`GoalCardView` + `ProgressBarView` : dégradé, image `GoalMountain` en calque, textes, barre de progression, bouton ›.
- **Concepts :** `LinearGradient`, `GeometryReader` (largeur de la barre ≈ `onLayout`), `Capsule`, superposition dans un `ZStack`, `shadow`, interpolation de chaînes dans `Text`
- **Fini quand :** la carte correspond à la maquette et la barre reflète `goal.progress`.

## [x] Étape 5 — Liste de tâches interactive
`SectionHeaderView` (« My Tasks » + « See All ») et `TaskRowView` (cercle, textes, menu ⋮). Cocher une tâche met à jour le ViewModel, donc `tasksDone`. Formatage « Today, 10:00 AM ».
- **Concepts :** `ForEach` (≈ `.map` + `key`), closures passées en props, `withAnimation`, `contentTransition`, `.sensoryFeedback` (haptique), `Menu` pour ⋮ (actions mock), `Date.FormatStyle`
- **Fini quand :** cocher et décocher fonctionne avec une animation, et le compteur « Tasks Done » suit.

## [x] Étape 6 — Tab bar et navigation
`AppTab` (enum), `CustomTabBar`, bouton + flottant, `RootView` qui bascule entre `HomeView` et des `PlaceholderScreen`.
- **Concepts :** `@Binding` (≈ `value` + `onChange`), `enum` + `CaseIterable`, `safeAreaInset(edge: .bottom)`, `matchedGeometryEffect` pour la pastille de l'onglet actif
- **Fini quand :** le changement d'onglet fonctionne, le bouton + est surélevé et le contenu n'est pas masqué par la barre.

## [x] Étape 7 — Finitions
Comparaison fine avec la maquette, animations d'apparition, états de chargement soignés (`redacted(reason: .placeholder)`), pull-to-refresh (`.refreshable`), passe d'accessibilité (VoiceOver).
- **Concepts :** `.transition`, `.animation(_:value:)`, `.redacted`, `.refreshable`
- **Fini quand :** le développeur valide la fidélité visuelle.

---

# Phase 2 : les autres écrans (source : canvas Claude Design « FocusApp — Écrans »)

Source de design : https://claude.ai/artifact/RDVEnKPgzbb23GAKCTAMwg (14 écrans, 390×844). Décisions associées : D-028 à D-032. Même méthode qu'en phase 1 : une étape à la fois, pause pour validation, commit à la fin de chaque étape.

## [x] Étape 8 — Alignement sur le design + feuille « New Task »
Tokens mis à jour (D-029), puis `TaskItem` étendu (catégorie, priorité, durée, rappel), `addTask` dans le ViewModel, et la feuille « New Task » ouverte par le bouton +.
- **Concepts :** `.sheet`, `@FocusState`, validation de formulaire, `Picker`, `Toggle`, `DatePicker`, `presentationDetents`
- **Fini quand :** le bouton + ouvre la feuille, « Create Task » est désactivé tant que le titre est vide, et la nouvelle tâche apparaît dans « My Tasks » (testé).

## [x] Étape 9 — Navigation secondaire et écran Notifications
`NavigationStack` avec une route typée : cloche → Notifications, carte Focus Time → Focus Session (écran provisoire), flèche de l'objectif → onglet Analytics, « See All » → onglet Calendar. Écran Notifications : groupes « Today / Earlier », points non lus, « Mark all as read ».
- **Concepts :** `NavigationStack`, `navigationDestination`, `@Environment(\.dismiss)`, sections groupées
- **Fini quand :** chaque lien du prototype mène au bon écran et « Mark all as read » met à jour l'état (testé).

## [x] Étape 10 — Focus Session
Minuteur 25:00 avec anneau de progression, pause / reset / skip, « Session 2 of 4 ». Logique testable : horloge injectée, machine à états.
- **Concepts :** `trim(from:to:)`, `Task.sleep` annulable, machine à états (`enum`), `monospacedDigit`
- **Fini quand :** le minuteur décompte, se met en pause et se réinitialise, et les transitions d'état sont testées.

## [x] Étape 11 — Calendar
Titre + « Today », navigation de semaine, bandeau des 7 jours (jour sélectionné, points), liste horaire avec pastilles de catégorie et ligne « maintenant ».
- **Concepts :** `Calendar` / `DateComponents`, `LazyVGrid`, sélection par `@State`, `Date.FormatStyle`
- **Fini quand :** changer de jour met à jour la liste, et le calcul de semaine est testé.

## [x] Étape 12 — Analytics
Sélecteur Week / Month / Year, graphe de focus par jour (barre du jour en dégradé et infobulle), anneau 9/12, meilleure série, temps par catégorie.
- **Concepts :** **Swift Charts** (`Chart`, `BarMark`), `Picker` segmenté, données agrégées dans le ViewModel
- **Fini quand :** les trois périodes affichent des données mock cohérentes et les agrégats sont testés.

## [x] Étape 13 — Profile et réglages
Avatar, e-mail, trois stats, interrupteur Notifications, lignes Daily goal / Focus session / Appearance, Help & Support, « Log out » (destructif).
- **Concepts :** `Toggle`, `@AppStorage`, `Stepper` / `Picker`, groupes de lignes réutilisables
- **Fini quand :** les réglages sont persistés entre deux lancements et « Log out » est branché (le flux d'entrée arrive à l'étape 14).

## [x] Étape 14 — Parcours d'entrée : Splash, Onboarding, Log In, Sign Up
Splash animé (anneau qui se dessine, coche, nom et slogan), onboarding en 3 pages avec « Skip », formulaires Log In / Sign Up avec validation, état « connecté » **fictif** (service mock, persisté localement). `RootView` choisit entre entrée et app.
- **Concepts :** `TabView(.page)`, `TextField` / `SecureField`, `@FocusState`, `accessibilityReduceMotion`, protocole `AuthProviding` mock, `@AppStorage`
- **Fini quand :** Splash → Onboarding → Sign Up / Log In → Home fonctionne, « Log out » ramène à Log In, et les règles de validation sont testées.

## [x] Étape 15 — Launch screen
L'icône `AppIcon` 1024×1024 est déjà faite (D-034). Reste le launch screen statique, au même dégradé que le Splash, pour que le passage lancement → Splash animé soit continu.
- **Concepts :** `INFOPLIST_KEY_UILaunchScreen_*`, couleur et image de launch screen dans l'asset catalog
- **Fini quand :** l'app démarre sur le dégradé (et non plus sur un écran blanc) avant d'afficher le Splash.

---

## Bonus (au choix, après validation)
- [x] Bouton + : une `sheet` pour ajouter une tâche → devenu l'étape 8
- [ ] Persistance avec **SwiftData** (`@Model`, `@Query`) en remplacement du mock
- [ ] Dark mode (tokens adaptatifs)
- [ ] Dynamic Type complet
- [ ] Passage en Swift 6 language mode
- [x] Navigation « See All » avec `NavigationStack` → intégré aux étapes 9 et 11
