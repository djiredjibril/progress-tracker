import SwiftUI

// Feuille « New Task » : un formulaire dont l'état local est un `NewTaskDraft`. À la validation, elle remonte une
// `TaskItem` par `onSubmit` (comme un `onSubmit` en React) : elle ne connaît pas le ViewModel.
struct NewTaskView: View {
    let editing: TaskItem?
    let onSubmit: (TaskItem) -> Void

    // ⚛️ React : `@Environment(\.dismiss)` ≈ la fonction `navigation.goBack()` / `onClose` : elle ferme la feuille
    // courante, sans qu'on la reçoive en prop. On l'appelle comme une fonction : `dismiss()`.
    @Environment(\.dismiss) private var dismiss

    // ⚛️ voir CONCEPTS.md#state : l'état du formulaire (≈ `useState({ title: '', … })`). Chaque champ s'y branche
    // avec `$draft.title`, `$draft.priority`… (un `Binding` sur UNE propriété de la struct).
    @State private var draft: NewTaskDraft
    @State private var isPickingDate = false

    // ⚛️ React : `@FocusState` ≈ un `ref` sur l'input + `ref.focus()` / `onFocus` : il dit quel champ a le focus et
    // permet de le changer par code. Ici il pilote l'aspect « focus » du champ (liseré violet + halo).
    @FocusState private var isTitleFocused: Bool

    // ⚛️ React : `editing == nil` crée une tâche, sinon le formulaire est prérempli avec elle. `State(initialValue:)` fixe
    // l'état de départ (≈ `useState(() => …)`) ; la valeur n'est utilisée qu'à la création de la vue.
    init(editing: TaskItem? = nil, onSubmit: @escaping (TaskItem) -> Void) {
        self.editing = editing
        self.onSubmit = onSubmit
        _draft = State(initialValue: editing.map { NewTaskDraft(editing: $0) } ?? NewTaskDraft())
    }

    var body: some View {
        // ⚛️ React : `ScrollView` + bouton fixé en bas ≈ `KeyboardAvoidingView` : `safeAreaInset` garde « Create Task »
        // visible sous le formulaire, qui défile derrière (voir CONCEPTS.md#safe-area-inset).
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                header
                titleField
                dateField
                timeAndDuration
                categoryField
                priorityField
                reminderRow
            }
            .padding(.horizontal, Spacing.screen)
            .padding(.top, Spacing.s)
        }
        // ⚛️ React : ≈ `keyboardDismissMode="interactive"` d'un `ScrollView` RN : le clavier se replie en tirant.
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            // ⚛️ React : `.disabled(true)` ≈ `disabled` d'un `Pressable`. `PrimaryButtonStyle` le lit via
            // `@Environment(\.isEnabled)` et pâlit tout seul : on ne passe aucune prop de plus.
            Button(draft.isEditing ? "Save Changes" : "Create Task", action: submit)
                .buttonStyle(.primary)
                .disabled(!draft.isValid)
                .padding(.horizontal, Spacing.screen)
                .padding(.bottom, Spacing.s)
        }
        // ⚛️ React : ces modifiers s'appliquent à la FEUILLE elle-même (≈ les options d'un `Modal` / bottom sheet) :
        // hauteur, poignée, coins arrondis et fond. Ils se posent sur le contenu de la feuille, pas sur le `.sheet`.
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(Radius.sheet)
        .presentationBackground {
            LinearGradient(colors: [Color.sheetTop, Color.sheetBottom], startPoint: .top, endPoint: .bottom)
        }
        // Calendrier complet pour « Pick a date » : une seconde feuille, plus petite, empilée sur celle-ci.
        .sheet(isPresented: $isPickingDate) {
            DatePickerSheet(day: $draft.day)
        }
    }

    // MARK: - Sections

    private var header: some View {
        // ⚛️ React : `ZStack` centre le titre sur TOUTE la largeur, indépendamment du bouton de gauche (avec un
        // `HStack`, le titre serait décalé par la largeur du bouton).
        ZStack {
            Text(draft.isEditing ? "Edit Task" : "New Task")
                .font(.appSheetTitle)
                .foregroundStyle(Color.textPrimary)
                .accessibilityAddTraits(.isHeader)
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.appIconButton)
                        .foregroundStyle(Color.textPrimary)
                        .frame(width: Size.circleButton, height: Size.circleButton)
                        .background(Circle().fill(Color.closeFill))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close")
                Spacer()
            }
        }
    }

    private var titleField: some View {
        labeled("Title") {
            // ⚛️ React : ≈ `<TextInput value onChangeText placeholder />`. `$draft.title` est le `Binding` : la
            // saisie écrit dans `draft.title`, et un changement de `draft.title` met le champ à jour (deux sens).
            TextField(
                "",
                text: $draft.title,
                prompt: Text("What do you need to do?").foregroundStyle(Color.textPlaceholder)
            )
            .font(.appFieldText)
            .foregroundStyle(Color.textPrimary)
            .focused($isTitleFocused)
            .submitLabel(.done)
            .onSubmit { isTitleFocused = false }
            .formField(isFocused: isTitleFocused)
        }
    }

    private var dateField: some View {
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(draft.day)
        let isTomorrow = calendar.isDateInTomorrow(draft.day)

        return labeled("Date") {
            HStack(spacing: Spacing.s) {
                ChoiceChip(title: "Today", isSelected: isToday) {
                    draft.day = .now
                }
                ChoiceChip(title: "Tomorrow", isSelected: isTomorrow) {
                    draft.day = calendar.date(byAdding: .day, value: 1, to: .now) ?? .now
                }
                ChoiceChip(
                    title: isToday || isTomorrow
                        ? "Pick a date"
                        : draft.day.formatted(.dateTime.month(.abbreviated).day()),
                    systemImage: "calendar",
                    isSelected: !(isToday || isTomorrow)
                ) {
                    isPickingDate = true
                }
            }
        }
    }

    private var timeAndDuration: some View {
        HStack(alignment: .top, spacing: Spacing.m) {
            labeled("Time") {
                HStack(spacing: Spacing.s) {
                    Image(systemName: "clock")
                        .foregroundStyle(Color.appPrimaryStrong)
                        .accessibilityHidden(true)
                    // ⚛️ React : ≈ `@react-native-community/datetimepicker` en mode « time ». `.compact` affiche une
                    // pastille qui ouvre le sélecteur natif au toucher ; `labelsHidden` retire son libellé visible
                    // (le titre « Time » est déjà au-dessus), mais VoiceOver le lit toujours.
                    DatePicker("Time", selection: $draft.time, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                    Spacer(minLength: 0)
                }
                .formField()
            }
            labeled("Duration") {
                // ⚛️ React : `Menu` + `Picker` ≈ un `<select>` : le menu natif liste les options, et la valeur choisie
                // est écrite dans `draft.durationMinutes` grâce au `tag` de chaque ligne.
                Menu {
                    Picker("Duration", selection: $draft.durationMinutes) {
                        ForEach(NewTaskDraft.durationOptions, id: \.self) { minutes in
                            Text(NewTaskDraft.label(forMinutes: minutes)).tag(minutes)
                        }
                    }
                } label: {
                    HStack {
                        Text(NewTaskDraft.label(forMinutes: draft.durationMinutes))
                            .font(.appFieldText.weight(.semibold))
                            .foregroundStyle(Color.textPrimary)
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.down")
                            .font(.appLinkChevron)
                            .foregroundStyle(Color.textSecondary)
                    }
                    .formField()
                }
            }
        }
    }

    private var categoryField: some View {
        labeled("Category") {
            HStack(spacing: Spacing.s) {
                ForEach(TaskCategory.allCases) { category in
                    ChoiceChip(
                        title: category.title,
                        isSelected: draft.category == category,
                        style: .outlined
                    ) {
                        draft.category = category
                    }
                }
            }
        }
    }

    private var priorityField: some View {
        labeled("Priority") {
            PillSegmentedControl(selection: $draft.priority, options: TaskPriority.allCases, title: \.title)
        }
    }

    private var reminderRow: some View {
        HStack(spacing: Spacing.m) {
            Image(systemName: "bell")
                .font(.appStatLabel)
                .foregroundStyle(Color.appPrimaryStrong)
                .frame(width: Size.statIcon - 4, height: Size.statIcon - 4)
                .background(
                    RoundedRectangle(cornerRadius: Radius.segment, style: .continuous)
                        .fill(Color.tabPill)
                )
                .accessibilityHidden(true)
            Text("Remind me 15 min before")
                .font(.appLink)
                .foregroundStyle(Color.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            // ⚛️ React : ≈ `<Switch value onValueChange />`. `labelsHidden` : le libellé est le texte à gauche.
            Toggle("Remind me 15 min before", isOn: $draft.remindsBeforeStart)
                .labelsHidden()
                .tint(Color.appPrimaryStrong)
        }
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, Spacing.m)
        .background(
            RoundedRectangle(cornerRadius: Radius.field, style: .continuous).fill(Color.fieldFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Radius.field, style: .continuous)
                .strokeBorder(Color.fieldBorder, lineWidth: 1)
        )
    }

    // MARK: - Helpers

    // ⚛️ React : une fonction qui renvoie une vue autour d'un *contenu* ≈ un composant avec `children` : le libellé
    // au-dessus, le champ en dessous. `@ViewBuilder` permet de lui passer plusieurs vues comme en JSX.
    private func labeled<Content: View>(_ label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(label)
                .font(.appFieldLabel)
                .foregroundStyle(Color.textSecondary)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func submit() {
        onSubmit(draft.makeTask())
        dismiss()
    }
}

// MARK: - Pastille de choix

// Pastille cliquable utilisée pour la date et la catégorie. Deux looks : « solid » (sélection pleine, pour la date)
// et « outlined » (sélection cerclée, pour la catégorie), comme dans le canvas.
private struct ChoiceChip: View {
    enum Style { case solid, outlined }

    let title: String
    var systemImage: String?
    let isSelected: Bool
    var style: Style = .solid
    let action: () -> Void

    var body: some View {
        Button {
            withAnimation(.snappy(duration: 0.15)) { action() }
        } label: {
            HStack(spacing: Spacing.xs + 2) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.appLinkChevron)
                        .accessibilityHidden(true)
                }
                Text(title)
                    .font(isSelected ? .appChip : .appLink)
            }
            .foregroundStyle(foreground)
            .padding(.horizontal, Spacing.l - 2)
            .frame(height: Size.chip)
            .background(Capsule().fill(fill))
            .overlay(Capsule().strokeBorder(border, lineWidth: isSelected && style == .outlined ? 1.5 : 1))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var foreground: Color {
        guard isSelected else { return Color.textPrimary }
        return style == .solid ? Color.textOnAccent : Color.appPrimaryDeep
    }

    private var fill: Color {
        guard isSelected else { return Color.fieldFill }
        return style == .solid ? Color.appPrimaryStrong : Color.selectedChipFill
    }

    private var border: Color {
        guard isSelected else { return Color.fieldBorder }
        return style == .solid ? Color.clear : Color.appPrimaryStrong
    }
}

// MARK: - Feuille du calendrier

private struct DatePickerSheet: View {
    @Binding var day: Date
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: Spacing.m) {
            // ⚛️ React : le sélecteur de date natif en grand calendrier (`.graphical`).
            DatePicker("Date", selection: $day, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(Color.appPrimaryStrong)
            Button("Done") { dismiss() }
                .buttonStyle(.primary)
        }
        .padding(Spacing.screen)
        // ⚛️ React : ≈ les « snap points » d'un bottom sheet : cette feuille ne prend que la moitié de l'écran.
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    NewTaskView { _ in }
}
