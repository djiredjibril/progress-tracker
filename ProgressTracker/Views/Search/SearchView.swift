import SwiftUI

// Écran de recherche, empilé par-dessus les onglets (route `.search`). Les résultats se mettent à jour à chaque frappe.
struct SearchView: View {
    let tasks: [TaskItem]
    // Un toucher sur un résultat ouvre ce jour dans Calendar : la navigation est décidée par le parent (`RootView`).
    let onSelect: (TaskItem) -> Void

    @Environment(\.dismiss) private var dismiss

    // ⚛️ voir CONCEPTS.md#state : la saisie est un état LOCAL de l'écran ; les résultats en sont DÉRIVÉS (jamais stockés).
    @State private var query = ""
    @FocusState private var isFieldFocused: Bool

    var body: some View {
        let results = TaskSearch.results(for: query, in: tasks)
        let hasQuery = !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        VStack(spacing: Spacing.m) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.s) {
                    if !hasQuery {
                        suggestions
                    } else if results.isEmpty {
                        emptyState
                    } else {
                        Text(results.count == 1 ? "1 result" : "\(results.count) results")
                            .font(.appFieldLabel)
                            .foregroundStyle(Color.textSecondary)
                            .padding(.bottom, Spacing.xs)
                            .accessibilityAddTraits(.isHeader)
                        ForEach(results) { task in
                            SearchResultRow(task: task) { onSelect(task) }
                        }
                    }
                }
                .padding(.horizontal, Spacing.screen)
                .padding(.bottom, Spacing.section)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollIndicators(.hidden)
        }
        .background { AppBackground() }
        .toolbar(.hidden, for: .navigationBar)
        // ⚛️ React : ≈ `autoFocus` d'un `<TextInput>` : le clavier s'ouvre dès l'arrivée sur l'écran.
        .task { isFieldFocused = true }
    }

    // MARK: - Sections

    private var header: some View {
        HStack(spacing: Spacing.m) {
            CircleIconButton(systemName: "chevron.left", accessibilityLabel: "Back") { dismiss() }
            HStack(spacing: Spacing.s) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.textSecondary)
                    .accessibilityHidden(true)
                // ⚛️ React : ≈ `<TextInput value onChangeText returnKeyType="search" />`.
                TextField("", text: $query, prompt: Text("Search tasks").foregroundStyle(Color.textPlaceholder))
                    .font(.appFieldText)
                    .foregroundStyle(Color.textPrimary)
                    .focused($isFieldFocused)
                    .submitLabel(.search)
                    .onSubmit { isFieldFocused = false }
                    .autocorrectionDisabled()
                if !query.isEmpty {
                    Button { query = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.textTertiary)
                            .frame(width: Size.circleButton - Spacing.s, height: Size.circleButton - Spacing.s)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear search")
                }
            }
            .formField(isFocused: isFieldFocused)
        }
        .padding(.horizontal, Spacing.screen)
        .padding(.top, Spacing.s)
    }

    // Raccourcis : un toucher sur une catégorie lance la recherche.
    private var suggestions: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text("Search by title or category")
                .font(.appFieldLabel)
                .foregroundStyle(Color.textSecondary)
            HStack(spacing: Spacing.s) {
                ForEach(TaskCategory.allCases) { category in
                    Button { query = category.title } label: {
                        Text(category.title)
                            .font(.appLink)
                            .foregroundStyle(Color.textPrimary)
                            .padding(.horizontal, Spacing.l - 2)
                            .frame(height: Size.chip)
                            .background(Capsule().fill(Color.fieldFill))
                            .overlay(Capsule().strokeBorder(Color.fieldBorder, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.top, Spacing.s)
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.s) {
            Image(systemName: "magnifyingglass")
                .font(.appLargeTitle)
                .foregroundStyle(Color.appPrimary)
            Text("No tasks match “\(query.trimmingCharacters(in: .whitespacesAndNewlines))”")
                .font(.appBody)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.section * 2)
        .accessibilityElement(children: .combine)
    }
}

// Une ligne de résultat : pastille de catégorie, titre, échéance, et une coche si la tâche est faite.
private struct SearchResultRow: View {
    let task: TaskItem
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.row) {
                Circle()
                    .fill(task.category.tint)
                    .frame(width: Size.badge, height: Size.badge)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(.appTaskTitle)
                        .foregroundStyle(Color.textPrimary)
                    Text("\(task.dueDate.dueLabel()) · \(task.category.title)")
                        .font(.appTaskSubtitle)
                        .foregroundStyle(Color.textSecondary)
                }
                Spacer(minLength: 0)
                if task.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.appPrimary)
                        .accessibilityHidden(true)
                }
                Image(systemName: "chevron.right")
                    .font(.appLinkChevron)
                    .foregroundStyle(Color.textSecondary)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, Spacing.m)
            .padding(.horizontal, Spacing.l)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard(cornerRadius: Radius.task, hasShadow: false)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(task.title), \(task.dueDate.dueLabel()), \(task.category.title)")
        .accessibilityValue(task.isCompleted ? "Done" : "")
        .accessibilityHint("Opens this day in the calendar")
    }
}

#Preview {
    NavigationStack {
        SearchView(tasks: MockData.homeData.tasks, onSelect: { _ in })
    }
}
