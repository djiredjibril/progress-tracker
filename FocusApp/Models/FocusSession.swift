import Foundation

// Une période de focus réellement réalisée (l'historique stocké sur l'appareil). Les « Focus Time » de Home et les barres
// d'Analytics sont CALCULÉS en additionnant ces enregistrements : on ne stocke jamais un total.
// ⚛️ React : ≈ une ligne d'une table `focus_sessions` ; le total est un `reduce`, pas un champ à tenir à jour.
struct FocusSession: Identifiable, Hashable {
    let id: UUID
    var date: Date
    var seconds: TimeInterval
    var taskTitle: String?

    init(id: UUID = UUID(), date: Date = .now, seconds: TimeInterval, taskTitle: String? = nil) {
        self.id = id
        self.date = date
        self.seconds = seconds
        self.taskTitle = taskTitle
    }
}
