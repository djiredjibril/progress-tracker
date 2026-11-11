# Architecture

## Vue d'ensemble (MVVM)

```
┌──────────────┐   intentions (toggle, refresh)   ┌──────────────────┐   async load()   ┌────────────────────────┐
│    Views     │ ───────────────────────────────▶ │  HomeViewModel   │ ───────────────▶ │  HomeDataProviding     │
│  (SwiftUI)   │ ◀─────────────────────────────── │  @Observable     │ ◀─────────────── │  (protocol)            │
└──────────────┘   état observé (re-render auto)  └──────────────────┘   HomeData       │  └ MockHomeDataProvider│
                                                                                       └────────────────────────┘
```

| Couche | SwiftUI | Équivalent React/RN |
|---|---|---|
| View | `struct HomeView: View` | Composant fonction (écran) |
| Composant | `struct StatCardView: View` | Composant présentationnel |
| ViewModel | `@Observable final class HomeViewModel` | Custom hook / store Zustand |
| Service | `protocol HomeDataProviding` + implémentation | `services/api.ts` + interface TS |
| Model | `struct TaskItem` | `type TaskItem = {...}` |

## Arborescence cible

```
FocusApp/
├── App/
│   ├── FocusApp.swift              @main, WindowGroup { RootView() }
│   └── RootView.swift              état de l'onglet sélectionné + CustomTabBar
├── DesignSystem/
│   ├── Colors.swift                extension Color { static let appPrimary … }
│   ├── Typography.swift            extension Font { static let appTitle … }
│   ├── Layout.swift                enum Spacing / Radius / Size
│   └── GlassCard.swift             ViewModifier .glassCard()
├── Models/
│   ├── User.swift
│   ├── UserStats.swift
│   ├── DailyGoal.swift
│   ├── TaskItem.swift
│   └── HomeData.swift              agrège user + stats + goal + tasks
├── Services/
│   ├── HomeDataProviding.swift     protocol
│   └── MockHomeDataProvider.swift  délai simulé puis MockData
├── Mock/
│   └── MockData.swift
├── ViewModels/
│   └── HomeViewModel.swift
├── Views/
│   ├── Home/
│   │   ├── HomeView.swift
│   │   └── Components/
│   │       ├── HomeHeaderView.swift
│   │       ├── CircleIconButton.swift
│   │       ├── StatCardView.swift
│   │       ├── GoalCardView.swift
│   │       ├── ProgressBarView.swift
│   │       ├── SectionHeaderView.swift
│   │       └── TaskRowView.swift
│   └── Shared/
│       ├── CustomTabBar.swift
│       ├── AppTab.swift            enum des onglets
│       └── PlaceholderScreen.swift
├── Utilities/
│   └── Date+Formatting.swift       "Today, 10:00 AM"
└── Resources/
    └── Assets.xcassets
FocusAppTests/
└── HomeViewModelTests.swift
```

## Modèles

```swift
struct User {
    var firstName: String
    var avatarName: String          // nom de l'asset : "Avatar"
}

struct UserStats {
    var tasksDone: Int
    var focusTime: TimeInterval     // en secondes
    var streakDays: Int
    var focusHours: Int { Int(focusTime) / 3600 }               // computed
    var focusMinutes: Int { (Int(focusTime) % 3600) / 60 }      // computed
}

struct DailyGoal {
    var title: String               // "Keep Going!"
    var progress: Double            // 0...1
    var progressPercent: Int { Int((progress * 100).rounded()) }
}

struct TaskItem: Identifiable, Hashable {
    let id: UUID
    var title: String
    var dueDate: Date
    var isCompleted: Bool
    // init avec id: UUID = UUID(), isCompleted: Bool = false
}

struct HomeData {
    var user: User
    var stats: UserStats
    var goal: DailyGoal
    var tasks: [TaskItem]
}
```

Le texte « You're 70% closer to your goal. » est **dérivé** de `progressPercent` dans la vue (ou dans le ViewModel). Il n'est pas stocké.

## Service

```swift
protocol HomeDataProviding {
    func fetchHomeData() async throws -> HomeData
}

struct MockHomeDataProvider: HomeDataProviding {
    var delay: Duration = .milliseconds(400)
    func fetchHomeData() async throws -> HomeData {
        try await Task.sleep(for: delay)        // simule le réseau
        return MockData.homeData
    }
}
```

## ViewModel

```swift
@Observable
@MainActor
final class HomeViewModel {
    enum LoadState { case idle, loading, loaded, failed(String) }

    private(set) var state: LoadState = .idle
    private(set) var data: HomeData?           // ou propriétés séparées, au choix de Claude Code
    private let provider: HomeDataProviding

    init(provider: HomeDataProviding = MockHomeDataProvider()) { … }

    var greeting: String { … }                 // "Good Morning" / "Good Afternoon" / "Good Evening" selon l'heure
    func load() async { … }                    // appelé via .task {} dans HomeView
    func toggle(_ task: TaskItem) { … }        // inverse isCompleted, met à jour stats.tasksDone
}
```

Règles :
- Pour rendre le ViewModel testable, l'heure courante est injectable (`now: () -> Date = { .now }`).
- `toggle` met à jour `tasksDone` (+1 / −1) pour que l'UI reste cohérente.
- Le ViewModel est créé par `HomeView` avec `@State private var viewModel = HomeViewModel()`.
- Dans les previews, on peut injecter un provider avec `delay: .zero`.

## Flux de données dans les vues

- `HomeView` lit `viewModel` et passe des **valeurs** aux composants : `StatCardView(icon:value:label:tint:)`, `TaskRowView(task:onToggle:)`.
- Les closures remontent les intentions : `onToggle: { viewModel.toggle(task) }` (comme un callback prop en React).
- La sélection d'onglet (`AppTab`) est un `@State` dans `RootView`, passé à `CustomTabBar` via `@Binding` (≈ passer `value` + `onChange`).

## Tests (Swift Testing)

`FocusAppTests/HomeViewModelTests.swift`, au minimum :
- `load()` passe à l'état `loaded` et remplit les données (provider mock avec `delay: .zero`)
- `toggle()` inverse `isCompleted` et ajuste `tasksDone`
- `greeting` renvoie la bonne salutation pour 8 h, 14 h et 21 h (heure injectée)
- `focusHours` et `focusMinutes` sont corrects pour 23 040 s (6 h 24 min)
