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

### D-025 · Étape 5 : liste de tâches
**Choix :**
- `TaskRowView(task:onToggle:onEdit:onDelete:)` : le menu ⋮ propose « Edit » et « Delete » branchés sur des no-op depuis `HomeView`. Le ViewModel n'a pas encore ces actions.
- L'animation est déclenchée par `withAnimation(.snappy)` dans `HomeView`, autour de `viewModel.toggle`. Elle anime la coche et le compteur « Tasks Done » (`contentTransition(.numericText())`).
- Zone tactile de la case agrandie avec `contentShape` (8 pt de marge). La case a `accessibilityLabel` (titre), `accessibilityValue` (Completed / Not completed) et un hint.
- Tokens ajoutés : `Font.appLinkChevron`, `Font.appCheckmark` et `Size.menuButton` (32).
- iOS récent insère une espace fine insécable (U+202F) avant AM/PM : `DateFormattingTests` la normalise avant de comparer.

### D-026 : Étape 6 : tab bar et navigation
**Choix :**
- `RootView` garde `HomeView` montée et la masque (`opacity` + `allowsHitTesting` + `accessibilityHidden`) quand un autre onglet est actif, au lieu d'un `switch` qui la détruirait. Sans ça, retourner sur Home recréerait le ViewModel, rechargerait les données et perdrait les tâches cochées. Les autres onglets affichent `PlaceholderScreen` (monté à la demande).
- `CustomTabBar` est posée avec `safeAreaInset(edge: .bottom)`, avec `Size.fabRaise` de marge haute pour le bouton + qui dépasse. L'onglet actif est signalé par une pastille `matchedGeometryEffect` (`Color.tabPill`, `Radius.tabItem`).
- Le bouton + (`onAdd`) est un no-op : la feuille d'ajout est un bonus de la roadmap.
- Tokens ajoutés : `Color.fabShadow`, `Color.tabPill`, `Font.appTabIcon`, `Font.appFabIcon`, `Radius.tabItem` (20), `Size.fabRaise` (20), `Shadow.fabRadius` (16) et `fabY` (8).
- `AppTab` expose `title` et `systemImage`, testés par `AppTabTests`.

### D-027 : Étape 7 : finitions
**Choix :**
- Le `ProgressView` de l'étape 1 est remplacé par un squelette : `HomeView` réaffiche le vrai écran avec `MockData` et `.redacted(reason: .placeholder)`, non interactif, annoncé « Loading » à VoiceOver. L'image de la montagne n'est pas dessinée pendant le squelette (sinon : gros rectangle gris).
- Apparition : `.animation(.smooth, value: viewModel.state)` sur le conteneur et `.transition(.opacity + offset)` sur le contenu chargé.
- `.refreshable` appelle `HomeViewModel.refresh()`, distinct de `load()` : il ne repasse pas par `.loading`, et un échec ne vide pas les données déjà affichées (sauf s'il n'y en a pas encore). Un rafraîchissement remet les données du service : avec le mock, les tâches cochées reviennent à leur état d'origine.
- État d'échec : le message plus un bouton « Try again ».
- Accessibilité : titres marqués `isHeader`, une seule annonce par ligne de tâche (titre + échéance), pourcentage de la carte masqué (doublon avec la barre), « See All My Tasks ».
- Écart de la maquette corrigé : la cible de « Today's Goal » est dans un disque blanc (`Size.eyebrowIcon`, `Font.appEyebrowIcon`).
- Écarts connus restants : la barre de progression est un peu plus fine que sur la maquette (`Size.progressBar` = 8), et la maquette est en perspective, donc comparée aux proportions et non au pixel.

### D-028 : Phase 2 : source de design et découpage
**Choix :** les écrans restants viennent du canvas Claude Design « FocusApp — Écrans » (https://claude.ai/artifact/RDVEnKPgzbb23GAKCTAMwg) : 14 écrans (Splash, Onboarding 1 à 3, Log In, Sign Up, Home, Calendar, Analytics, Profile, New Task, Focus Session, Notifications, App Icon). La phase 2 de `ROADMAP.md` (étapes 8 à 15) les implémente, une étape à la fois.
**Pourquoi :** le design a été fait après la phase 1 et va au-delà de l'écran d'accueil. Le canvas est la référence visuelle tant qu'il ne contredit pas une décision déjà prise.

### D-029 : Tokens assombris du canvas appliqués partout
**Choix :** on applique à toute l'app, y compris aux écrans de la phase 1, les couleurs du canvas : `textSecondary` `#6B7088` devient `#5F6479`, nouveau violet fort `#5552E0` (onglet actif, liens), dégradé du bouton principal `#6D6BEE` → `#4F4BD8`, couleur de placeholder `#6E7389` et rouge destructif `#B4322A`.
**Pourquoi :** le canvas les a assombries pour atteindre le contraste 4.5:1. Les appliquer partout évite une incohérence entre anciens et nouveaux écrans. À faire à l'étape 8 ; les valeurs de `DESIGN_SYSTEM.md` seront mises à jour.

### D-030 : Police système conservée (confirme D-013)
**Choix :** SF Pro, pas Inter.
**Pourquoi :** la note du canvas dit qu'Inter y remplace SF Pro. Garder la police système donne le Dynamic Type gratuitement et évite d'embarquer des fichiers de police.

### D-031 : Écarts Home canvas / maquette d'origine
**Choix :** le 👋 après « Hello, Alex » est conservé (le canvas l'a retiré). Les autres écarts (avatar 112 pt contre 120, liseré de 4 pt autour du bouton +) sont tranchés à l'étape 8 par comparaison visuelle, puis notés ici.
**Pourquoi :** le retrait de l'emoji n'a pas été jugé voulu. Les autres écarts sont des détails mineurs.

### D-032 : Swift Charts autorisé, authentification fictive
**Choix :** Analytics utilise **Swift Charts**, framework natif d'Apple : D-011 (zéro dépendance tierce) reste respecté. Log In / Sign Up passent par un protocole `AuthProviding` avec une implémentation mock, sans backend ; l'état « connecté » est persisté localement.
**Pourquoi :** Swift Charts est dans le SDK. L'authentification réelle sort du périmètre d'apprentissage.

### D-033 : Étape 8 : ViewModel remonté dans `RootView`, feuille « New Task »
**Choix :**
- `RootView` possède le `HomeViewModel` (`@State`) et le passe à `HomeView(viewModel:)`. Cela remplace D-020 (« HomeView crée son ViewModel »). Le bouton + de la tab bar, qui vit dans `RootView`, doit ajouter des tâches à l'état affiché par Home, et Calendar et Analytics partageront ces tâches.
- `NewTaskDraft` (struct pure, testée) porte l'état du formulaire, la validation (titre non vide après `trim`) et la combinaison jour + heure. La feuille ne connaît pas le ViewModel : elle remonte une `TaskItem` par `onCreate`, et `HomeViewModel.addTask` l'insère en gardant la liste triée par échéance (sans toucher à `tasksDone`).
- `TaskItem` gagne `category`, `priority`, `durationMinutes` et `reminderMinutes` (tous avec valeur par défaut). Nouveaux enums `TaskCategory` et `TaskPriority`.
- « Pick a date » ouvre une seconde feuille (calendrier graphique, détent moyen). L'heure utilise le `DatePicker` compact natif : sa pastille grise et son format (24 h selon la locale du téléphone) diffèrent du canvas, qui affiche « 6:00 PM » en texte simple.
- Pas de focus automatique sur le titre à l'ouverture (le clavier masquerait le formulaire) : le focus se fait au toucher.
- Composants partagés ajoutés : `PrimaryButtonStyle` (`.buttonStyle(.primary)`) et `PillSegmentedControl` (réutilisé par Analytics à l'étape 12).
- **D-029 appliqué :** `textSecondary` assombri, `appPrimaryStrong` pour l'onglet actif, onglets inactifs en `textSecondary`, dégradé du bouton + terminé en `appPrimaryStrong`. `DESIGN_SYSTEM.md` mis à jour.
- **D-031 tranché :** avatar à 112 pt (valeur du canvas) et liseré de 4 pt autour du bouton + (`Size.fabRing`).
- **Mock :** Home garde ses 3 tâches. Le « Team stand-up » de 13:00 que montre Calendar sera ajouté à l'étape 11, avec la décision sur ce que Home affiche alors.

### D-034 : Icône de l'app (faite en avance sur l'étape 15)
**Choix :** l'icône est l'artboard « App Icon » du canvas (anneau de progression à 75 %, coche blanche, dégradé `#A58DF0` → `#6B70E6` → `#4E60D9` avec un halo clair en haut à gauche et un halo sombre en bas à droite). Elle a été redessinée en SVG (`docs/reference/AppIcon.svg`), rendue en PNG 1024×1024 avec `qlmanage`, puis son canal alpha a été retiré (l'App Store refuse une icône transparente). Elle est enregistrée dans `AppIcon.appiconset` comme icône unique `1024x1024` (iOS génère toutes les tailles).
**Pourquoi :** sans image, iOS affichait l'icône générique. Le rendu du flou peut différer très légèrement du canvas (de faibles bandes dans le coin bas-droit) ; pour l'améliorer, exporter le PNG depuis le canvas et remplacer `AppIcon-1024.png`.
**Aussi :** l'étape 15 de la roadmap ne garde que le launch screen.

### D-035 : Étape 9 : navigation secondaire et Notifications
**Choix :**
- `RootView` contient un `NavigationStack(path:)` avec une route typée `AppRoute` (`.notifications`, `.focusSession`). La tab bar fait partie du contenu racine de la pile : un écran empilé la recouvre, comme dans le canvas.
- Les liens du prototype : la cloche empile Notifications, la carte Focus Time empile Focus Session (écran provisoire avec bouton retour, remplacé à l'étape 10), la flèche de l'objectif bascule sur l'onglet Analytics, « See All » sur l'onglet Calendar. Ces deux onglets sont encore des écrans provisoires. Un toucher sur « Weekly report is ready » dépile tout et ouvre Analytics.
- `HomeView` reçoit ces actions en callbacks et `hasUnreadNotifications` en valeur : elle ne connaît pas la pile. Le point de la cloche suit désormais l'état réel des notifications (il disparaît avec « Mark all as read »).
- `NotificationsViewModel` (possédé par `RootView`, comme `HomeViewModel`) porte la liste, les groupes « Today / Earlier » (jour courant, sinon plus ancien, groupe vide masqué), le marquage lu / non lu et les libellés d'âge (`Date.relativeLabel`). L'heure est injectable. Contrairement à Home, les notifications sont fournies directement par `MockData` (mock synchrone, pas de protocole de service) : rien à charger de façon asynchrone pour l'instant.
- Les dates du mock sont relatives à « maintenant », donc les libellés restent cohérents. Le message « Daily goal reached » cite le jour de la semaine réel au lieu d'un « Monday » fixe.
- `.glassCard` accepte un voile, un liseré et une option d'ombre : une notification lue est plus discrète (voile 50 %, pas d'ombre).
- `PlaceholderScreen` prend un titre et une icône (et un bouton retour optionnel) ; `PlaceholderScreen(tab:)` reste disponible.
- Nom du modèle : `AppNotification` (`Notification` est pris par Foundation, voir D-007).

### D-036 : Étape 10 : Focus Session
**Choix :**
- Technique Pomodoro : 4 sessions de 25 min, pauses de 5 min (`FocusSessionConfig`). La pause démarre toute seule ; le focus suivant attend l'appui sur ▶︎. À la fin de la 4e session, l'état passe à « Complete ».
- `FocusSessionViewModel` ne dépend que d'une horloge injectée : `tick()` recalcule le temps restant depuis `endDate`. La vue le déclenche toutes les 500 ms par `.task(id:)`, qui n'est actif que pendant « running ».
- Le temps de focus réalisé (session terminée, « skip » en focus avec le temps écoulé, ou départ de l'écran) est remonté par `onFocusLogged` et ajouté à « Focus Time » de Home (`HomeViewModel.addFocusTime`). Un « reset » n'enregistre rien.
- La tâche affichée est la prochaine non terminée (`HomeViewModel.nextTask`) ; la pastille de catégorie utilise `TaskCategory.tint` (`DesignSystem/CategoryStyle.swift`).
- « Next break : 5 min » est la durée de la prochaine pause (le canvas ne dit pas si c'est un décompte) ; pendant la pause, la carte devient « Next focus : 25 min ».
- Le bouton ⋯ (réglages de session) est une action mock. L'écran provisoire `PlaceholderScreen` perd son bouton retour, devenu inutile.
- Non fait : une notification « Focus session complete » à la fin d'une session (elle existe dans le mock des notifications).

### D-037 : Étape 11 : Calendar et tâches sur plusieurs jours
**Choix :**
- La semaine commence le **lundi** (`Calendar.mondayFirst`), comme dans le canvas. Les flèches changent de semaine en gardant le même jour de la semaine ; « Today » revient à aujourd'hui. Le mois affiché est celui du jour sélectionné.
- Le jour sélectionné a un titre qui s'adapte (« Today's / Tomorrow's / Yesterday's Schedule », sinon « Thu, Nov 12 ») et un résumé « 3 tasks · 1 done ». Le repère « maintenant » est un `ScheduleItem` inséré entre les tâches passées et à venir, seulement quand le jour sélectionné est aujourd'hui. Un jour sans tâche affiche un état vide.
- `CalendarViewModel` ne garde que l'état d'affichage (jour sélectionné, semaine). Les tâches restent dans `HomeViewModel` (source unique) et sont passées à la vue ; elles sont donc partagées avec Home et la feuille « New Task ».
- **Home n'affiche plus que les tâches du jour** (`HomeData.tasks(on:)`). Le mock gagne 4 tâches sur d'autres jours de la semaine (lundi, mardi, jeudi, samedi) pour les points du bandeau ; celles qui tombent aujourd'hui sont écartées. `nextTask` ignore les tâches passées non faites.
- **Écarts avec le canvas :** le « Team stand-up » de 13:00 n'est pas dans le mock : le canvas montre 3 tâches sur Home et 4 sur Calendar, et on privilégie des données cohérentes (le planning affiche « 3 tasks »). Il peut être ajouté par la feuille « New Task ». Le canvas colore deux tâches Work en violet et en bleu ; ici la couleur suit la **catégorie** (Work violet, Health corail, Learning blanc, Personal bleu). Les indicateurs d'état du planning sont en lecture seule, comme dans le canvas : on coche depuis Home.
- Les libellés horaires séparent heure et période (`Date.clockParts`) et normalisent l'espace insécable fine d'iOS avant AM/PM.

### D-038 : Étape 12 : Analytics
**Choix :**
- **Swift Charts** pour l'histogramme (D-032). Abscisse de type texte (le nom de chaque barre, unique) : une abscisse numérique donnait des barres invisibles. Barre « courante » en dégradé avec infobulle, barres passées en violet pâle, périodes à venir en petits traits gris.
- Trois périodes : **Week** (7 barres lundi → dimanche), **Month** (paquets de 7 jours : W1 à W5) et **Year** (12 mois). Un historique mock de ~13 mois alimente les agrégations (`AnalyticsViewModel`, horloge et calendrier injectables).
- **La barre d'aujourd'hui vient du vrai temps de focus de Home** (`stats.focusTime`), pas de l'historique : elle augmente quand on termine une session de Focus Session. Lundi et mardi de la semaine courante valent 4 h 12 et 5 h 06 : avec les 6 h 24 d'aujourd'hui, la semaine fait 15 h 42, comme le canvas (si on est un autre jour, les valeurs suivent).
- Les chiffres « tâches faites sur prévues » (9/12, 38/50, 410/520), la meilleure série (12 jours) et la répartition par catégorie sont des valeurs mock par période : elles ne sont pas déduites des tâches réelles, trop peu nombreuses.
- `PillSegmentedControl` gagne un style `.glass` (piste en verre, texte violet) pour le sélecteur de période. `AttributedString.stat` accepte des polices réglables (28/16 ici, 22/14 sur Home).
- Limite connue : en vue Year, l'infobulle de la barre courante peut chevaucher la barre voisine (plus haute).

### D-039 : Étape 13 : Profile et réglages
**Choix :**
- Trois réglages persistés avec `@AppStorage` (clés dans `SettingsKey`) : **Notifications** (défaut activé), **Daily goal** (1 à 10 tâches, défaut 5) et **Focus session** (15, 25, 45 ou 60 min, défaut 25). Daily goal et Focus session se choisissent par un `Menu` + `Picker`.
- Les réglages ont un **effet réel** : la durée de focus choisie pilote `FocusSessionConfig(focusMinutes:)` donc le minuteur de Focus Session ; désactiver les notifications masque le point de la cloche sur Home. Le « Daily goal » est enregistré et affiché mais ne pilote pas encore la carte objectif de Home (dont la progression reste mock).
- **Appearance** affiche « Light » sans proposer d'autre choix : le dark mode est un bonus (D-014). La ligne n'est pas interactive.
- **Log out** demande confirmation (`confirmationDialog`) puis appelle `onLogOut`, qui est un no-op dans `RootView` jusqu'à l'étape 14 (le flux d'entrée n'existe pas encore).
- « Edit profile » (✎) et « Help & Support » sont des actions mock : le design ne détaille pas ces écrans.
- `User` gagne `email` (mock « alex@example.com »). Tant que Home n'a pas chargé, Profile réutilise le squelette `redacted` avec les données mock.
- Composants : `SettingsRow<Trailing>`, `SettingsValueTrailing` et `SettingsGroup` (verre) ; l'avatar a un liseré blanc de 4 pt et une ombre violette.

### D-040 : Étape 14 : parcours d'entrée et authentification fictive
**Choix :**
- `AppFlowView` devient la racine de l'app : Splash → (Onboarding la première fois) → Log In / Sign Up → `RootView`. `RootView` reçoit `onLogOut`. Quand l'utilisateur est déjà connecté, le Splash (≈ 2,6 s, ou un toucher) mène directement à l'app. L'app est recréée (`.id`) quand la session change.
- **Authentification fictive** (D-032) : protocole `AuthProviding`, `MockAuthProvider` (délai simulé, accepte toute saisie valide, `failure` configurable). Au login, le prénom est dérivé de l'e-mail (`alex@…` donne « Alex »). La session et « onboarding vu » sont persistés dans `UserDefaults` (injectable ; suite jetable en test). Après connexion, `MockHomeDataProvider(user:)` met le vrai prénom et l'e-mail dans Home et Profile.
- `hasSeenOnboarding` passe à vrai seulement à la **première connexion réussie** (le retour depuis Sign Up revient donc à l'onboarding, comme le canvas) et reste vrai après « Log out », qui ramène à Log In.
- Validation (testée, dans `LoginDraft` / `SignUpDraft`) : e-mail valide, mot de passe non vide au login, ≥ 8 caractères et CGU cochées (par défaut, comme le canvas) à l'inscription. Les messages d'erreur d'e-mail et de mot de passe n'apparaissent qu'une fois le champ quitté ; une erreur du « serveur » s'efface dès qu'on retape. « Forgot password? » est une action mock.
- **Splash** : anneau qui se dessine (`trim`), coche qui « pop », nom et slogan en fondu, halo qui respire ; avec « Réduire les animations », tout s'affiche d'un coup. Le launch screen statique (même dégradé) reste à faire à l'étape 15.
- **Onboarding** : `TabView` en pages ; les illustrations réutilisent les vrais composants (`TaskRowView`, `FocusRingView`, `GoalCardView`) avec des pastilles flottantes. Le lien « I already have an account » occupe toujours sa place (invisible sauf page 3) pour que le bouton ne saute pas.
- `FormFieldStyle` est sorti de `NewTaskView` pour être partagé ; nouveaux composants `CheckboxToggleStyle`, `AppLogoView` (anneau + coche dessinés en code), `AuthField`, `PasswordInput`.
- Les fonds de Log In / Sign Up réutilisent `AppBackground` (les taches du canvas sont à des positions légèrement différentes).

### D-041 : Étape 15 : launch screen
**Choix :** un `LaunchScreen.storyboard` affiche une image plein écran (`LaunchBackground`) : le dégradé `#A58DF0` → `#6B70E6` → `#4E60D9` et les deux halos du Splash, **sans le logo**, que le `SplashView` dessine ensuite. `UILaunchScreen_Generation` (écran blanc) est remplacé par `INFOPLIST_KEY_UILaunchStoryboardName`. L'image (1206×2622, `@3x`, source `docs/reference/LaunchBackground.svg`) est faite pour l'iPhone 17 Pro ; sur un autre modèle elle est recadrée (`scaleAspectFill`) avec une couleur de repli proche (`#6B70E6`).
**Pourquoi :** la clé `UILaunchScreen` de l'Info.plist ne gère pas un dégradé plein écran. Le storyboard est écrit à la main (le `.xcodeproj` reste généré par XcodeGen, D-010).
**Limite :** l'image est rendue à partir d'un SVG (`qlmanage`) : de très faibles bandes sont possibles dans les zones floues. Elle n'a pas été testée sur d'autres tailles d'écran ni en mode sombre.

### D-042 : Home aligné sur le canvas (relecture après la phase 2)
**Contexte :** le canvas Claude Design (inchangé, même version) a été relu écran Home contre écran Home. Plusieurs écarts venaient de la maquette d'origine ou d'approximations de la phase 1.
**Corrigé (le canvas fait foi, D-028) :**
- **Avatar :** il ne chevauche plus la 3e carte de stats (le canvas laisse 16 pt) et porte l'ombre violette du canvas. `Size.avatarOverlap` et le `zIndex` du header sont supprimés.
- **Espacements :** 16 pt entre les grands blocs (12 avant), 10 pt entre les boutons du header, titre « Hello » avec `tracking(-0.5)`, marge haute réduite (la safe area dégage déjà l'encoche).
- **Cartes de stats :** padding de 14 pt, 10 pt entre la puce et le texte, 2 pt entre la valeur et le libellé.
- **Carte objectif :** 164 pt de haut, texte en **blanc pur** (le canvas n'utilise pas les 85 % de `DESIGN_SYSTEM.md`), barre de 10 pt, disque d'eyebrow de 24 pt, bouton › à 52 pt du haut avec icône `#4E60D9` et ombre, montagne de 128 pt, dégradé aux couleurs de la marque (`#4E60D9` → `#6B70E6` → `#A58DF0`) et ombre assortie.
- **Lignes de tâche :** pas d'ombre, padding 12 / 16 / 8, cercle à 2 pt, ⋮ en `textSecondary` dans une zone de 36 × 44 pt, 8 pt entre les lignes ; l'en-tête « My Tasks » fait 44 pt de haut et est centré.
- **Cloche :** point de 8 pt cerné de blanc (12 pt au total), à 9 pt du haut et 10 pt de la droite.
- **Tab bar :** colonnes de même largeur, pastille derrière l'icône seule (48 × 30), fond blanc à 78 %, bouton + dépassant de 16 pt (20 avant), barre à 16 pt des bords.
- **Fond d'écran :** taches de 280 pt (16 %) en haut à droite et de 260 pt (18 %) à gauche, flou 70, aux positions du canvas.
**Écarts conservés :** SF Pro à la place d'Inter (D-030) ; le 👋 après « Hello » (D-031) ; les salutations suivent l'heure réelle (« Good Afternoon ») ; les tâches affichées sont celles du jour.

### D-043 : Étape 16 : édition et suppression de tâches
**Choix :**
- Le menu ⋮ des lignes de Home fonctionne : **Edit** ouvre la feuille « New Task » préremplie (titre « Edit Task », bouton « Save Changes ») ; **Delete** demande confirmation (`confirmationDialog`) puis supprime.
- Un seul formulaire pour les deux usages : `NewTaskDraft(editing:)` conserve l'`id` et l'état « fait » de la tâche ; `RootView` présente la feuille avec `sheet(item:)` (enum `TaskSheet`). Enregistrer appelle `HomeViewModel.updateTask` (remplacement par `id`, liste retriée par échéance, aucun doublon).
- Supprimer une tâche déjà faite fait baisser « Tasks Done » (jamais sous 0). Supprimer une tâche en attente ne change pas les compteurs.
- Limites : l'édition et la suppression se font depuis **Home** (les lignes du planning de Calendar restent en lecture seule, comme le canvas). La suppression n'est pas annulable (« This cannot be undone »). Les actions agissent sur les données en mémoire du mock tant que l'étape 20 (SwiftData) n'est pas faite : elles sont perdues au relancement.

### D-044 : Étape 17 : recherche
**Choix :**
- Le bouton loupe de Home empile un écran de recherche (route `.search`) : champ avec focus automatique, résultats en direct, état vide (« No tasks match … ») et raccourcis par catégorie quand le champ est vide. Le canvas n'a pas d'écran de recherche : il suit le style de l'app (champ `formField`, lignes en verre).
- `TaskSearch.results(for:in:)` (pure, testée) : chaque mot saisi doit se retrouver dans le titre OU la catégorie (ET entre les mots), sans tenir compte de la casse ni des accents ; résultats triés par échéance. La recherche porte sur **toutes** les tâches, pas seulement celles du jour.
- Un toucher sur un résultat revient à la racine, sélectionne ce jour dans Calendar (`CalendarViewModel.select`) et ouvre l'onglet.
- Limites : pas d'historique de recherches, pas de surlignage du texte trouvé, pas de recherche dans les notifications.

### D-045 : Étape 18 : modifier le profil
**Choix :**
- Le bouton ✎ de Profile ouvre la feuille « Edit Profile » : photo (`PhotosPicker`, avec « Change photo » et « Remove »), prénom, e-mail. Le formulaire est un `ProfileDraft` (testé) : prénom non vide, e-mail valide, et « Save Changes » reste désactivé tant que rien n'a changé (la casse et les espaces seuls ne comptent pas).
- `AuthViewModel.updateProfile` met à jour la session ET les réglages persistés. La photo est réduite (600 px max), enregistrée en JPEG dans Application Support/Avatars (`AvatarStore`), et l'ancienne photo est supprimée du disque quand elle est remplacée, retirée ou à la déconnexion. Si l'image choisie est illisible, la photo actuelle est conservée.
- `User` gagne `avatarURL` ; `AvatarImage` affiche la photo locale ou l'avatar par défaut sur Home et Profile. Home reçoit le nouvel utilisateur par `HomeViewModel.updateUser` sans recréer l'app : `RootView` n'est recréée (`.id(appID)`) qu'à une connexion ou une déconnexion, ce qui change l'ancien `.id(email)`.
- Le changement d'e-mail n'est pas « vérifié » (authentification fictive, D-032).

### D-046 : Étape 19 : mode clair, sombre ou système (remplace D-014)
**Choix :**
- La ligne **Appearance** de Profile propose Light / Dark / System (`Menu` + `Picker`), persisté (`SettingsKey.appearance`). **Le défaut est System** : l'app suit le téléphone. `AppFlowView` applique `.preferredColorScheme(mode.colorScheme)` à toute l'app (le mode clair forcé de D-014 est supprimé).
- Les **couleurs de base** sont adaptatives (`Color.adaptive(light:dark:)`) : fonds, textes, verre et liserés, champs, feuilles, notifications, tab bar, pistes d'anneau et de graphique, couleurs du planning, rouge destructif. Les couleurs dérivées suivent leur base. Inchangés : dégradés de la marque, puces de statistiques, icône, texte sur fond coloré.
- **Palette sombre dérivée par moi** (le canvas n'a pas de dessin sombre) : fond `#12162B` → `#1A1630`, texte `#F2F3FA` / `#A9AEC6`, violet fort `#8E8CF7` (le `#5552E0` clair manquait de contraste), cartes en verre blanc à 8 % sur matériau sombre, ombres noires. Les valeurs sont à ajuster si tu as une maquette sombre.
- Vérifié sur capture en mode sombre : Home, Calendar, Analytics, Profile, Notifications, feuille « New Task » et Log In.
- Limites : le launch screen et le Splash gardent leur dégradé de marque dans les deux modes (voulu) ; les écrans Onboarding, Focus Session, Search et Edit Profile n'ont pas été vérifiés visuellement en mode sombre.

### D-047 : Étape 20 : données locales SwiftData, fin du mock au runtime
**Choix :**
- **Stockage :** protocole `DataStore` (tâches, sessions de focus, notifications) ; `SwiftDataStore` en production (`@Model` `TaskRecord`, `FocusRecord`, `NotificationRecord`), `InMemoryStore` en test et en preview. Si la base ne s'ouvre pas, l'app retombe sur une base en mémoire (utilisable, sans sauvegarde). Une erreur d'écriture est journalisée sans bloquer l'écran.
- **Premier lancement : app vide** (décision déjà prise). `MockData` ne sert plus qu'aux previews (`InMemoryStore.sample()`), au squelette de chargement et aux tests.
- **Tout est calculé** (`LocalStats`) : *Tasks Done* = tâches faites dont l'échéance est aujourd'hui ; *Focus Time* = somme des sessions d'aujourd'hui ; *Day Streak* = jours consécutifs avec au moins une tâche faite (à son échéance, faute de date de complétion) ou une session de focus, la série d'hier restant vivante tant qu'aujourd'hui n'est pas fini ; *objectif* = part des tâches du jour faites (« Plan your day » / « Let's Go! » / « Keep Going! » / « Goal Reached! »). Analytics : tâches faites sur prévues par période, meilleure série, répartition par catégorie = durée des tâches FAITES.
- **Notifications nées d'événements réels** : tâche cochée, objectif du jour atteint, session de focus, série qui s'allonge (≥ 2 jours). Décocher n'annonce rien. Le « rapport hebdomadaire » du mock n'est plus généré (pas d'événement réel derrière).
- **États vides** : Home (« No tasks today » + bouton), Notifications, carte « Time by category » ; Calendar et Search avaient déjà les leurs.
- **Les données restent sur l'appareil à la déconnexion** (un seul utilisateur local) ; une autre personne qui se connecte voit les mêmes tâches. À revoir si un vrai compte arrive.
- Analytics relit le stockage à l'ouverture de l'onglet ; Home recalcule après chaque action.
- Limite : la persistance entre deux lancements est testée sur la base SwiftData en mémoire (même code) ; le fichier sur disque n'a pas été relancé à la main depuis le CLI.
