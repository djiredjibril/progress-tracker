// ⚛️ React : une `struct` est un type VALEUR : l'assigner en crée une copie indépendante.
// C'est l'immutabilité de `{ ...obj }` offerte gratuitement. À l'inverse, une `class` est passée par référence
// (comme un objet JS). Tous nos modèles sont des `struct` (voir D-008).
struct User {
    // ⚛️ React : `var` = propriété modifiable, `let` = constante. ≈ un `type User = { firstName: string, … }`,
    // sauf que le type porte aussi son initialiseur (`User(firstName:avatarName:)` est généré automatiquement).
    var firstName: String
    var avatarName: String      // nom de l'asset dans Assets.xcassets : "Avatar"
    var email: String
}
