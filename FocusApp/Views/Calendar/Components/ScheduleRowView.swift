import SwiftUI

// Une ligne du planning : la colonne des heures à gauche, et une carte colorée selon la catégorie à droite.
struct ScheduleRowView: View {
    let task: TaskItem

    var body: some View {
        let start = task.dueDate.clockParts()

        HStack(alignment: .top, spacing: Spacing.m) {
            VStack(alignment: .leading, spacing: 0) {
                Text(start.time)
                    .font(.appChip)
                    .foregroundStyle(Color.textPrimary)
                Text(start.period)
                    .font(.appCaption)
                    .foregroundStyle(Color.textSecondary)
            }
            .frame(width: Size.timeColumn, alignment: .leading)
            .padding(.top, Spacing.row)

            card
        }
        // Une seule annonce : « Work, Design new UI screens, 10:00 – 11:30 AM, done ».
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(task.category.title), \(task.title), \(task.dueDate.timeRangeLabel(to: task.endDate))")
        .accessibilityValue(task.isCompleted ? "Done" : "Not done")
    }

    private var card: some View {
        HStack(spacing: Spacing.m) {
            VStack(alignment: .leading, spacing: 6) {
                Text(task.category.title)
                    .font(.appTag)
                    .foregroundStyle(task.category.tagForeground)
                    .padding(.horizontal, Spacing.s)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: Radius.tag, style: .continuous)
                            .fill(task.category.tagFill)
                    )
                Text(task.title)
                    .font(.appTaskTitle)
                    .foregroundStyle(Color.textPrimary)
                Text(task.dueDate.timeRangeLabel(to: task.endDate))
                    .font(.appTaskSubtitle)
                    .foregroundStyle(Color.textSecondary)
            }
            Spacer(minLength: 0)
            statusIndicator
        }
        .padding(.vertical, Spacing.row)
        .padding(.horizontal, Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Radius.task, style: .continuous)
                .fill(task.category.scheduleFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.task, style: .continuous)
                .strokeBorder(Color.glassStroke, lineWidth: 1)
        )
    }

    // Indicateur d'état, non interactif (comme dans le canvas : on coche depuis Home).
    @ViewBuilder
    private var statusIndicator: some View {
        if task.isCompleted {
            Image(systemName: "checkmark")
                .font(.appCheckmark)
                .foregroundStyle(Color.textOnAccent)
                .frame(width: Size.checkbox, height: Size.checkbox)
                .background(Circle().fill(Color.appPrimary))
        } else {
            Circle()
                .strokeBorder(Color.textTertiary, lineWidth: 2)
                .frame(width: Size.checkbox, height: Size.checkbox)
        }
    }
}

#Preview {
    VStack(spacing: Spacing.m) {
        ForEach(MockData.tasks) { ScheduleRowView(task: $0) }
    }
    .padding(Spacing.screen)
    .background { AppBackground() }
}
