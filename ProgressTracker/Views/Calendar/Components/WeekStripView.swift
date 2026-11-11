import SwiftUI

// Bandeau des 7 jours (lundi → dimanche) : le jour sélectionné a une pastille en dégradé, et un point indique les jours
// qui ont des tâches. Composant présentationnel : il reçoit des dates et des closures.
struct WeekStripView: View {
    let days: [Date]
    let selected: Date
    let today: Date
    let hasTasks: (Date) -> Bool
    let onSelect: (Date) -> Void

    // ⚛️ voir CONCEPTS.md#matched-geometry : la pastille glisse d'un jour à l'autre.
    @Namespace private var pillNamespace
    private let calendar = Calendar.mondayFirst

    var body: some View {
        HStack(spacing: Spacing.xs + 2) {
            // ⚛️ React : `id: \.self` : la date elle-même sert de clé (`Date` est `Hashable`), comme `key={day}`.
            ForEach(days, id: \.self) { day in
                dayButton(day)
            }
        }
        .padding(Spacing.s)
        .glassCard(cornerRadius: Radius.card)
    }

    private func dayButton(_ day: Date) -> some View {
        let isSelected = calendar.isDate(day, inSameDayAs: selected)
        let isToday = calendar.isDate(day, inSameDayAs: today)
        let hasDot = hasTasks(day)

        return Button {
            withAnimation(.snappy) { onSelect(day) }
        } label: {
            VStack(spacing: Spacing.xs) {
                Text(day.formatted(.dateTime.weekday(.abbreviated).locale(AppLanguage.current.locale)))
                    .font(.appCaption)
                    .foregroundStyle(isSelected ? Color.textOnAccent : Color.textSecondary)
                Text("\(calendar.component(.day, from: day))")
                    .font(isSelected ? .appHeadline.weight(.bold) : .appHeadline)
                    .foregroundStyle(isSelected ? Color.textOnAccent : Color.textPrimary)
                Circle()
                    .fill(hasDot ? (isSelected ? Color.textOnAccent : Color.appPrimary) : Color.clear)
                    .frame(width: Size.dayDot, height: Size.dayDot)
            }
            .padding(.top, Spacing.s + 2)
            .padding(.bottom, Spacing.s)
            .frame(maxWidth: .infinity)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: Radius.day, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.appPrimaryLight, Color.appPrimaryStrong],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.buttonShadow, radius: Shadow.segmentRadius * 2, y: Shadow.segmentY * 2)
                        .matchedGeometryEffect(id: "selectedDay", in: pillNamespace)
                }
            }
        }
        .buttonStyle(.plain)
        // « Wednesday, November 11, today, 3 tasks » : VoiceOver lit la date complète, pas « Wed 11 ».
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(day.formatted(.dateTime.weekday(.wide).month(.wide).day().locale(AppLanguage.current.locale))
                            + (isToday ? tr(", today") : "")
                            + (hasDot ? tr(", has tasks") : ""))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    @Previewable @State var selected = Calendar.mondayFirst.startOfDay(for: .now)
    let calendar = Calendar.mondayFirst
    let start = calendar.dateInterval(of: .weekOfYear, for: .now)!.start
    let days = (0..<7).map { calendar.date(byAdding: .day, value: $0, to: start)! }
    return WeekStripView(
        days: days,
        selected: selected,
        today: .now,
        hasTasks: { calendar.component(.day, from: $0) % 2 == 0 },
        onSelect: { selected = $0 }
    )
    .padding(Spacing.screen)
    .background { AppBackground() }
}
