# Concepts Swift ↔ React

Glossaire tenu à jour par Claude Code. **Un concept listé ici ne sera plus ré-expliqué en commentaire dans le code** : le code y renvoie avec `// ⚛️ voir CONCEPTS.md#ancre`.

Format d'une entrée :

```markdown
### <ancre> · <Nom du concept>
- **Swift :** `extrait minimal`
- **React/RN :** équivalent le plus proche
- **Différence clé :** ce qui change vraiment (ou « aucune »)
- **Vu à :** étape N, fichier `Chemin/Fichier.swift`
```

---

<!-- Les entrées sont ajoutées ci-dessous, dans l'ordre d'apparition. -->

### main · `@main` (point d'entrée)
- **Swift :** `@main struct FocusApp: App { … }`
- **React/RN :** `AppRegistry.registerComponent(...)` ou `index.js` qui monte le composant racine
- **Différence clé :** c'est un attribut du compilateur sur un type, pas un appel de fonction. Un seul `@main` par application.
- **Vu à :** étape 0, `FocusApp/App/FocusApp.swift`

### app-protocol · Protocole `App`, `Scene`, `WindowGroup`
- **Swift :** `struct FocusApp: App { var body: some Scene { WindowGroup { RootView() } } }`
- **React/RN :** `<NavigationContainer>` ou `root.render(<App />)`
- **Différence clé :** `App` est un *protocole* (≈ interface TypeScript) qui impose une propriété `body`. `Scene` représente une fenêtre de l'app, concept sans équivalent RN. `WindowGroup` crée la fenêtre principale et y monte la vue racine.
- **Vu à :** étape 0, `FocusApp/App/FocusApp.swift`

### view · Protocole `View`, `body`, `some View`
- **Swift :** `struct RootView: View { var body: some View { Text("…") } }`
- **React/RN :** un composant fonction qui `return (<Text>…</Text>)`
- **Différence clé :** une vue est une `struct` (type valeur léger, recréé à chaque rendu), pas une fonction. `body` est une propriété calculée que SwiftUI rappelle quand l'état change. `some View` signifie « un type de vue précis déduit par le compilateur », vérifié statiquement (≈ `JSX.Element`, en plus strict). Pas de JSX : on enchaîne des *modifiers*.
- **Vu à :** étape 0, `FocusApp/App/RootView.swift`

### preview · `#Preview`
- **Swift :** `#Preview { RootView() }`
- **React/RN :** une story Storybook
- **Différence clé :** le rendu s'affiche dans le canevas d'Xcode, sans lancer l'app. Le code est exclu du build de production.
- **Vu à :** étape 0, `FocusApp/App/RootView.swift`

### swift-testing · Swift Testing (`@Test`, `#expect`)
- **Swift :** `@Test func ok() { #expect(1 + 1 == 2) }`
- **React/RN :** Jest/Vitest : `test("…", () => { expect(…).toBe(…) })`
- **Différence clé :** `@Test` remplace le préfixe `test` de XCTest. `#expect` est une macro qui affiche les valeurs des deux côtés en cas d'échec, sans matchers à apprendre. Fourni par le SDK, rien à installer.
- **Vu à :** étape 0, `FocusAppTests/SmokeTests.swift`

### extension · `extension` (Color, Font, Date)
- **Swift :** `extension Color { static let appPrimary = Color(hex: 0x6C6CF5) }`
- **React/RN :** augmentation de module TypeScript, ou un `theme` branché sur un objet qu'on ne possède pas
- **Différence clé :** on ajoute des membres à un type existant (même d'Apple) sans le modifier ni en hériter.
- **Vu à :** étape 1, `DesignSystem/Colors.swift`, `Typography.swift`, `Utilities/Date+Formatting.swift`

### let-var-static · `let`, `var`, `static let`, `init` avec valeurs par défaut
- **Swift :** `let id: UUID`, `var title: String`, `static let appPrimary`, `init(hex: UInt32, opacity: Double = 1)`
- **React/RN :** `const` / `let`, `export const colors = {…}`, paramètres par défaut
- **Différence clé :** `let` est une vraie constante par propriété. Les labels d'arguments (`hex:`, `opacity:`) sont obligatoires à l'appel, comme un objet de props.
- **Vu à :** étape 1, `DesignSystem/Colors.swift`, `Models/TaskItem.swift`

### enum-namespace · `enum` sans case comme espace de noms
- **Swift :** `enum Spacing { static let screen: CGFloat = 20 }`
- **React/RN :** `export const Spacing = { screen: 20 } as const`
- **Différence clé :** un enum sans case ne peut pas être instancié par erreur, contrairement à une `struct`.
- **Vu à :** étape 1, `DesignSystem/Layout.swift`, `Mock/MockData.swift`

### struct-vs-class · `struct` (valeur) vs `class` (référence)
- **Swift :** `struct User { var firstName: String }` / `final class HomeViewModel`
- **React/RN :** `{ ...obj }` (copie) vs un objet JS partagé par référence
- **Différence clé :** une `struct` est copiée à l'assignation, donc l'immutabilité est gratuite. Seul le ViewModel est une `class`, car il doit être partagé et observé (D-008). L'initialiseur d'une `struct` est généré automatiquement.
- **Vu à :** étape 1, `Models/User.swift`, `ViewModels/HomeViewModel.swift`

### computed-property · Propriété calculée
- **Swift :** `var focusHours: Int { Int(focusTime) / 3600 }`
- **React/RN :** un getter de classe, ou une valeur dérivée plutôt qu'un `useState` de plus
- **Différence clé :** recalculée à chaque lecture, jamais stockée, donc jamais désynchronisée.
- **Vu à :** étape 1, `Models/UserStats.swift`

### identifiable · `Identifiable` et `Hashable`
- **Swift :** `struct TaskItem: Identifiable, Hashable { let id: UUID }`
- **React/RN :** la `key` d'une liste ; pouvoir utiliser l'objet comme clé de `Map`/`Set`
- **Différence clé :** la clé est portée par le type (propriété `id`), donc `ForEach(tasks)` n'a pas besoin qu'on la précise.
- **Vu à :** étape 1, `Models/TaskItem.swift`

### protocol · `protocol` et injection de dépendance
- **Swift :** `protocol HomeDataProviding { func fetchHomeData() async throws -> HomeData }`, `init(provider: HomeDataProviding = …)`
- **React/RN :** une `interface` TypeScript ; passer le service en argument du hook (`useHome(api = realApi)`)
- **Différence clé :** un type promet de respecter le protocole. On dépend du protocole, on injecte l'implémentation par l'`init` (mock en test et en preview).
- **Vu à :** étape 1, `Services/HomeDataProviding.swift`, `ViewModels/HomeViewModel.swift`

### async-await · `async` / `await` / `throws`
- **Swift :** `func fetchHomeData() async throws -> HomeData`, `try await Task.sleep(for: delay)`
- **React/RN :** `async function` qui renvoie une `Promise` ; `await new Promise(r => setTimeout(r, ms))`
- **Différence clé :** `throws` apparaît dans la signature et l'appelant doit écrire `try` (imposé par le compilateur). `do { try … } catch { … }` remplace `try/catch` JS.
- **Vu à :** étape 1, `Services/MockHomeDataProvider.swift`

### enum-associated · `enum` avec valeurs associées (`LoadState`)
- **Swift :** `enum LoadState: Equatable { case idle, loading, loaded, failed(String) }`
- **React/RN :** union discriminée TypeScript `{ status: 'failed', message: string } | …`
- **Différence clé :** un `switch` doit traiter tous les cas, et un état incohérent est impossible à écrire.
- **Vu à :** étape 1, `ViewModels/HomeViewModel.swift`, `Views/Home/HomeView.swift`

### optional · Optionnels (`?`, `if let`, `guard`)
- **Swift :** `private(set) var data: HomeData?`, `if let data = viewModel.data { … }`, `guard … else { return }`
- **React/RN :** `HomeData | null`, `if (data) { … }`
- **Différence clé :** le compilateur interdit d'utiliser un optionnel sans avoir géré `nil`. `private(set)` = lisible partout, modifiable seulement dans le type.
- **Vu à :** étape 1, `ViewModels/HomeViewModel.swift`

### observable · `@Observable`
- **Swift :** `@Observable final class HomeViewModel { var state … }`
- **React/RN :** un store Zustand / un custom hook
- **Différence clé :** SwiftUI suit les propriétés lues dans `body` et ne re-rend que les vues concernées. Pas de `setState` ni de sélecteur : on modifie les propriétés.
- **Vu à :** étape 1, `ViewModels/HomeViewModel.swift`

### main-actor · `@MainActor`
- **Swift :** `@MainActor final class HomeViewModel`
- **React/RN :** pas d'équivalent (JS n'a qu'un thread)
- **Différence clé :** le compilateur garantit que l'état de l'écran n'est touché que depuis le thread principal. Les tests qui l'utilisent sont aussi `@MainActor`.
- **Vu à :** étape 1, `ViewModels/HomeViewModel.swift`, `FocusAppTests/HomeViewModelTests.swift`

### state · `@State` qui détient un objet
- **Swift :** `@State private var viewModel: HomeViewModel`
- **React/RN :** `useState` / `useRef` initialisé une fois
- **Différence clé :** la vue possède l'objet et le conserve entre les rendus, sans quoi il serait recréé à chaque rendu. Pas de setter. Pour l'initialiser depuis un paramètre : `_viewModel = State(initialValue: …)`.
- **Vu à :** étape 1, `Views/Home/HomeView.swift`

### task-modifier · `.task { }`
- **Swift :** `.task { await viewModel.load() }`
- **React/RN :** `useEffect(() => { load() }, [])`
- **Différence clé :** le bloc est `async`, et il est annulé automatiquement quand la vue disparaît.
- **Vu à :** étape 1, `Views/Home/HomeView.swift`

### viewbuilder · `@ViewBuilder`, `switch`, `ForEach`, `Button`, interpolation
- **Swift :** `@ViewBuilder var content: some View { switch state { … } }`, `ForEach(tasks) { … }`, `"Hello, \(name)"`
- **React/RN :** une fonction `renderContent()`, `tasks.map(t => <Row key={t.id} />)`, `${name}`
- **Différence clé :** `@ViewBuilder` permet plusieurs vues et des `switch` dans une propriété. La vue envoie des intentions au ViewModel (`Button { viewModel.toggle(task) }`) et ne modifie jamais les données elle-même.
- **Vu à :** étape 1, `Views/Home/HomeView.swift`

### date-format-style · `Date.FormatStyle`
- **Swift :** `date.formatted(.dateTime.hour().minute().locale(locale))`
- **React/RN :** `Intl.DateTimeFormat` / `date-fns`
- **Différence clé :** on compose les champs voulus et le format s'adapte à la locale (forcée en `en_US` pour coller à la maquette).
- **Vu à :** étape 1, `Utilities/Date+Formatting.swift`

### testable-parameterized · `@testable import`, `@Test(arguments:)`, `#require`
- **Swift :** `@Test(arguments: [(8, "Good Morning"), …]) func greeting(hour:expected:)`, `try #require(x)`
- **React/RN :** `test.each([[8, '…'], …])` ; un `expect(x).toBeDefined()` qui interrompt le test
- **Différence clé :** `#require` déballe un optionnel ou arrête le test proprement. `@testable import` donne accès aux éléments internes du module testé.
- **Vu à :** étape 1, `FocusAppTests/HomeViewModelTests.swift`

### stacks · `VStack` / `HStack` / `ZStack`, `Spacer`, `alignment`
- **Swift :** `HStack(alignment: .top, spacing: Spacing.m) { … Spacer() … }`
- **React/RN :** `<View style={{ flexDirection: 'row', alignItems, gap }}>`, `<View style={{ flex: 1 }} />`
- **Différence clé :** `VStack` = colonne, `HStack` = ligne, `ZStack` = empilement (≈ `position: 'absolute'` sans top/left). `Spacer` prend l'espace libre. Pas de flexbox global : chaque conteneur choisit son axe.
- **Vu à :** étape 2, `Views/Home/Components/HomeHeaderView.swift`, `Views/Shared/AppBackground.swift`

### modifiers-order · Modifiers, `frame`, `padding` et leur ordre
- **Swift :** `.frame(width: 44, height: 44).background(Circle().fill(…)).padding(…)`
- **React/RN :** `style={{ width, height, padding }}`
- **Différence clé :** chaque modifier enveloppe la vue précédente, donc **l'ordre compte** (`padding` puis `background` ≠ `background` puis `padding`). `frame(maxWidth: .infinity)` ≈ `flex: 1` / `alignSelf: 'stretch'`.
- **Vu à :** étape 2, `CircleIconButton.swift`, `AppBackground.swift`

### background-overlay · `background` vs `overlay`
- **Swift :** `.background(Circle().fill(…))`, `.overlay(alignment: .topTrailing) { badge }`
- **React/RN :** un enfant `position: 'absolute'` derrière / devant
- **Différence clé :** les deux se calent sur la taille de la vue et acceptent un `alignment`, sans qu'on dimensionne la couche soi-même.
- **Vu à :** étape 2, `CircleIconButton.swift`

### image · `Image(systemName:)`, `Image("Asset")`, `clipShape`
- **Swift :** `Image("Avatar").resizable().scaledToFill().frame(…).clipShape(Circle())`
- **React/RN :** `<Image source={require(…)} resizeMode="cover" />` + `borderRadius` + `overflow: 'hidden'`
- **Différence clé :** `resizable()` est obligatoire pour redimensionner. `Image(systemName:)` affiche un SF Symbol qui suit la police et la couleur du texte (≈ vector-icons intégré à l'OS). Poser le `frame` AVANT `clipShape`.
- **Vu à :** étape 2, `CircleIconButton.swift`, `HomeHeaderView.swift`

### button-a11y · `Button`, `buttonStyle(.plain)`, `accessibilityLabel`
- **Swift :** `Button(action: action) { Image(…) }.buttonStyle(.plain).accessibilityLabel("Search")`
- **React/RN :** `<Pressable onPress accessibilityLabel="Search">`
- **Différence clé :** le style par défaut applique une teinte d'accent et un flash au toucher, `.plain` les retire. Un bouton qui n'a qu'une icône DOIT avoir un label, sinon VoiceOver ne sait pas quoi annoncer. `() -> Void` est le type d'une closure `onPress`.
- **Vu à :** étape 2, `CircleIconButton.swift`

### props · Composant présentationnel (props par `let`)
- **Swift :** `struct CircleIconButton: View { let systemName: String; var showsBadge = false; let action: () -> Void }`
- **React/RN :** `function CircleIconButton({ systemName, showsBadge = false, onPress })`
- **Différence clé :** les props sont les propriétés de la `struct`, et l'`init` est généré dans l'ordre de déclaration. Une valeur par défaut rend l'argument facultatif.
- **Vu à :** étape 2, `CircleIconButton.swift`, `HomeHeaderView.swift`

### gradient-blur · `LinearGradient`, `blur`, `ignoresSafeArea`
- **Swift :** `LinearGradient(colors:startPoint:endPoint:)`, `.blur(radius:)`, `.ignoresSafeArea()`
- **React/RN :** `expo-linear-gradient`, `BlurView`, `StyleSheet.absoluteFill` plein écran
- **Différence clé :** un dégradé est une vue qui remplit l'espace disponible. SwiftUI respecte la safe area par défaut (≈ `SafeAreaView`), `ignoresSafeArea` laisse le fond passer derrière l'encoche.
- **Vu à :** étape 2, `Views/Shared/AppBackground.swift`

### color-scheme · `preferredColorScheme`
- **Swift :** `.preferredColorScheme(.light)`
- **React/RN :** `userInterfaceStyle: 'light'` d'Expo
- **Différence clé :** posé à la racine, il s'applique à toute l'app et ignore le mode sombre du téléphone (D-014).
- **Vu à :** étape 2, `App/RootView.swift`

### view-modifier · `ViewModifier` + `extension View`
- **Swift :** `struct GlassCard: ViewModifier { func body(content: Content) -> some View { … } }` + `extension View { func glassCard() … }`
- **React/RN :** un HOC `withGlass(Component)` ou un composant wrapper `<GlassCard>{children}</GlassCard>`
- **Différence clé :** `content` joue le rôle de `children`. L'extension de `View` rend le modifier disponible sur TOUTES les vues, donc il s'enchaîne comme `.padding()` au lieu d'imbriquer des composants.
- **Vu à :** étape 3, `DesignSystem/GlassCard.swift`

### material · `.ultraThinMaterial`, `shadow`, `RoundedRectangle(style: .continuous)`
- **Swift :** `shape.fill(.ultraThinMaterial).overlay(shape.fill(Color.glassFill)).shadow(color:radius:y:)`
- **React/RN :** `<BlurView>` d'expo-blur, `shadow*` / `elevation`, `borderCurve: 'continuous'`
- **Différence clé :** le matériau floute ce qui est DERRIÈRE la carte et s'adapte tout seul au clair/sombre. `.continuous` donne les coins « squircle » d'iOS.
- **Vu à :** étape 3, `DesignSystem/GlassCard.swift`

### attributed-string · `AttributedString` (texte riche)
- **Swift :** `var n = AttributedString("6"); n.font = .appStatValue; result += n; Text(result)`
- **React/RN :** du texte imbriqué `<Text><Text style={big}>6</Text><Text style={small}>h</Text></Text>`
- **Différence clé :** on construit des « runs » avec chacun leur police, concaténés dans UN seul texte (alignés sur la ligne de base). `Text + Text` existe mais est déprécié dans les SDK récents.
- **Vu à :** étape 3, `Views/Home/Components/StatCardView.swift`

### zindex-offset · `offset` et `zIndex`
- **Swift :** `.offset(y: Size.avatarOverlap)` et `.zIndex(1)`
- **React/RN :** `transform: [{ translateY }]` et `zIndex`
- **Différence clé :** `offset` déplace le dessin SANS changer la place réservée dans la mise en page, donc la vue déborde sur ses voisines. Dans un stack, les vues suivantes se dessinent par-dessus, d'où le `zIndex` pour garder l'avatar au-dessus.
- **Vu à :** étape 3, `HomeHeaderView.swift`, `HomeView.swift`

### a11y-combine · `accessibilityElement(children: .combine)`
- **Swift :** `.accessibilityElement(children: .combine)`, `.accessibilityHidden(true)`
- **React/RN :** `accessible={true}` sur le conteneur
- **Différence clé :** fusionne les enfants en un seul élément : VoiceOver lit « 12, Tasks Done » d'un trait, et l'icône décorative est masquée.
- **Vu à :** étape 3, `StatCardView.swift`

### geometry-reader · `GeometryReader`
- **Swift :** `GeometryReader { proxy in … proxy.size.width * progress … }`
- **React/RN :** `onLayout` + un `useState` pour stocker la largeur
- **Différence clé :** la taille est disponible dès le rendu, sans état ni second rendu. Attention : il s'étire pour remplir tout l'espace proposé, d'où le `frame(height:)` posé dessus.
- **Vu à :** étape 4, `Views/Home/Components/ProgressBarView.swift`, `GoalCardView.swift`

### capsule · `Capsule`, `Label`, `scaledToFit`
- **Swift :** `Capsule().fill(…)`, `Label("Today's Goal", systemImage: "target")`, `Image("GoalMountain").resizable().scaledToFit()`
- **React/RN :** `borderRadius` maximal, une icône + un texte dans un `<View row>`, `resizeMode="contain"`
- **Différence clé :** `Capsule` adapte ses coins à la hauteur sans calcul. `Label` associe icône et texte et les aligne seul.
- **Vu à :** étape 4, `ProgressBarView.swift`, `GoalCardView.swift`

### layered-card · Carte en couches (`background` + `overlay` + `clipShape` + `shadow`)
- **Swift :** `shape.fill(gradient).overlay { mountain.clipShape(shape) }.shadow(…)`
- **React/RN :** un conteneur `overflow: 'hidden'` avec des enfants `position: 'absolute'`, et l'ombre sur un conteneur frère (car `overflow` coupe l'ombre en RN)
- **Différence clé :** on clippe seulement la montagne puis on ajoute l'ombre sur la forme, donc l'ombre n'est pas coupée. Le bouton est un `overlay(alignment: .trailing)`, donc au-dessus de la montagne.
- **Vu à :** étape 4, `Views/Home/Components/GoalCardView.swift`

### with-animation · `withAnimation`, propriétés animables, `contentTransition`
- **Swift :** `withAnimation(.snappy) { viewModel.toggle(task) }`, `.opacity(isCompleted ? 1 : 0)`, `.contentTransition(.numericText())`
- **React/RN :** `LayoutAnimation.configureNext(...)` / `Animated.timing` avec une `Animated.Value`
- **Différence clé :** pas d'`Animated.Value` à créer : tout ce qui change d'état dans le bloc `withAnimation` est interpolé automatiquement (opacity, scale, position…). `numericText` fait défiler les chiffres, sans équivalent RN direct.
- **Vu à :** étape 5, `Views/Home/HomeView.swift`, `TaskRowView.swift`, `StatCardView.swift`

### sensory-feedback · `.sensoryFeedback`
- **Swift :** `.sensoryFeedback(.selection, trigger: task.isCompleted)`
- **React/RN :** `Haptics.selectionAsync()` d'expo-haptics
- **Différence clé :** déclaratif : le retour haptique se déclenche à chaque CHANGEMENT du `trigger`, pas par un appel impératif dans le handler. Sans effet dans le simulateur, à tester sur un vrai iPhone.
- **Vu à :** étape 5, `Views/Home/Components/TaskRowView.swift`

### menu · `Menu`, `Button(role:)`
- **Swift :** `Menu { Button("Delete", systemImage: "trash", role: .destructive, action: onDelete) } label: { Image(systemName: "ellipsis") }`
- **React/RN :** un `ActionSheet` / menu contextuel natif
- **Différence clé :** menu natif iOS ancré sur le bouton. `role: .destructive` colore l'action en rouge. `rotationEffect(.degrees(90))` transforme ⋯ en ⋮ sans changer la mise en page.
- **Vu à :** étape 5, `Views/Home/Components/TaskRowView.swift`

### hit-area · `contentShape` et baseline
- **Swift :** `.contentShape(Circle().inset(by: -Spacing.s))`, `HStack(alignment: .firstTextBaseline)`
- **React/RN :** `hitSlop`, `alignItems: 'baseline'`
- **Différence clé :** on agrandit la zone tactile au-delà de la forme visible (inset négatif). La ligne de base aligne un gros titre et un petit lien sur la même ligne d'écriture.
- **Vu à :** étape 5, `TaskRowView.swift`, `SectionHeaderView.swift`
