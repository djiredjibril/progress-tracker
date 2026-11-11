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

### binding · `@Binding`
- **Swift :** `@Binding var selection: AppTab` ; le parent le passe avec `$selectedTab`
- **React/RN :** passer `value` ET `onChange` en props, regroupés en un seul objet
- **Différence clé :** le parent possède l'état (`@State`), l'enfant peut le lire ET l'écrire (`selection = tab`) et le parent se re-rend. `$` crée le binding depuis le `@State`.
- **Vu à :** étape 6, `Views/Shared/CustomTabBar.swift`, `App/RootView.swift`

### enum-caseiterable · `enum` + `CaseIterable` + propriétés calculées
- **Swift :** `enum AppTab: String, CaseIterable, Identifiable { case home … ; var title: String { switch self { … } } }`
- **React/RN :** `type Tab = 'home' | 'calendar'…` + `Object.values(Tab)` + un `Record<Tab, string>`
- **Différence clé :** l'enum porte ses propres propriétés calculées. `allCases` donne la liste dans l'ordre de déclaration. Chaque `switch` doit couvrir tous les cas : ajouter un onglet fait signaler par le compilateur tous les endroits à compléter.
- **Vu à :** étape 6, `Views/Shared/AppTab.swift`

### safe-area-inset · `safeAreaInset(edge: .bottom)`
- **Swift :** `.safeAreaInset(edge: .bottom) { CustomTabBar(…) }`
- **React/RN :** `contentContainerStyle={{ paddingBottom }}` + une vue `position: 'absolute'`
- **Différence clé :** on réserve la place ET on la déclare au contenu : le `ScrollView` ajoute tout seul sa marge basse, sans calculer la hauteur de la barre.
- **Vu à :** étape 6, `App/RootView.swift`

### matched-geometry · `@Namespace` + `matchedGeometryEffect`
- **Swift :** `.matchedGeometryEffect(id: "activeTabPill", in: pillNamespace)` dans un `withAnimation`
- **React/RN :** mesurer chaque onglet avec `onLayout` puis animer une pastille à la main (Reanimated)
- **Différence clé :** deux vues avec le même `id` dans le même namespace sont considérées comme LA MÊME : SwiftUI la fait glisser de l'une à l'autre au lieu de la supprimer puis de la recréer.
- **Vu à :** étape 6, `Views/Shared/CustomTabBar.swift`

### keep-mounted · Garder une vue montée vs la démonter
- **Swift :** `HomeView().opacity(selected ? 1 : 0).allowsHitTesting(selected).accessibilityHidden(!selected)`
- **React/RN :** `display: 'none'` plutôt que `{tab === 'home' && <Home />}`
- **Différence clé :** un `switch` détruit la vue et donc son `@State` (ViewModel, tâches cochées). Masquer la vue conserve l'état entre les onglets.
- **Vu à :** étape 6, `App/RootView.swift`

### previewable · `@Previewable` et piège de `Color.clear`
- **Swift :** `#Preview { @Previewable @State var selection = AppTab.home … }`, `Color.clear.frame(width: 64, height: 0)`
- **React/RN :** un `useState` dans une story ; un `<View style={{ flex: 1 }} />` sans hauteur
- **Différence clé :** `@Previewable` rend le `Binding` modifiable dans le canevas. Une vue « couleur » est flexible dans les deux sens : sans `height: 0`, un simple espace réservé s'étire sur tout l'écran.
- **Vu à :** étape 6, `Views/Shared/CustomTabBar.swift`

### redacted · `.redacted(reason: .placeholder)` (skeleton)
- **Swift :** `loadedContent(MockData.homeData).redacted(reason: .placeholder).allowsHitTesting(false)`
- **React/RN :** un composant skeleton écrit à la main (`react-native-skeleton-placeholder`)
- **Différence clé :** SwiftUI remplace chaque texte et chaque image par un bloc gris, donc on réutilise le VRAI écran avec des données mock : le squelette a toujours la bonne forme, sans second composant à maintenir.
- **Vu à :** étape 7, `Views/Home/HomeView.swift`

### environment · `@Environment(\.redactionReasons)`
- **Swift :** `@Environment(\.redactionReasons) private var redactionReasons` puis `redactionReasons.contains(.placeholder)`
- **React/RN :** `useContext`
- **Différence clé :** SwiftUI expose des valeurs système (taille de texte, mode clair/sombre, mode squelette…) que n'importe quelle vue peut lire. Utile pour masquer une image décorative qui deviendrait un gros rectangle gris.
- **Vu à :** étape 7, `Views/Home/Components/GoalCardView.swift`

### refreshable · `.refreshable`
- **Swift :** `.refreshable { await viewModel.refresh() }`
- **React/RN :** `<RefreshControl refreshing onRefresh>` avec un état `refreshing` à gérer
- **Différence clé :** pas d'état à gérer : le spinner reste affiché tant que la closure `async` n'est pas terminée.
- **Vu à :** étape 7, `Views/Home/HomeView.swift`

### transition-animation-value · `.transition` et `.animation(_:value:)`
- **Swift :** `.transition(.opacity.combined(with: .offset(y: 24)))` et `.animation(.smooth, value: viewModel.state)`
- **React/RN :** `entering={FadeIn}` de Reanimated, et une `LayoutAnimation` déclenchée par un changement
- **Différence clé :** `transition` décrit COMMENT une vue entre/sort, mais ne joue que si l'insertion a lieu dans une animation. `animation(_:value:)` attache l'animation à UNE valeur précise : plus prévisible que `withAnimation`, qui anime tout ce qui change dans son bloc.
- **Vu à :** étape 7, `Views/Home/HomeView.swift`

### a11y-pass · Passe VoiceOver (`isHeader`, labels, doublons)
- **Swift :** `.accessibilityAddTraits(.isHeader)`, `.accessibilityLabel(…)`, `.accessibilityHidden(true)` sur les doublons
- **React/RN :** `accessibilityRole="header"`, `accessibilityLabel`
- **Différence clé :** on décide ce que VoiceOver lit : un label par ligne de tâche (titre + échéance) plutôt que trois éléments, pas de « waving hand » après le prénom, et « See All My Tasks » plutôt que « See All » seul.
- **Vu à :** étape 7, `HomeHeaderView.swift`, `SectionHeaderView.swift`, `TaskRowView.swift`, `GoalCardView.swift`

### sheet · `.sheet`, `presentationDetents`, `@Environment(\.dismiss)`
- **Swift :** `.sheet(isPresented: $isAddingTask) { NewTaskView { … } }`, `.presentationDetents([.large])`, `@Environment(\.dismiss) var dismiss`
- **React/RN :** `<Modal visible={isAddingTask}>` ou un bottom sheet, avec `onClose` en prop
- **Différence clé :** SwiftUI remet le booléen à faux tout seul quand on ferme la feuille (le `$` est un binding en lecture ET écriture). `dismiss()` ferme la feuille courante sans qu'on reçoive de callback. Hauteur, poignée, coins et fond se règlent par des modifiers posés sur le CONTENU de la feuille.
- **Vu à :** étape 8, `App/RootView.swift`, `Views/Home/NewTaskView.swift`

### focus-state · `@FocusState`, `TextField` et `Binding` sur une propriété
- **Swift :** `@FocusState private var isTitleFocused: Bool`, `TextField("", text: $draft.title).focused($isTitleFocused)`
- **React/RN :** un `ref` sur le `TextInput` + `ref.focus()` / `onFocus`, et `value` + `onChangeText`
- **Différence clé :** `$draft.title` est un `Binding` sur UNE propriété de la struct : la saisie l'écrit et tout changement du modèle met le champ à jour. `@FocusState` dit quel champ a le focus et permet de le changer par code.
- **Vu à :** étape 8, `Views/Home/NewTaskView.swift`

### form-controls · `DatePicker`, `Menu` + `Picker`, `Toggle`
- **Swift :** `DatePicker("Time", selection: $draft.time, displayedComponents: .hourAndMinute)`, `Menu { Picker(…) { … .tag(minutes) } }`, `Toggle(…, isOn: $draft.remindsBeforeStart)`
- **React/RN :** `datetimepicker`, `<select>`, `<Switch value onValueChange>`
- **Différence clé :** ces contrôles natifs se branchent par `Binding`, sans handler. `.labelsHidden()` retire le libellé visible mais VoiceOver le lit toujours. Le format de l'heure suit la locale du téléphone.
- **Vu à :** étape 8, `Views/Home/NewTaskView.swift`

### button-style · `ButtonStyle` et `@Environment(\.isEnabled)`
- **Swift :** `struct PrimaryButtonStyle: ButtonStyle { func makeBody(configuration:) … }` + `extension ButtonStyle where Self == PrimaryButtonStyle { static var primary … }` → `.buttonStyle(.primary)`
- **React/RN :** un composant `<PrimaryButton>`, mais ici le bouton reste un vrai `Button`
- **Différence clé :** `configuration.label` est le contenu et `configuration.isPressed` l'état d'appui. `isEnabled` se lit dans l'environnement : `.disabled(…)` pâlit le bouton sans prop supplémentaire.
- **Vu à :** étape 8, `Views/Shared/PrimaryButtonStyle.swift`

### generics · Composant générique (`PillSegmentedControl<Option>`)
- **Swift :** `struct PillSegmentedControl<Option: Hashable>: View { @Binding var selection: Option; let options: [Option]; let title: (Option) -> String }`
- **React/RN :** `function SegmentedControl<T>({ value, options, label })` en TypeScript
- **Différence clé :** le même composant sert pour une priorité, une période… et le compilateur vérifie les types. `title: \.title` passe un key path comme fonction.
- **Vu à :** étape 8, `Views/Shared/PillSegmentedControl.swift`

### lifting-state · Remonter l'état (ViewModel possédé par `RootView`)
- **Swift :** `@State private var viewModel` dans `RootView`, passé à `HomeView(viewModel:)` en simple `let`
- **React/RN :** « lifting state up » : déplacer l'état dans le parent commun, ou dans un contexte/store global
- **Différence clé :** une classe `@Observable` reçue en `let` suffit : la vue suit les propriétés qu'elle lit, sans `Binding` ni `useContext`.
- **Vu à :** étape 8, `App/RootView.swift`, `Views/Home/HomeView.swift`

### app-icon · Icône d'app dans l'asset catalog
- **Swift / Xcode :** `Assets.xcassets/AppIcon.appiconset` avec un seul `AppIcon-1024.png` (`"size": "1024x1024"`) et `ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon` dans `project.yml`
- **React/RN :** l'option `icon` d'`app.json` (Expo) / les mipmaps et `AppIcon` générés par `expo prebuild`
- **Différence clé :** une seule image carrée suffit, sans coins arrondis : iOS génère toutes les tailles et applique lui-même le masque et l'effet de verre. Elle doit être **opaque** (sans canal alpha) pour être acceptée par l'App Store.
- **Vu à :** entre les étapes 8 et 9, `Resources/Assets.xcassets/AppIcon.appiconset`

### navigation-stack · `NavigationStack(path:)`, `navigationDestination(for:)`, route typée
- **Swift :** `@State var path: [AppRoute] = []`, `NavigationStack(path: $path) { … .navigationDestination(for: AppRoute.self) { route in … } }`, `path.append(.notifications)`, `path.removeAll()`
- **React/RN :** `<Stack.Navigator>` de React Navigation, `navigation.navigate('Notifications')`, `popToTop()`, et le type `RootStackParamList`
- **Différence clé :** l'état de navigation est un simple tableau que l'on possède. `AppRoute` est un `enum` : un `case` par écran (il peut porter des paramètres), et le `switch` du `navigationDestination` est exhaustif. SwiftUI met le tableau à jour quand l'utilisateur revient en arrière.
- **Vu à :** étape 9, `App/RootView.swift`, `App/AppRoute.swift`

### hidden-nav-bar · Barre de navigation masquée et en-tête maison
- **Swift :** `.toolbar(.hidden, for: .navigationBar)`, `@Environment(\.dismiss)` pour le bouton retour
- **React/RN :** `headerShown: false` et un `<Header>` personnalisé
- **Différence clé :** on dessine son propre en-tête (bouton retour en verre) mais le balayage depuis le bord gauche pour revenir en arrière continue de fonctionner. Si la tab bar est dans le contenu RACINE du `NavigationStack`, un écran empilé la recouvre naturellement.
- **Vu à :** étape 9, `Views/Notifications/NotificationsView.swift`, `Views/Shared/PlaceholderScreen.swift`

### callbacks-navigation · La navigation décidée par le parent
- **Swift :** `HomeView(onNotifications: { path.append(.notifications) }, onGoalDetails: { select(.analytics) })`
- **React/RN :** passer `onPress={() => navigation.navigate(...)}` en props plutôt que d'appeler `useNavigation` dans l'écran
- **Différence clé :** l'écran ne connaît ni la pile ni les onglets : il remonte des intentions. Un écran reste donc testable et prévisualisable seul.
- **Vu à :** étape 9, `Views/Home/HomeView.swift`, `App/RootView.swift`

### any-shape-style · `AnyShapeStyle` et effacement de type
- **Swift :** `private var iconFill: AnyShapeStyle { switch kind { … AnyShapeStyle(LinearGradient(…)) … AnyShapeStyle(Color.tabPill) } }`
- **React/RN :** une union `Color | Gradient` en TypeScript
- **Différence clé :** un `switch` doit renvoyer UN seul type ; `AnyShapeStyle` « efface » le type concret pour pouvoir renvoyer tantôt une couleur, tantôt un dégradé.
- **Vu à :** étape 9, `Views/Notifications/NotificationRowView.swift`

### text-styling · `textCase`, `tracking`, `lineSpacing`, `fixedSize`
- **Swift :** `.textCase(.uppercase).tracking(0.6)`, `.lineSpacing(2)`, `.fixedSize(horizontal: false, vertical: true)`
- **React/RN :** `textTransform: 'uppercase'`, `letterSpacing`, `lineHeight`, et un texte qui grandit avec son contenu
- **Différence clé :** `fixedSize` empêche un texte multiligne d'être tronqué ou compressé par son parent : la hauteur suit le contenu.
- **Vu à :** étape 9, `Views/Notifications/NotificationRowView.swift`, `NotificationsView.swift`

### state-machine · Machine à états et horloge injectée
- **Swift :** `enum Phase { case focus, rest }`, `enum RunState { case idle, running, paused, finished }`, `init(now: @escaping () -> Date = { .now })`
- **React/RN :** `useReducer` avec des états nommés ; `jest.useFakeTimers()`
- **Différence clé :** deux `enum` indépendants (quelle phase, et si ça tourne) remplacent des booléens `isBreak` / `isPaused` incohérents. Le temps restant se déduit de l'horloge (`endDate - now`), pas d'un compteur décrémenté : un tick en retard ou l'arrière-plan ne faussent rien. En test, on avance `now` à la main et on appelle `tick()`, sans attendre.
- **Vu à :** étape 10, `ViewModels/FocusSessionViewModel.swift`, `FocusAppTests/FocusSessionViewModelTests.swift`

### task-id · `.task(id:)` et `Task.sleep` annulable
- **Swift :** `.task(id: viewModel.runState) { while !Task.isCancelled { try? await Task.sleep(for: .milliseconds(500)); viewModel.tick() } }`
- **React/RN :** `useEffect(() => { const id = setInterval(tick, 500); return () => clearInterval(id) }, [runState])`
- **Différence clé :** le bloc redémarre quand `id` change et l'ancien est annulé automatiquement ; `Task.sleep` s'interrompt à l'annulation, donc pas de fuite quand on quitte l'écran. `.onDisappear` joue le rôle du cleanup au démontage.
- **Vu à :** étape 10, `Views/Focus/FocusSessionView.swift`

### trim-ring · `Circle().trim(from:to:)` et `monospacedDigit`
- **Swift :** `Circle().trim(from: 0, to: progress).stroke(gradient, style: StrokeStyle(lineWidth: 16, lineCap: .round)).rotationEffect(.degrees(-90))`, `Font.system(size: 56, weight: .bold).monospacedDigit()`
- **React/RN :** `strokeDasharray` / `strokeDashoffset` d'un `<Circle>` SVG ; `fontVariant: ['tabular-nums']`
- **Différence clé :** `trim` ne dessine qu'une fraction du cercle et est animable, donc l'arc avance de façon fluide sans `Animated.Value`. Le cercle démarre à 3 h : on le tourne de -90°. Des chiffres de même largeur évitent que le minuteur « tremble ».
- **Vu à :** étape 10, `Views/Focus/FocusRingView.swift`, `DesignSystem/Typography.swift`

### viewbuilder-prop · Composant à contenu (`@ViewBuilder` + générique)
- **Swift :** `struct FocusRingView<Center: View>: View { @ViewBuilder let center: () -> Center }`
- **React/RN :** une prop `children` / un render prop
- **Différence clé :** l'appelant place n'importe quelle vue au centre, et le compilateur garde son type exact (pas de `any View` coûteux).
- **Vu à :** étape 10, `Views/Focus/FocusRingView.swift`

### symbol-effect · `contentTransition(.symbolEffect(.replace))` et `.numericText(countsDown:)`
- **Swift :** `Image(systemName: isRunning ? "pause.fill" : "play.fill").contentTransition(.symbolEffect(.replace))`
- **React/RN :** pas d'équivalent direct (animer deux icônes à la main)
- **Différence clé :** le symbole se transforme au lieu de sauter, et les chiffres défilent dans le bon sens pour un compte à rebours.
- **Vu à :** étape 10, `Views/Focus/RoundControlButton.swift`, `FocusSessionView.swift`

### calendar-api · `Calendar`, `dateInterval(of:)`, `DateComponents`
- **Swift :** `calendar.dateInterval(of: .weekOfYear, for: date)`, `calendar.date(byAdding: .day, value: 7, to: date)`, `calendar.isDate(a, inSameDayAs: b)`, `var c = Calendar.current; c.firstWeekday = 2`
- **React/RN :** `date-fns` : `startOfWeek(d, { weekStartsOn: 1 })`, `addDays`, `isSameDay`
- **Différence clé :** tout passe par un `Calendar` qui connaît fuseau, locale et premier jour de semaine : on ne fait jamais `date + 86400`. On l'injecte (`calendar:`) pour des tests déterministes, et `Calendar.mondayFirst` fixe le lundi une fois pour toute l'app.
- **Vu à :** étape 11, `Utilities/Calendar+App.swift`, `ViewModels/CalendarViewModel.swift`

### enum-in-foreach · Union affichée dans un `ForEach` (`ScheduleItem`)
- **Swift :** `enum ScheduleItem: Identifiable { case task(TaskItem), now(Date) }` puis `ForEach(items) { item in switch item { case .task(let t): … case .now(let d): … } }`
- **React/RN :** `items.map(i => i.type === 'task' ? <Row/> : <NowLine/>)` sur une union discriminée
- **Différence clé :** le `switch` est exhaustif : ajouter un cas oblige à le traiter partout. Le repère « maintenant » devient un élément de la liste, inséré par la logique (testée) et non par la vue.
- **Vu à :** étape 11, `ViewModels/CalendarViewModel.swift`, `Views/Calendar/CalendarView.swift`

### date-id-self · `ForEach(days, id: \.self)` et pastille partagée
- **Swift :** `ForEach(days, id: \.self) { day in … }`, `.matchedGeometryEffect(id: "selectedDay", in: namespace)`
- **React/RN :** `key={day}` ; animer une pastille qui glisse (Reanimated / `onLayout`)
- **Différence clé :** une `Date` est `Hashable`, donc elle sert de clé sans `Identifiable`. La pastille du jour sélectionné glisse d'un jour à l'autre (même `id` dans le même namespace, voir CONCEPTS.md#matched-geometry).
- **Vu à :** étape 11, `Views/Calendar/Components/WeekStripView.swift`

### swift-charts · Swift Charts (`Chart`, `BarMark`, axes personnalisés)
- **Swift :** `import Charts` puis `Chart(bars) { bar in BarMark(x: .value("Period", bar.name), y: .value("Focus", bar.seconds), width: .ratio(0.7)).foregroundStyle(…).cornerRadius(10).annotation(position: .top) { tooltip } }`, `.chartYScale(domain:)`, `.chartYAxis(.hidden)`, `.chartXAxis { AxisMarks(values:) { AxisValueLabel { … } } }`
- **React/RN :** Victory / `react-native-chart-kit` / d3
- **Différence clé :** déclaratif et natif (SDK Apple, zéro dépendance, D-011) : pour chaque donnée on décrit une marque et ses propriétés ; échelle, axes et animations sont calculés. Une abscisse de type TEXTE crée des « cases » de largeur égale (échelle `band` de d3) ; avec un nombre, la largeur d'une barre n'était pas définie et les barres disparaissaient. `annotation` ancre un tooltip à la barre. VoiceOver lit chaque marque grâce à `accessibilityLabel/Value`.
- **Vu à :** étape 12, `Views/Analytics/FocusChartCard.swift`

### bindable · `@Bindable`
- **Swift :** `@Bindable var viewModel: AnalyticsViewModel` puis `PillSegmentedControl(selection: $viewModel.period, …)`
- **React/RN :** passer `value` + `onChange` d'un store au composant
- **Différence clé :** un objet `@Observable` reçu en paramètre n'offre pas de `$` par défaut : `@Bindable` permet de créer un `Binding` vers l'une de ses propriétés.
- **Vu à :** étape 12, `Views/Analytics/AnalyticsView.swift`

### aggregation · Agrégation d'un historique (dictionnaire, `reduce`, injection de `todayFocus`)
- **Swift :** `Dictionary(history.map { (calendar.startOfDay(for: $0.date), $0.seconds) }, uniquingKeysWith: +)`, `days.reduce(0) { … }`
- **React/RN :** `groupBy`, `reduce` et un `Map` indexé par date
- **Différence clé :** l'historique est indexé par jour une seule fois. La valeur d'aujourd'hui n'y figure pas : elle est passée à chaque appel, car elle vient de Home et change en direct quand on termine une session de focus.
- **Vu à :** étape 12, `ViewModels/AnalyticsViewModel.swift`

### app-storage · `@AppStorage` (réglages persistés)
- **Swift :** `@AppStorage(SettingsKey.focusMinutes) private var focusMinutes = 25`, `Toggle(…, isOn: $notificationsEnabled)`
- **React/RN :** `useState` + `AsyncStorage` (ou `react-native-mmkv`) lu au démarrage et écrit à chaque changement
- **Différence clé :** une seule ligne : la valeur est relue au lancement, écrite à chaque modification, et TOUTE vue qui utilise la même clé (Profile et `RootView`) se met à jour. C'est synchrone, sans `await` ni provider. Les clés sont regroupées en constantes (`SettingsKey`) pour éviter une faute de frappe qui ne sauvegarderait jamais. Ne fonctionne que dans une vue : un `@Observable` ne peut pas porter un `@AppStorage`.
- **Vu à :** étape 13, `Views/Profile/ProfileView.swift`, `App/RootView.swift`, `Models/SettingsOptions.swift`

### confirmation-dialog · `confirmationDialog`
- **Swift :** `.confirmationDialog("Log out of FocusApp?", isPresented: $flag, titleVisibility: .visible) { Button("Log out", role: .destructive) { … }; Button("Cancel", role: .cancel) {} }`
- **React/RN :** `Alert.alert(title, message, [{ text, style: 'destructive' }, { text: 'Cancel', style: 'cancel' }])`
- **Différence clé :** déclaratif, piloté par un booléen d'état (`isPresented`) ; sur iPhone c'est une feuille d'actions qui monte du bas, l'action `.destructive` est en rouge.
- **Vu à :** étape 13, `Views/Profile/ProfileView.swift`

### settings-row · Lignes de réglage génériques (`SettingsRow<Trailing>`, `SettingsGroup`)
- **Swift :** `SettingsRow(systemImage:…, title:…) { SettingsValueTrailing(value: "5 tasks") }` dans un `Menu { Picker … } label: { … }`
- **React/RN :** un composant `<Row icon title right={…} />` avec une prop render `right`
- **Différence clé :** le contenu de droite est un `@ViewBuilder` (interrupteur, valeur + chevron, rien) et la même ligne sert de label à un `Menu` ou à un `Button`. Le trait de séparation est porté par la ligne (`showsTopDivider`).
- **Vu à :** étape 13, `Views/Profile/SettingsRow.swift`

### reduce-motion · Animation séquencée et `accessibilityReduceMotion`
- **Swift :** `withAnimation(.timingCurve(0.65, 0, 0.35, 1, duration: 1.1).delay(0.2)) { arc = 0.75 }`, `.spring(response:dampingFraction:)`, `.repeatForever(autoreverses: true)`, `@Environment(\.accessibilityReduceMotion)`
- **React/RN :** `Animated.sequence` / `Animated.delay` / `Animated.loop`, `Easing.bezier`, `AccessibilityInfo.isReduceMotionEnabled()`
- **Différence clé :** on enchaîne les étapes en changeant des `@State` dans des `withAnimation` avec des délais : SwiftUI interpole tout seul. Avec « Réduire les animations », on pose directement les valeurs finales. Le Splash passe à la suite à la fin du `.task` OU au toucher (le premier gagne).
- **Vu à :** étape 14, `Views/Entry/SplashView.swift`

### paging-tabview · `TabView(selection:)` en pages
- **Swift :** `TabView(selection: $page) { ForEach(pages) { page in content.tag(page) } }.tabViewStyle(.page(indexDisplayMode: .never))`
- **React/RN :** un `ScrollView horizontal pagingEnabled` / `PagerView` avec un index d'état
- **Différence clé :** le `@State` page est lu ET écrit : glisser change la page, changer la page par code fait glisser. Les points système sont masqués : on dessine les nôtres (le point actif s'allonge).
- **Vu à :** étape 14, `Views/Entry/OnboardingView.swift`

### text-fields · `TextField`, `SecureField`, `@FocusState` sur une enum, `FocusState.Binding`
- **Swift :** `@FocusState private var focused: Field?`, `.focused($focused, equals: .email)`, `.submitLabel(.next)`, `.onSubmit { focused = .password }`, `.textContentType(.emailAddress)`, `.keyboardType(.emailAddress)`
- **React/RN :** `<TextInput secureTextEntry keyboardType autoComplete returnKeyType onSubmitEditing ref />`
- **Différence clé :** un seul `@FocusState` d'enum pilote le champ actif de tout le formulaire. Un composant enfant reçoit le focus du parent par `FocusState<Bool>.Binding`. `Text(verbatim:)` évite que SwiftUI détecte une adresse e-mail dans un texte et la colore comme un lien.
- **Vu à :** étape 14, `Views/Entry/LoginView.swift`, `SignUpView.swift`, `AuthComponents.swift`

### toggle-style · `ToggleStyle` personnalisé
- **Swift :** `struct CheckboxToggleStyle: ToggleStyle { func makeBody(configuration:) … }` + `.toggleStyle(.checkbox)`
- **React/RN :** un composant `<Checkbox checked onChange />`
- **Différence clé :** on redessine un `Toggle` sans perdre son état lié par `Binding`, ni son accessibilité (`.isToggle`).
- **Vu à :** étape 14, `Views/Shared/CheckboxToggleStyle.swift`

### auth-flow · Racine conditionnelle, `.id()` et `UserDefaults` injecté
- **Swift :** `if auth.isLoggedIn { RootView(…).id(session?.email) } else { entry }`, `AuthViewModel(provider:defaults:)`
- **React/RN :** `isSignedIn ? <MainTabs /> : <AuthStack />` ; `key={user.id}` pour tout réinitialiser ; `AsyncStorage` injecté
- **Différence clé :** `.id(valeur)` ≈ `key` : quand il change, SwiftUI détruit et recrée la vue et ses `@State`. Les tests passent une suite `UserDefaults` jetable : rien n'est écrit dans les vrais réglages. `Shape` (`LogoCheckShape`) décrit un tracé comme un `<Path d>` SVG.
- **Vu à :** étape 14, `Views/Entry/AppFlowView.swift`, `ViewModels/AuthViewModel.swift`, `Views/Shared/AppLogoView.swift`

### launch-screen · Launch screen (storyboard + image d'asset)
- **Swift / Xcode :** `LaunchScreen.storyboard` (une `UIImageView` plein écran, `scaleAspectFill`) + `Assets.xcassets/LaunchBackground.imageset`, et `INFOPLIST_KEY_UILaunchStoryboardName: LaunchScreen` dans `project.yml`
- **React/RN :** le `splash` d'`app.json` (Expo : `image`, `backgroundColor`, `resizeMode`)
- **Différence clé :** le launch screen est affiché par iOS AVANT que le code de l'app ne tourne : il ne peut donc pas être animé ni écrit en SwiftUI. On y met le décor fixe (ici le dégradé et les halos), et le `SplashView` SwiftUI y dessine ensuite le logo : le passage est continu. La clé `UILaunchScreen` de l'Info.plist ne sait faire qu'une couleur unie et une image centrée, pas un dégradé plein écran.
- **Vu à :** étape 15, `Resources/LaunchScreen.storyboard`, `Resources/Assets.xcassets/LaunchBackground.imageset`

### sheet-item · `sheet(item:)` et un formulaire à deux modes
- **Swift :** `@State var taskSheet: TaskSheet?` puis `.sheet(item: $taskSheet) { sheet in switch sheet { case .create: NewTaskView { … } case .edit(let task): NewTaskView(editing: task) { … } } }`
- **React/RN :** `<Modal visible={sheet !== null}>` avec les données de la feuille, et des `defaultValues` pour préremplir un formulaire
- **Différence clé :** une seule feuille pour créer ET modifier : l'`enum` à valeurs associées (`create` / `edit(TaskItem)`) dit laquelle est ouverte et porte la tâche. Le brouillon (`NewTaskDraft(editing:)`) garde l'`id` et l'état « fait » de la tâche, donc enregistrer MET À JOUR la tâche au lieu d'en créer une copie.
- **Vu à :** étape 16, `App/RootView.swift`, `Models/NewTaskDraft.swift`, `Views/Home/NewTaskView.swift`

### confirm-item · `confirmationDialog(presenting:)` sur un élément
- **Swift :** `.confirmationDialog("Delete this task?", isPresented: Binding(get: { pending != nil }, set: { if !$0 { pending = nil } }), presenting: pending) { task in … }`
- **React/RN :** `Alert.alert` ouvert depuis le handler d'une ligne, avec la ligne en closure
- **Différence clé :** on mémorise la tâche « en attente » dans un `@State` ; la boîte s'ouvre tant qu'il est non `nil` et le remet à `nil` en se fermant. Rien n'est supprimé avant la confirmation.
- **Vu à :** étape 16, `Views/Home/HomeView.swift`

### derived-search · Recherche : une fonction pure et un état local
- **Swift :** `enum TaskSearch { static func results(for query: String, in tasks: [TaskItem]) -> [TaskItem] }`, `@State private var query`, `task.title.localizedStandardContains(term)`, `.task { isFieldFocused = true }`
- **React/RN :** `useMemo(() => tasks.filter(…), [query, tasks])` ; `autoFocus` sur un `<TextInput>`
- **Différence clé :** la saisie est un état local et les résultats en sont DÉRIVÉS (jamais stockés, donc jamais périmés). La logique de filtrage vit hors de la vue : elle se teste sans interface. `localizedStandardContains` ignore la casse et les accents et suit la langue de l'appareil (« RÉUNION » trouve « reunion »).
- **Vu à :** étape 17, `Models/TaskSearch.swift`, `Views/Search/SearchView.swift`

### photos-picker · `PhotosPicker` et fichiers locaux
- **Swift :** `PhotosPicker(selection: $pickedItem, matching: .images) { label }`, `.onChange(of: pickedItem) { Task { data = try? await item.loadTransferable(type: Data.self) } }`, `AvatarStore` (écrit un JPEG dans Application Support)
- **React/RN :** `expo-image-picker` (`launchImageLibraryAsync`) + `expo-file-system`
- **Différence clé :** pas d'autorisation à demander : le sélecteur système tourne dans un autre processus et ne donne accès qu'à la photo CHOISIE. `PhotosPickerItem` est un « ticket » dont on charge les données de façon asynchrone. On ne stocke dans les réglages que le NOM du fichier, et le dossier est injectable pour les tests.
- **Vu à :** étape 18, `Views/Profile/EditProfileView.swift`, `Services/AvatarStore.swift`

### up-propagation · Remonter une modification puis la redescendre
- **Swift :** `onUpdateProfile: (ProfileDraft) -> Void` jusqu'à `AppFlowView`, qui met à jour la session ; `RootView(user:)` reçoit le nouvel utilisateur et `.onChange(of: user) { viewModel.updateUser($0) }`
- **React/RN :** un callback `onSave` qui remonte à un store, puis un `useEffect` qui resynchronise l'état local
- **Différence clé :** la session persistée est la source de vérité ; Home et Profile la reçoivent sans que l'app soit recréée (`.id(appID)` ne change qu'à la connexion / déconnexion), donc les tâches ne sont pas perdues. `AvatarImage` choisit la photo locale ou l'avatar par défaut.
- **Vu à :** étape 18, `App/RootView.swift`, `Views/Entry/AppFlowView.swift`, `Views/Shared/AvatarImage.swift`

### adaptive-colors · Couleurs adaptatives et `preferredColorScheme`
- **Swift :** `Color(uiColor: UIColor { traits in traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light) })` (aide `Color.adaptive(light:dark:)`), `.preferredColorScheme(mode.colorScheme)` avec `nil` = « le système décide »
- **React/RN :** un thème `{ light, dark }` choisi par `useColorScheme()` et un `ThemeProvider`
- **Différence clé :** iOS résout la couleur AU MOMENT DU DESSIN : quand le mode change, tout se met à jour sans re-render ni contexte à propager. Une couleur DÉRIVÉE (`Color.textPrimary.opacity(0.1)`) reste adaptative parce qu'elle suit sa base : on ne définit en double (clair / sombre) que les tokens de base. Les matériaux (`.ultraThinMaterial`) et les contrôles système s'adaptent seuls. Les dégradés de la marque, les puces et l'icône ne changent pas.
- **Vu à :** étape 19, `DesignSystem/Colors.swift`, `DesignSystem/CategoryStyle.swift`, `Views/Entry/AppFlowView.swift`

### picker-enum · Un réglage à trois états (`AppearanceMode`)
- **Swift :** `enum AppearanceMode: String, CaseIterable { case system, light, dark }`, `@AppStorage` d'un `String`, `init(storedValue:)` qui retombe sur `.system`
- **React/RN :** `'light' | 'dark' | 'system'` dans `AsyncStorage`
- **Différence clé :** on stocke le `rawValue` (une chaîne) et on le reconvertit avec une valeur de repli : un réglage illisible ne casse jamais l'app. Le `Picker` met à jour ce `String`, et `AppFlowView` le relit pour l'appliquer à toute l'app.
- **Vu à :** étape 19, `Models/AppearanceMode.swift`, `Views/Profile/ProfileView.swift`

### swiftdata · SwiftData : `@Model`, `ModelContainer`, `ModelContext`
- **Swift :** `@Model final class TaskRecord { … }` décrit une table ; `ModelContainer(for: TaskRecord.self)` ouvre la base (un fichier SQLite) ; `container.mainContext.insert(...)`, `.fetch(FetchDescriptor<TaskRecord>(predicate: #Predicate { $0.id == id }))`, `.delete(...)`, `.save()`
- **React/RN :** une entité Prisma / WatermelonDB / `expo-sqlite` avec son ORM ; le container ≈ la connexion, le contexte ≈ une transaction
- **Différence clé :** pas de SQL ni de migration pour un premier schéma, et les prédicats `#Predicate` sont du Swift vérifié à la compilation. Les `@Model` sont des CLASSES : on les garde dans la couche de stockage et on expose des `struct` (`TaskItem`) au reste de l'app, qui ne connaît donc pas SwiftData. Les enums se stockent par leur `rawValue` (texte).
- **Vu à :** étape 20, `Services/SwiftDataStore.swift`

### storage-protocol · Un protocole de stockage (`DataStore`) avec deux implémentations
- **Swift :** `protocol DataStore { func tasks() -> [TaskItem]; func save(_:) … }` ; `SwiftDataStore` (prod) et `InMemoryStore` (tests, previews)
- **React/RN :** le pattern *repository* ; en test on remplace AsyncStorage / la base par un faux
- **Différence clé :** les mêmes tests tournent sur les DEUX implémentations (`DataStoreTests`) : la version mémoire sert de référence. `@MainActor` sur le protocole : le contexte SwiftData principal ne doit être touché que depuis le thread principal. Conséquence : une valeur par défaut `= InMemoryStore.sample()` n'est pas permise dans un `init` (évaluée hors du thread principal) ; on prend un optionnel et on construit dans le corps.
- **Vu à :** étape 20, `Services/DataStore.swift`

### derived-data · Les statistiques sont calculées, jamais stockées
- **Swift :** `enum LocalStats { static func stats(tasks:sessions:now:) … }` : fonctions pures
- **React/RN :** des *selectors* (Reselect) plutôt qu'un état dérivé dupliqué dans `useState`
- **Différence clé :** on stocke les FAITS (une tâche, une session de focus) et on recalcule le total, la série, l'objectif et les graphiques. Rien ne peut se désynchroniser, et les tests se limitent à des tableaux et une date injectée.
- **Vu à :** étape 20, `Models/LocalStats.swift`
