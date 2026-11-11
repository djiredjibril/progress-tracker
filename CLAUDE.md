# CLAUDE.md — Progress Tracker (apprentissage Swift / SwiftUI)

## Contexte

Ce projet est un **projet d'apprentissage**. Le développeur est un dev web et mobile expérimenté (React, React Native, Expo, Node) qui apprend **Swift et SwiftUI** en reproduisant fidèlement l'écran d'accueil d'une app de productivité.

- Maquette de référence : `docs/reference/home_mockup.png` (le cadre du téléphone et la perspective ne font PAS partie de l'UI).
- Toutes les décisions prises en amont sont dans `docs/`. **Lis ces fichiers avant de coder** :
  - `SETUP.md` : création du projet, outils, commandes de build, test et capture d'écran
  - `docs/DECISIONS.md` : décisions techniques et leurs raisons (ne pas les contredire sans demander)
  - `docs/ARCHITECTURE.md` : arborescence, modèles, flux de données MVVM
  - `docs/DESIGN_SYSTEM.md` : couleurs, typo, espacements, rayons, SF Symbols, assets
  - `docs/ROADMAP.md` : les étapes, dans l'ordre, avec critères de fin
  - `docs/CONCEPTS.md` : concepts Swift déjà expliqués (glossaire Swift ↔ React)

## Ton rôle

**Tu écris le code**, et tu l'accompagnes de **commentaires pédagogiques** qui comparent chaque concept Swift/SwiftUI à son équivalent React / React Native / TypeScript.

### Règles des commentaires pédagogiques

1. Préfixe obligatoire : `// ⚛️ React :` (en français), placé juste au-dessus de la ligne concernée.
2. **Première apparition uniquement** : un concept déjà listé dans `docs/CONCEPTS.md` n'est pas ré-expliqué dans le code. Tu peux renvoyer brièvement : `// ⚛️ voir CONCEPTS.md#state`.
3. Court et concret : 1 à 3 lignes. Donne l'équivalent React/RN, puis **la différence importante** s'il y en a une (c'est souvent là que se trouve l'apprentissage).
4. Quand la comparaison avec React est trompeuse, dis-le explicitement (`// ⚛️ React : pas d'équivalent direct…`).
5. Les commentaires techniques normaux (sans préfixe) restent permis, mais avec parcimonie.

Exemple :

```swift
// ⚛️ React : `@State` ≈ `useState`. La vue possède cette valeur et se re-rend quand elle change.
// Différence : ici on stocke un objet @Observable entier, pas besoin de setter.
@State private var viewModel = HomeViewModel()
```

### Après chaque nouveau concept

Ajoute une entrée dans `docs/CONCEPTS.md` (format du fichier à respecter).

## Méthode de travail

- **Une étape de `docs/ROADMAP.md` à la fois.** À la fin d'une étape, arrête-toi et attends la validation avant de passer à la suivante.
- À la fin de chaque étape :
  1. Le projet compile sans warning (voir commandes dans `SETUP.md`).
  2. Les tests passent (dès l'étape 1).
  3. Prends une capture du simulateur et compare-la visuellement à la maquette (voir `SETUP.md` > « Vérification visuelle »).
  4. Coche l'étape dans `docs/ROADMAP.md`.
  5. Ajoute toute nouvelle décision dans `docs/DECISIONS.md`.
  6. Écris dans le chat un **récap pédagogique court** : les 3 à 5 concepts Swift clés de l'étape, avec leur équivalent React.
- Si un choix n'est pas couvert par les docs, **demande** au lieu de deviner, sauf pour les détails mineurs (alors note-le dans `DECISIONS.md`).

## Règles techniques

- **Ne jamais éditer `ProgressTracker.xcodeproj` à la main.** Le projet est généré par XcodeGen à partir de `project.yml`. Après avoir ajouté, supprimé ou déplacé un fichier : `xcodegen generate`.
- **Aucune dépendance tierce** (pas de SPM, de CocoaPods ni de Carthage). Tout est natif : SwiftUI, Observation, Swift Testing.
- Cible minimale : **iOS 17**. Mode de langage : **Swift 5** (voir DECISIONS.md, D-004).
- **Aucune couleur, taille de police ou espacement en dur dans les vues.** Utilise toujours les tokens de `DesignSystem/` (définis selon `docs/DESIGN_SYSTEM.md`).
- Une vue par fichier, avec un `#Preview` dans chaque fichier de vue (en utilisant les données de `MockData`).
- Les composants de `Views/Home/Components/` sont **présentationnels** : ils reçoivent des valeurs et des closures, et ne connaissent jamais le ViewModel (comme des composants « dumb » en React).
- Les icônes passent par SF Symbols (`Image(systemName:)`) selon la table de `DESIGN_SYSTEM.md`. Les seules images bitmap sont `Avatar` et `GoalMountain`.
- Nommage : types en `UpperCamelCase`, propriétés et fonctions en `lowerCamelCase`, fichiers nommés comme le type principal.
- Accessibilité : chaque bouton icône a un `.accessibilityLabel`.
