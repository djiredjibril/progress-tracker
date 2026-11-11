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
    // ⚛️ React : le stockage local (D-047). Avec lui, chaque action est ÉCRITE sur l'appareil puis les statistiques sont
    // RECALCULÉES depuis les données ; sans lui (tests, previews), le ViewModel ne garde que l'état en mémoire.
    private let store: DataStore?
    private let now: () -> Date

    // Prévient le parent d'un événement qui mérite une notification (tâche terminée, objectif atteint…). `RootView` la branche
    // sur `NotificationsViewModel`. ⚛️ React : ≈ une prop callback `onEvent`, mais posée après coup.
    // `@ObservationIgnored` : ce n'est pas un état à afficher, SwiftUI n'a pas à le suivre.
    @ObservationIgnored var onEvent: (AppNotification) -> Void = { _ in }

    // ⚛️ React : *injection de dépendance* par le constructeur ≈ passer le service en argument du hook
    // (`useHome(api = realApi)`). En test, on injecte un faux service et une fausse horloge.
    // `@escaping` : la closure est conservée après le retour de `init` (comme un callback stocké).
    // `nil` = le service mock (créé ici, dans le corps : un fournisseur isolé au thread principal ne peut pas être une valeur par défaut).
    init(provider: HomeDataProviding? = nil, store: DataStore? = nil, now: @escaping () -> Date = { .now }) {
        self.provider = provider ?? MockHomeDataProvider()
        self.store = store
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
        store?.save(task)
        recomputeDerived()
    }

    // Met à jour l'utilisateur affiché (après une modification du profil) sans toucher au reste des données.
    func updateUser(_ user: User) {
        data?.user = user
    }

    // Remplace une tâche (même `id`) par sa version modifiée, puis garde la liste triée par échéance.
    func updateTask(_ task: TaskItem) {
        guard var current = data, let index = current.tasks.firstIndex(where: { $0.id == task.id }) else { return }
        current.tasks[index] = task
        current.tasks.sort { $0.dueDate < $1.dueDate }
        data = current
        store?.save(task)
        recomputeDerived()
    }

    // Supprime une tâche. Si elle était faite, le compteur « Tasks Done » baisse d'un cran (jamais sous 0).
    func deleteTask(_ task: TaskItem) {
        guard var current = data, let index = current.tasks.firstIndex(where: { $0.id == task.id }) else { return }
        if current.tasks[index].isCompleted {
            current.stats.tasksDone = max(0, current.stats.tasksDone - 1)
        }
        current.tasks.remove(at: index)
        data = current
        store?.deleteTask(id: task.id)
        recomputeDerived()
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
    func addFocusTime(_ seconds: TimeInterval, taskTitle: String? = nil) {
        guard var current = data, seconds > 0 else { return }
        current.stats.focusTime += seconds
        data = current
        guard let store else { return }
        let streakBefore = current.stats.streakDays
        store.add(FocusSession(date: now(), seconds: seconds, taskTitle: taskTitle))
        recomputeDerived()
        let minutes = max(1, Int((seconds / 60).rounded()))
        let subject = taskTitle.map { " on \($0)" } ?? ""
        onEvent(AppNotification(kind: .focusSession, title: "Focus session complete",
                                message: "You focused \(minutes) min\(subject).", date: now()))
        announceStreak(from: streakBefore)
    }

    // Recalcule les statistiques et l'objectif depuis les données stockées (voir `LocalStats`).
    private func recomputeDerived() {
        guard let store, var current = data else { return }
        let sessions = store.focusSessions()
        current.stats = LocalStats.stats(tasks: current.tasks, sessions: sessions, now: now())
        current.goal = LocalStats.goal(tasks: current.tasks, now: now())
        data = current
    }

    // Une série qui s'allonge (2 jours ou plus) mérite une notification.
    private func announceStreak(from before: Int) {
        guard let days = data?.stats.streakDays, days > before, days >= 2 else { return }
        onEvent(AppNotification(kind: .streak, title: "\(days)-day streak!",
                                message: "You've been active \(days) days in a row. Keep it up!", date: now()))
    }

    // ⚛️ React : le `_` signifie « pas de label à l'appel » : `toggle(task)` et non `toggle(task: task)`.
    func toggle(_ task: TaskItem) {
        guard var current = data,
              let index = current.tasks.firstIndex(where: { $0.id == task.id }) else { return }

        let goalBefore = current.goal.progress
        let streakBefore = current.stats.streakDays
        current.tasks[index].isCompleted.toggle()
        current.stats.tasksDone += current.tasks[index].isCompleted ? 1 : -1
        // ⚛️ React : `data` est une struct (type valeur) : on a modifié une COPIE (`current`), puis on la
        // réassigne. C'est exactement le `setData({ ...data, … })` de React, et c'est ce qui déclenche le re-render.
        data = current

        guard let store else { return }
        let updated = current.tasks[index]
        store.save(updated)
        recomputeDerived()
        // Événements : seulement quand on COCHE (décocher n'annonce rien).
        guard updated.isCompleted else { return }
        onEvent(AppNotification(kind: .taskCompleted, title: "Task completed",
                                message: "\(updated.title) was marked as done.", date: now()))
        if let goal = data?.goal, goal.progress >= 1, goalBefore < 1 {
            onEvent(AppNotification(kind: .dailyGoal, title: "Daily goal reached",
                                    message: "You completed every task planned for today.", date: now()))
        }
        announceStreak(from: streakBefore)
    }
}
