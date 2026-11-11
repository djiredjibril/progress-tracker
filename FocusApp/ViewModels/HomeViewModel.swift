import Foundation
import Observation

// ⚛️ React : `@Observable` ≈ un store Zustand / un custom hook : SwiftUI suit automatiquement quelles
// propriétés chaque vue lit dans son `body`, et ne la re-rend que si celles-là changent.
// Différence : pas de `setState` ni de `useSelector`, on modifie simplement les propriétés.
@Observable
// ⚛️ React : `@MainActor` force tout ce code à s'exécuter sur le thread principal (celui de l'UI).
// En JS il n'y a qu'un thread, donc pas d'équivalent : ici c'est le compilateur qui garantit qu'on ne touche
// jamais à l'état de l'écran depuis un autre thread.
@MainActor
// ⚛️ React : une `class` (type référence) : contrairement aux `struct`, il n'y a qu'UNE instance partagée
// que la vue observe. `final` = « personne n'en hérite » (optimisation + intention claire).
final class HomeViewModel {
    // ⚛️ React : un `enum` avec valeurs associées ≈ une union discriminée TypeScript :
    // `{ status: 'failed', message: string } | { status: 'loaded' } | …`.
    // Différence : impossible d'avoir un état incohérent (ex. `loaded` avec un message d'erreur).
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    // ⚛️ React : `private(set)` = lisible de partout, modifiable seulement ici (≈ état exposé en lecture seule
    // par un hook : on renvoie `state` mais pas `setState`). Les vues passent par `load()` et `toggle(_:)`.
    private(set) var state: LoadState = .idle
    // ⚛️ React : `HomeData?` est un *optionnel* : soit une valeur, soit `nil` (≈ `HomeData | null`).
    // Le compilateur oblige à gérer le cas `nil` avant d'utiliser la valeur.
    private(set) var data: HomeData?

    private let provider: HomeDataProviding
    private let now: () -> Date

    // ⚛️ React : *injection de dépendance* par le constructeur ≈ passer le service en argument du hook
    // (`useHome(api = realApi)`). En test, on injecte un faux service et une fausse horloge.
    // `@escaping` : la closure est conservée après le retour de `init` (comme un callback stocké).
    init(provider: HomeDataProviding = MockHomeDataProvider(), now: @escaping () -> Date = { .now }) {
        self.provider = provider
        self.now = now
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: now())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<18: return "Good Afternoon"
        default: return "Good Evening"
        }
    }

    // ⚛️ React : ≈ une fonction `async` appelée dans un `useEffect`. La vue la déclenche via `.task { }`.
    func load() async {
        state = .loading
        do {
            data = try await provider.fetchHomeData()
            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    // ⚛️ React : ≈ `refetch()` de React Query, appelée par le pull-to-refresh. Différence avec `load()` : on ne repasse
    // PAS par `.loading` (le squelette ne doit pas remplacer l'écran pendant que le spinner du geste tourne), et un
    // échec ne vide pas les données déjà affichées.
    func refresh() async {
        do {
            data = try await provider.fetchHomeData()
            state = .loaded
        } catch {
            if data == nil { state = .failed(error.localizedDescription) }
        }
    }

    // Ajoute une tâche créée par le formulaire et garde la liste triée par échéance. Sans données chargées, il n'y a
    // rien à mettre à jour : on ignore. Une nouvelle tâche n'est pas cochée, donc `tasksDone` ne change pas.
    func addTask(_ task: TaskItem) {
        guard var current = data else { return }
        current.tasks.append(task)
        current.tasks.sort { $0.dueDate < $1.dueDate }
        data = current
    }

    // La prochaine tâche à faire (les tâches sont triées par échéance) : c'est celle que propose la session de focus.
    // Les tâches passées et non faites sont ignorées : on propose la prochaine, aujourd'hui ou plus tard.
    var nextTask: TaskItem? {
        let startOfToday = Calendar.current.startOfDay(for: now())
        return data?.tasks
            .sorted { $0.dueDate < $1.dueDate }
            .first { !$0.isCompleted && $0.dueDate >= startOfToday }
    }

    // « Maintenant » (injectable pour les tests) : Home s'en sert pour ne montrer que les tâches du jour.
    var currentDate: Date { now() }

    // Ajoute du temps de focus réalisé (par `FocusSessionViewModel`) au total affiché sur Home.
    func addFocusTime(_ seconds: TimeInterval) {
        guard var current = data, seconds > 0 else { return }
        current.stats.focusTime += seconds
        data = current
    }

    // ⚛️ React : le `_` signifie « pas de label à l'appel » : `toggle(task)` et non `toggle(task: task)`.
    func toggle(_ task: TaskItem) {
        guard var current = data,
              let index = current.tasks.firstIndex(where: { $0.id == task.id }) else { return }

        current.tasks[index].isCompleted.toggle()
        current.stats.tasksDone += current.tasks[index].isCompleted ? 1 : -1
        // ⚛️ React : `data` est une struct (type valeur) : on a modifié une COPIE (`current`), puis on la
        // réassigne. C'est exactement le `setData({ ...data, … })` de React, et c'est ce qui déclenche le re-render.
        data = current
    }
}
