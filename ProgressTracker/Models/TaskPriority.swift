enum TaskPriority: String, CaseIterable, Identifiable, Hashable {
    case low
    case medium
    case high

    var id: String { rawValue }

    var title: String {
        switch self {
        case .low: tr("Low")
        case .medium: tr("Medium")
        case .high: tr("High")
        }
    }
}
