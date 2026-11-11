import SwiftUI

// ⚛️ React : `@main` marque le point d'entrée du programme, comme `AppRegistry.registerComponent`
// (RN) ou `index.js` qui appelle `root.render(<App />)`. Il ne doit y en avoir qu'un seul.
@main
// ⚛️ React : `App` est un *protocole* (≈ une interface TypeScript que la struct doit respecter).
// Il exige une propriété `body` qui renvoie une `Scene`. C'est la racine de l'application.
struct FocusApp: App {
    // ⚛️ React : une `Scene` est une « fenêtre » de l'app (pas d'équivalent RN, il n'y en a qu'une sur iPhone).
    // `some Scene` = « un type précis qui est une Scene, que le compilateur déduit pour moi ».
    var body: some Scene {
        // ⚛️ React : `WindowGroup` crée la fenêtre principale et y monte la vue racine,
        // un peu comme `<NavigationContainer>` ou `root.render(...)`.
        WindowGroup {
            AppFlowView()
        }
    }
}
