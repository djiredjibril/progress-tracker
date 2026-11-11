import SwiftUI

// Composant présentationnel (D-006) : il affiche une tâche et REMONTE des intentions par des closures.
// Il ne modifie jamais `task` lui-même : c'est le ViewModel qui change l'état.
struct TaskRowView: View {
    let task: TaskItem
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: Spacing.m) {
            checkbox
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(task.title)
                    .font(.appTaskTitle)
                    .foregroundStyle(Color.textPrimary)
                Text(task.dueDate.dueLabel())
                    .font(.appTaskSubtitle)
                    .foregroundStyle(Color.textSecondary)
            }
            Spacer(minLength: 0)
            menu
        }
        .padding(Spacing.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: Radius.task)
    }

    private var checkbox: some View {
        Button(action: onToggle) {
            // Deux états superposés : le disque plein + la coche apparaissent quand `isCompleted` passe à vrai.
            ZStack {
                Circle()
                    .strokeBorder(Color.textTertiary, lineWidth: 1.5)
                Circle()
                    .fill(Color.appPrimary)
                    // ⚛️ React : `opacity` et `scaleEffect` sont des propriétés ANIMABLES. Quand l'état change à
                    // l'intérieur d'un `withAnimation` (voir HomeView), SwiftUI les interpole seul : pas de
                    // `Animated.Value` à créer, ni de `useNativeDriver`.
                    .opacity(task.isCompleted ? 1 : 0)
                    .scaleEffect(task.isCompleted ? 1 : 0.6)
                Image(systemName: "checkmark")
                    .font(.appCheckmark)
                    .foregroundStyle(Color.textOnAccent)
                    .opacity(task.isCompleted ? 1 : 0)
                    .scaleEffect(task.isCompleted ? 1 : 0.4)
            }
            .frame(width: Size.checkbox, height: Size.checkbox)
            // ⚛️ React : `contentShape` ≈ `hitSlop` de RN : on agrandit la zone tactile au-delà des 26 pt visibles
            // (inset négatif = la forme grossit). Sans ça, le cercle serait difficile à viser.
            .contentShape(Circle().inset(by: -Spacing.s))
        }
        .buttonStyle(.plain)
        // ⚛️ React : ≈ `expo-haptics` (`Haptics.selectionAsync()`), mais déclaratif : le retour haptique se
        // déclenche tout seul à chaque CHANGEMENT de `trigger`, pas à un appel impératif dans le handler.
        .sensoryFeedback(.selection, trigger: task.isCompleted)
        .accessibilityLabel(task.title)
        // ⚛️ React : ≈ `accessibilityState={{ checked }}` : VoiceOver annonce « coché / non coché ».
        .accessibilityValue(task.isCompleted ? "Completed" : "Not completed")
        .accessibilityHint("Double-tap to toggle")
    }

    private var menu: some View {
        // ⚛️ React : `Menu` ≈ un `ActionSheet` / menu contextuel natif (ex. `react-native-menu`) : un bouton qui
        // ouvre une liste d'actions. Les actions sont ici des closures, branchées sur des no-op (actions mock).
        Menu {
            Button("Edit", systemImage: "pencil", action: onEdit)
            // `role: .destructive` : iOS colore l'action en rouge et la place selon ses conventions.
            Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
        } label: {
            Image(systemName: "ellipsis")
                .font(.appIconButton)
                .foregroundStyle(Color.textTertiary)
                // ⚛️ React : ≈ `transform: [{ rotate: '90deg' }]`. Comme `offset`, il ne change pas la mise en page :
                // les ⋯ horizontaux deviennent des ⋮ verticaux.
                .rotationEffect(.degrees(90))
                .frame(width: Size.menuButton, height: Size.menuButton)
        }
        .accessibilityLabel("Task options")
    }
}

#Preview {
    ZStack {
        AppBackground()
        VStack(spacing: Spacing.m) {
            ForEach(MockData.tasks) { task in
                TaskRowView(task: task, onToggle: {}, onEdit: {}, onDelete: {})
            }
        }
        .padding(Spacing.screen)
    }
}
