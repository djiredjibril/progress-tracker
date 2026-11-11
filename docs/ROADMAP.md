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

## [ ] Étape 7 — Finitions
Comparaison fine avec la maquette, animations d'apparition, états de chargement soignés (`redacted(reason: .placeholder)`), pull-to-refresh (`.refreshable`), passe d'accessibilité (VoiceOver).
- **Concepts :** `.transition`, `.animation(_:value:)`, `.redacted`, `.refreshable`
- **Fini quand :** le développeur valide la fidélité visuelle.

---

## Bonus (au choix, après validation)
- [ ] Bouton + : une `sheet` pour ajouter une tâche (formulaire, `@FocusState`, validation)
- [ ] Persistance avec **SwiftData** (`@Model`, `@Query`) en remplacement du mock
- [ ] Dark mode (tokens adaptatifs)
- [ ] Dynamic Type complet
- [ ] Passage en Swift 6 language mode
- [ ] Navigation « See All » avec `NavigationStack`
