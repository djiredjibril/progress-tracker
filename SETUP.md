# SETUP — Création et outillage du projet

Ce fichier explique à Claude Code **comment créer le projet, quoi installer et comment compiler, tester et vérifier**. Il s'exécute une seule fois au début (étape 0 de la roadmap), puis sert de référence pour les commandes.

## 1. Prérequis (machine du développeur)

| Outil | Rôle | Vérification | Installation |
|---|---|---|---|
| macOS + **Xcode 16 ou plus récent** | Compilateur Swift, SDK iOS, simulateurs | `xcodebuild -version` | App Store |
| Command Line Tools pointant sur Xcode | Accès CLI | `xcode-select -p` | `sudo xcode-select -s /Applications/Xcode.app` |
| **Homebrew** | Installer les outils | `brew --version` | https://brew.sh |
| **XcodeGen** | Génère le `.xcodeproj` depuis `project.yml` | `xcodegen --version` | `brew install xcodegen` |
| xcbeautify (optionnel) | Logs `xcodebuild` lisibles | `xcbeautify --version` | `brew install xcbeautify` |

> ⚛️ React : XcodeGen joue le rôle d'un `package.json` + config déclarative. Le `.xcodeproj` est un **artefact généré**, comme un dossier `ios/` produit par `expo prebuild`. On ne l'édite pas et on ne le commit pas.

**Dépendances de l'app : aucune.** SwiftUI, Observation et Swift Testing sont fournis par le SDK.

Si un outil manque, Claude Code propose la commande d'installation et attend la confirmation du développeur avant de l'exécuter.

## 2. Arborescence à créer

Les assets sont **déjà fournis** dans `FocusApp/Resources/Assets.xcassets` (ne pas les recréer). Crée le reste :

```
FocusApp/                         ← racine du repo
├── CLAUDE.md
├── SETUP.md
├── project.yml                   ← à créer (contenu ci-dessous)
├── .gitignore                    ← à créer (contenu ci-dessous)
├── docs/                         ← fourni
├── FocusApp/                     ← sources de l'app
│   ├── App/
│   │   ├── FocusApp.swift        ← point d'entrée @main
│   │   └── RootView.swift
│   ├── DesignSystem/
│   ├── Models/
│   ├── Services/
│   ├── Mock/
│   ├── ViewModels/
│   ├── Views/
│   │   ├── Home/
│   │   │   └── Components/
│   │   └── Shared/
│   ├── Utilities/
│   └── Resources/
│       └── Assets.xcassets       ← fourni (Avatar, GoalMountain, AccentColor, AppIcon)
└── FocusAppTests/
```

XcodeGen n'inclut pas les dossiers vides. Pour l'étape 0, il suffit que `App/` contienne ses deux fichiers ; les autres dossiers seront remplis aux étapes suivantes.

## 3. `project.yml`

```yaml
name: FocusApp
options:
  bundleIdPrefix: com.example          # à remplacer par le préfixe du développeur
  deploymentTarget:
    iOS: "17.0"
  createIntermediateGroups: true
  developmentLanguage: fr

settings:
  base:
    SWIFT_VERSION: "5.0"
    MARKETING_VERSION: "1.0"
    CURRENT_PROJECT_VERSION: "1"

targets:
  FocusApp:
    type: application
    platform: iOS
    sources:
      - path: FocusApp
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.example.focusapp
        GENERATE_INFOPLIST_FILE: YES
        INFOPLIST_KEY_UILaunchScreen_Generation: YES
        INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait
        INFOPLIST_KEY_UIApplicationSceneManifest_Generation: YES
        ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon
        ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME: AccentColor
        TARGETED_DEVICE_FAMILY: "1"
        ENABLE_PREVIEWS: YES
        CODE_SIGN_STYLE: Automatic

  FocusAppTests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - path: FocusAppTests
    dependencies:
      - target: FocusApp
    settings:
      base:
        GENERATE_INFOPLIST_FILE: YES

schemes:
  FocusApp:
    build:
      targets:
        FocusApp: all
        FocusAppTests: [test]
    test:
      targets:
        - FocusAppTests
```

Le dossier `FocusAppTests/` doit contenir au moins un fichier pour que la génération fonctionne. À l'étape 0, crée un test minimal (`FocusAppTests/SmokeTests.swift`) avec Swift Testing (`import Testing`, `@Test`).

## 4. `.gitignore`

```gitignore
# Généré par XcodeGen
*.xcodeproj
# Xcode
xcuserdata/
DerivedData/
build/
*.xcuserstate
# macOS
.DS_Store
# Captures de vérification
docs/screenshots/*.png
!docs/screenshots/.gitkeep
```

## 5. Point d'entrée minimal (étape 0)

- `FocusApp/App/FocusApp.swift` : struct `@main` conforme à `App`, qui affiche `RootView()` dans un `WindowGroup`.
- `FocusApp/App/RootView.swift` : pour l'étape 0, un simple `Text("FocusApp")`. Il deviendra le conteneur de la tab bar à l'étape 6.

Commente ces deux fichiers selon les règles pédagogiques de `CLAUDE.md`. Ce sont les premiers concepts : `@main`, `App`, `Scene`, `View`, `body`, `some View`.

## 6. Commandes

Le nom du simulateur dépend de la version de Xcode installée. **Au début de chaque session**, choisis un iPhone disponible :

```bash
xcrun simctl list devices available | grep -i iphone
```

Ensuite, utilise ce nom (noté `SIM` ci-dessous ; préfère un modèle récent, non « Plus/Max », pour coller aux proportions de la maquette).

```bash
# Générer le projet (après tout ajout ou suppression de fichier)
xcodegen generate

# Compiler
xcodebuild -project FocusApp.xcodeproj -scheme FocusApp \
  -destination "platform=iOS Simulator,name=$SIM" \
  -derivedDataPath build build | xcbeautify   # retirer "| xcbeautify" s'il n'est pas installé

# Tester
xcodebuild -project FocusApp.xcodeproj -scheme FocusApp \
  -destination "platform=iOS Simulator,name=$SIM" \
  -derivedDataPath build test | xcbeautify

# Lancer dans le simulateur
xcrun simctl boot "$SIM" 2>/dev/null || true
open -a Simulator
xcrun simctl install booted build/Build/Products/Debug-iphonesimulator/FocusApp.app
xcrun simctl launch booted com.example.focusapp
```

> ⚛️ React : `xcodegen generate` ≈ `expo prebuild`, `xcodebuild build` ≈ `npx expo run:ios` sans le lancement, et `xcodebuild test` ≈ `npm test`. Il n'y a pas de Metro ni de hot reload en CLI : pour itérer vite sur l'UI, le développeur utilise les **Previews** dans Xcode (`#Preview`), l'équivalent le plus proche de Storybook combiné au fast refresh.

## 7. Vérification visuelle

À la fin de chaque étape d'UI :

```bash
mkdir -p docs/screenshots
xcrun simctl status_bar booted override --time "9:41" --batteryState charged --batteryLevel 100
xcrun simctl io booted screenshot docs/screenshots/step-<N>.png
```

Ouvre ensuite la capture et `docs/reference/home_mockup.png`, puis liste les écarts visibles (espacements, tailles, couleurs, alignements). Corrige ceux qui sont significatifs. Garde en tête que la maquette est en perspective : compare les proportions, pas les pixels.

## 8. Signature

En simulateur, aucune signature n'est requise. Pour tester sur un vrai iPhone, le développeur ouvre `FocusApp.xcodeproj` dans Xcode et choisit son équipe dans *Signing & Capabilities*. Ce réglage sera perdu à la prochaine génération : il faudra alors ajouter `DEVELOPMENT_TEAM` dans `project.yml`.
