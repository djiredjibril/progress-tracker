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
