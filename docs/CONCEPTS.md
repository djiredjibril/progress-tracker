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
