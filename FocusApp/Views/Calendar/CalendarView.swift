import SwiftUI

// Écran Calendar : bandeau de la semaine et planning du jour sélectionné.
struct CalendarView: View {
    // Le jour et la semaine affichés vivent dans ce ViewModel (possédé par `RootView`) ; les tâches viennent de Home.
    let viewModel: CalendarViewModel
    let tasks: [TaskItem]

    var body: some View {
        let dayTasks = viewModel.tasks(on: viewModel.selectedDate, in: tasks)

        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l + 2) {
                header
                monthRow
                WeekStripView(
                    days: viewModel.weekDays,
                    selected: viewModel.selectedDate,
                    today: viewModel.today,
                    hasTasks: { viewModel.hasTasks(on: $0, in: tasks) },
                    onSelect: { viewModel.select($0) }
                )
                scheduleHeader(dayTasks)
                schedule(dayTasks)
            }
            .padding(.horizontal, Spacing.screen)
            .padding(.top, Spacing.s)
            .padding(.bottom, Spacing.section)
            // Le planning se met à jour en douceur quand on change de jour.
            .animation(.snappy, value: viewModel.selectedDate)
        }
        .scrollIndicators(.hidden)
        .background { AppBackground() }
    }

    // MARK: - Sections

    private var header: some View {
        HStack {
            Text("Calendar")
                .font(.appLargeTitle)
                .foregroundStyle(Color.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            Button {
                withAnimation(.snappy) { viewModel.goToToday() }
            } label: {
                Text("Today")
                    .font(.appChip)
                    .foregroundStyle(Color.appPrimaryStrong)
                    .padding(.horizontal, Spacing.m + 2)
                    .frame(height: Size.statIcon)
                    .background(Capsule().fill(Color.glassFill))
                    .overlay(Capsule().strokeBorder(Color.glassStroke, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Go to today")
        }
    }

    private var monthRow: some View {
        HStack {
            CircleIconButton(systemName: "chevron.left", accessibilityLabel: "Previous week") {
                withAnimation(.snappy) { viewModel.previousWeek() }
            }
            Spacer()
            Text(viewModel.monthTitle)
                .font(.appHeadline)
                .foregroundStyle(Color.textPrimary)
                // ⚛️ voir CONCEPTS.md#with-animation : le texte change en fondu quand on passe d'un mois à l'autre.
                .contentTransition(.opacity)
            Spacer()
            CircleIconButton(systemName: "chevron.right", accessibilityLabel: "Next week") {
                withAnimation(.snappy) { viewModel.nextWeek() }
            }
        }
    }

    private func scheduleHeader(_ dayTasks: [TaskItem]) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(viewModel.scheduleTitle)
                .font(.appSectionTitle)
                .foregroundStyle(Color.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            Text(viewModel.summary(for: dayTasks))
                .font(.appCardBody)
                .foregroundStyle(Color.textSecondary)
        }
    }

    @ViewBuilder
    private func schedule(_ dayTasks: [TaskItem]) -> some View {
        if dayTasks.isEmpty {
            emptyState
        } else {
            VStack(spacing: Spacing.s + 2) {
                // ⚛️ React : un `ForEach` sur une union : chaque élément est soit une tâche, soit le repère « now ».
                ForEach(viewModel.scheduleItems(for: dayTasks)) { item in
                    switch item {
                    case .task(let task):
                        ScheduleRowView(task: task)
                    case .now(let date):
                        NowIndicatorView(label: date.clockLabel)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.s) {
            Image(systemName: "calendar")
                .font(.appLargeTitle)
                .foregroundStyle(Color.appPrimary)
            Text("Nothing planned for this day.")
                .font(.appBody)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.section * 2)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    CalendarView(viewModel: CalendarViewModel(), tasks: MockData.homeData.tasks)
}
