import Foundation
import Testing
@testable import FocusApp

// Les deux implémentations doivent se comporter pareil : on exécute les mêmes tests sur chacune.
@MainActor
struct DataStoreTests {
    private func stores() throws -> [DataStore] {
        [InMemoryStore(), try SwiftDataStore(inMemory: true)]
    }

    @Test func aNewStoreIsEmpty() throws {
        for store in try stores() {
            #expect(store.tasks().isEmpty)
            #expect(store.focusSessions().isEmpty)
            #expect(store.notifications().isEmpty)
        }
    }

    @Test func savingATaskCreatesThenUpdatesIt() throws {
        for store in try stores() {
            var task = TaskItem(title: "Run", dueDate: .now, category: .health, priority: .high, durationMinutes: 45, reminderMinutes: 15)
            store.save(task)
            #expect(store.tasks().count == 1)

            task.title = "Run 10k"
            task.isCompleted = true
            task.reminderMinutes = nil
            store.save(task)

            let saved = try #require(store.tasks().first)
            #expect(store.tasks().count == 1)                 // mise à jour, pas de doublon
            #expect(saved.id == task.id)
            #expect(saved.title == "Run 10k")
            #expect(saved.isCompleted)
            #expect(saved.category == .health)
            #expect(saved.priority == .high)
            #expect(saved.durationMinutes == 45)
            #expect(saved.reminderMinutes == nil)
        }
    }

    @Test func tasksComeBackSortedByDueDate() throws {
        for store in try stores() {
            store.save(TaskItem(title: "Later", dueDate: Date(timeIntervalSince1970: 2000)))
            store.save(TaskItem(title: "Sooner", dueDate: Date(timeIntervalSince1970: 1000)))
            #expect(store.tasks().map(\.title) == ["Sooner", "Later"])
        }
    }

    @Test func deletingATaskRemovesOnlyThatTask() throws {
        for store in try stores() {
            let keep = TaskItem(title: "Keep", dueDate: .now)
            let drop = TaskItem(title: "Drop", dueDate: .now)
            store.save(keep)
            store.save(drop)
            store.deleteTask(id: drop.id)
            #expect(store.tasks().map(\.title) == ["Keep"])
        }
    }

    @Test func focusSessionsAreAppended() throws {
        for store in try stores() {
            store.add(FocusSession(seconds: 1500, taskTitle: "Read"))
            store.add(FocusSession(seconds: 300))
            #expect(store.focusSessions().count == 2)
            #expect(store.focusSessions().reduce(0) { $0 + $1.seconds } == 1800)
            #expect(store.focusSessions().contains { $0.taskTitle == "Read" })
        }
    }

    @Test func notificationsAreSavedAndMarkedAsRead() throws {
        for store in try stores() {
            var note = AppNotification(kind: .streak, title: "3-day streak!", message: "Nice", date: .now)
            store.save(note)
            #expect(store.notifications().first?.isRead == false)
            #expect(store.notifications().first?.kind == .streak)

            note.isRead = true
            store.save(note)
            #expect(store.notifications().count == 1)
            #expect(store.notifications().first?.isRead == true)
        }
    }
}
