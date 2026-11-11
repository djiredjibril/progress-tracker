# Design System

Ces valeurs ont été **échantillonnées sur la maquette** (`docs/reference/home_mockup.png`) puis arrondies. Comme la maquette est en perspective et légèrement éclairée, elles sont fidèles à l'esprit plutôt qu'au pixel près. Claude Code peut les ajuster après comparaison visuelle, en notant chaque changement dans `DECISIONS.md`.

Implémentation dans `ProgressTracker/DesignSystem/`, sous forme d'extensions `Color` et `Font` et d'enums `Spacing`, `Radius` et `Size`. Aucune valeur en dur dans les vues.

## Couleurs

| Token | Hex | Usage |
|---|---|---|
| `appPrimary` | `#6C6CF5` | Accent : checkbox cochée, bouton +, onglet actif, point de notification |
| `appPrimaryLight` | `#8E8CF7` | Haut du dégradé du bouton + |
| `textPrimary` | `#0F1328` | Titres (« Hello, Alex », valeurs des stats, titres des tâches) |
| `textSecondary` | `#5F6479` | Sous-titres, labels, horaires, « See All » (assombri depuis `#6B7088`, D-029) |
| `textTertiary` | `#9A9EB2` | Onglets inactifs, icônes ⋮, cercles des tâches non cochées |
| `backgroundTop` | `#E6ECFB` | Haut du fond de l'écran |
| `backgroundBottom` | `#F3F1FC` | Bas du fond de l'écran |
| `glassFill` | blanc à 55 % | Fond des cartes claires (sur `.ultraThinMaterial`) |
| `glassStroke` | blanc à 70 % | Liseré 1 pt des cartes claires |

### Dégradé de la carte objectif

`LinearGradient`, de `.bottomLeading` vers `.topTrailing` :
`#5A6FE4` → `#7F84F2` → `#B59DF4`

Sur la carte : texte blanc, sous-titre blanc à 85 %, barre de progression avec une piste blanche à 30 % et un remplissage blanc.

### Puces d'icônes des stats (cercle de 36 pt)

| Stat | Fond (dégradé doux) | Icône |
|---|---|---|
| Tasks Done | `#D6CCFA` → `#A493F2` | blanc |
| Focus Time | `#A9C1FA` → `#6E95F0` | blanc |
| Day Streak | `#F9DDD7` → `#F2846F` | blanc |

### Ombres

- Cartes claires : `appPrimary` à 8 %, rayon 20, y 8
- Carte objectif : `#5A6FE4` à 30 %, rayon 24, y 12
- Bouton + : `appPrimary` à 40 %, rayon 16, y 8

## Typographie (police système SF Pro)

| Token | Taille | Graisse | Usage |
|---|---|---|---|
| `greetingSmall` | 15 | regular | « Good Morning » |
| `largeTitle` | 30 | bold | « Hello, Alex 👋 » |
| `body` | 15 | regular | « Make today productive… » |
| `statValue` | 22 | bold | « 12 », « 6 », « 24 », « 5 » |
| `statUnit` | 14 | semibold | « h », « m » (en ligne, alignés sur la ligne de base) |
| `statLabel` | 13 | regular | « Tasks Done » |
| `cardEyebrow` | 13 | medium | « Today's Goal » |
| `cardTitle` | 24 | bold | « Keep Going! » |
| `cardBody` | 14 | regular | « You're 70% closer… » |
| `sectionTitle` | 20 | semibold | « My Tasks » |
| `link` | 14 | medium | « See All › » |
| `taskTitle` | 16 | semibold | Titre de tâche |
| `taskSubtitle` | 13 | regular | « Today, 10:00 AM » |
| `tabLabel` | 11 | medium | Labels de la tab bar |

Utilise `Font.system(size:weight:)`. Le Dynamic Type est une amélioration bonus (`relativeTo:`).

## Espacements, rayons et tailles (en points)

| Token | Valeur | Usage |
|---|---|---|
| `Spacing.screen` | 20 | Marge horizontale de l'écran |
| `Spacing.section` | 24 | Entre les grands blocs |
| `Spacing.m` | 12 | Entre les cartes de stats, entre les tâches |
| `Spacing.s` | 8 | Interne aux composants |
| `Spacing.xs` | 4 | Entre un titre et son sous-titre |
| `Radius.card` | 24 | Carte objectif |
| `Radius.stat` | 22 | Cartes de stats |
| `Radius.task` | 20 | Lignes de tâches |
| `Radius.tabBar` | 28 | Fond de la tab bar |
| `Size.avatar` | 112 | Diamètre de l'avatar (120 dans la maquette, 112 dans le canvas, D-031) |
| `Size.circleButton` | 44 | Boutons recherche et notification |
| `Size.statIcon` | 36 | Puce d'icône des stats |
| `Size.checkbox` | 26 | Cercle de la tâche |
| `Size.fab` | 64 | Bouton + central |
| `Size.goalArrow` | 44 | Bouton › de la carte objectif |

## SF Symbols

| Élément | Symbole |
|---|---|
| Recherche | `magnifyingglass` |
| Notification | `bell` (+ point `appPrimary` de 8 pt en haut à droite) |
| Tasks Done | `chart.bar.fill` |
| Focus Time | `clock` |
| Day Streak | `flame.fill` |
| Today's Goal | `target` |
| Flèche de la carte objectif | `chevron.right` |
| See All | `chevron.right` (petit, à côté du texte) |
| Tâche cochée | `checkmark` (blanc, dans un cercle `appPrimary`) |
| Menu de tâche | `ellipsis` avec `.rotationEffect(.degrees(90))` |
| Onglet Home | `house.fill` |
| Onglet Calendar | `calendar` |
| Bouton central | `plus` |
| Onglet Analytics | `chart.bar` |
| Onglet Profile | `person` |
| Emoji après « Hello, Alex » | caractère texte `👋` |

## Assets bitmap (`Assets.xcassets`)

| Nom | Contenu | Utilisation |
|---|---|---|
| `Avatar` | Avatar 3D détouré en cercle, fond violet inclus, PNG avec transparence | `Image("Avatar").resizable().scaledToFill()` dans un cadre de `Size.avatar`, `clipShape(Circle())` |
| `GoalMountain` | Montagne enneigée, bords gauche et bas en fondu transparent | Calque à droite de la carte objectif, **derrière** le bouton ›, aligné en haut à droite, hauteur ≈ 75 % de la carte, opacité 0,9 |
| `AccentColor` | `#6C6CF5` | Couleur d'accent globale |
| `AppIcon` | Anneau de progression + coche blanche sur le dégradé violet-bleu, 1024×1024, sans canal alpha | Icône de l'app (source vectorielle : `docs/reference/AppIcon.svg`, D-034) |

## Notes de mise en page (lecture de la maquette)

- **Fond de l'écran** : dégradé vertical `backgroundTop` → `backgroundBottom`, avec deux grandes taches floues décoratives (cercles `appPrimary` à 12 % et `#B59DF4` à 12 %, `blur(80)`) pour l'ambiance lavande.
- **Header** : les boutons recherche et notification sont alignés à droite, en haut. En dessous, une colonne de texte à gauche (salutation, titre, sous-titre sur 2 lignes) et l'avatar à droite. L'avatar descend légèrement et chevauche le haut de la troisième carte de stats : décalage vertical négatif, avatar au-dessus des cartes dans le `ZStack`.
- **Stats** : trois cartes de même largeur dans un `HStack`. Chaque carte empile la puce d'icône, la valeur et le label, alignés à gauche. La valeur Focus Time s'affiche « 6h 24m » en mélangeant `statValue` et `statUnit`.
- **Carte objectif** : l'eyebrow (icône `target` + « Today's Goal »), le titre et le sous-titre sont en haut à gauche. La barre de progression est en bas, avec le pourcentage à droite. Le bouton › est blanc et circulaire, sur la droite au milieu.
- **My Tasks** : en-tête de section avec « See All › » à droite. Les lignes contiennent, de gauche à droite : cercle, titre + horaire, menu ⋮. Une tâche cochée a un cercle plein `appPrimary` avec un checkmark. Le titre n'est **pas** barré.
- **Tab bar** : une capsule claire flottante (verre) avec 4 onglets et un bouton + circulaire en dégradé au centre, qui dépasse vers le haut. L'onglet actif est affiché en `appPrimary` avec une pastille de fond claire derrière l'icône.
- **Défilement** : le contenu défile dans un `ScrollView` et la tab bar reste fixe en bas. Prévoir une marge basse pour que la dernière tâche ne soit pas masquée.

## Ajouts de la phase 2 (source : canvas Claude Design, D-029)

### Couleurs

| Token | Valeur | Usage |
|---|---|---|
| `appPrimaryStrong` | `#5552E0` | Onglet actif, liens, pastille de date sélectionnée, dégradé du bouton + (fin) |
| `appPrimaryDeep` | `#3F3BC0` | Texte d'une pastille de catégorie sélectionnée |
| `buttonGradientStart` / `buttonGradientEnd` | `#6D6BEE` → `#4F4BD8` | Bouton principal (`.buttonStyle(.primary)`) |
| `buttonShadow` | `appPrimaryStrong` à 35 % | Ombre du bouton principal |
| `destructive` | `#B4322A` | « Log out », actions de suppression |
| `textPlaceholder` | `#6E7389` | Placeholder des champs |
| `sheetTop` / `sheetBottom` | `#F7F6FE` → `#F1F0FC` | Fond d'une feuille |
| `fieldFill` / `fieldBorder` / `focusRing` | blanc / `textPrimary` à 10 % / `appPrimary` à 12 % | Champs de formulaire (halo violet au focus) |
| `segmentTrack` / `closeFill` / `selectedChipFill` | `textPrimary` à 5 % / 6 % / `appPrimary` à 12 % | Piste d'un contrôle segmenté, bouton ✕, pastille cerclée |

Onglets inactifs : `textSecondary` (et non `textTertiary`, trop pâle pour 4.5:1). Pastille de l'onglet actif : `appPrimary` à 14 %.

### Typographie

`appFieldLabel` 13 semibold, `appFieldText` 16 regular, `appChip` 14 semibold (pastille sélectionnée, les autres utilisent `appLink`), `appButton` 16 bold, `appSheetTitle` 18 bold.

### Espacements, rayons et tailles

`Spacing.l` 16 (padding horizontal d'un champ). `Radius.field` 16, `Radius.button` 18, `Radius.segment` 12, `Radius.sheet` 32. `Size.field` 52, `Size.chip` 40, `Size.primaryButton` 56, `Size.segmentHeight` 38, `Size.fabRing` 4 (liseré de la couleur du fond autour du bouton +).

## Alignement sur le canvas (D-042)

- Carte objectif : hauteur 164, texte `textOnAccent` (blanc pur, pas 85 %), barre 10 pt (`Size.goalProgressBar`), dégradé `brandEnd` → `brandMid` (55 %) → `brandStart`, ombre `brandEnd` à 30 %. Le bouton › est à 52 pt du haut, icône `brandEnd`, ombre noire à 12 %.
- L'avatar de Home ne chevauche **pas** les cartes de stats (la note « Header » plus haut décrit la maquette d'origine) ; il porte `avatarShadow` (rayon 14, y 12).
- Rythme vertical de Home : 16 pt entre les blocs ; cartes de stats : padding 14, 10 pt puce → texte, 2 pt valeur → libellé ; lignes de tâche : padding 12 / 16 / 8, 8 pt entre lignes, sans ombre.
- Tab bar : hauteur 72, fond `tabBarFill` (blanc 78 %), liseré `tabBarStroke`, ombre `tabBarShadow` ; pastille 48 × 30 derrière l'icône active ; bouton + remonté de 16 pt.
- Fond : taches `backgroundBlobPrimary` (280 pt, 16 %, haut droite) et `backgroundBlobSecondary` (260 pt, 18 %, gauche), flou 70.
