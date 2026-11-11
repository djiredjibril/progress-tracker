import SwiftUI

// Écran Notifications, empilé par-dessus les onglets (route `.notifications`).
struct NotificationsView: View {
    // ViewModel reçu en `let` (possédé par `RootView`, voir D-035) : la vue lit ses propriétés `@Observable`.
    let viewModel: NotificationsViewModel
    // Le rapport hebdomadaire ouvre Analytics : la navigation est décidée par le parent (`RootView`).
    let onOpenAnalytics: () -> Void

    // ⚛️ voir CONCEPTS.md#sheet : `dismiss()` ≈ `navigation.goBack()`. Ici il dépile l'écran au lieu de fermer une feuille.
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.m) {
                header
                Text("Notifications")
                    .font(.appLargeTitle)
                    .foregroundStyle(Color.textPrimary)
                    .accessibilityAddTraits(.isHeader)

                // ⚛️ React : ≈ `groups.map(group => <Section key={group.title}>…)` : un `ForEach` dans un `ForEach`.
                ForEach(viewModel.groups()) { group in
                    section(group)
                }
                if viewModel.notifications.isEmpty {
                    EmptyStateView(
                        systemImage: "bell",
                        title: "You're all caught up",
                        message: "Finish a task or a focus session and it will show up here."
                    )
                    .padding(.top, Spacing.section)
                }
            }
            .padding(.horizontal, Spacing.screen)
            .padding(.bottom, Spacing.section)
            // Les lignes se réorganisent et changent d'aspect en douceur quand on les marque comme lues.
            .animation(.snappy, value: viewModel.unreadCount)
        }
        .scrollIndicators(.hidden)
        .background { AppBackground() }
        // ⚛️ React : ≈ `headerShown: false` d'un écran React Navigation : on dessine notre propre en-tête (bouton retour
        // en verre), à la place de la barre de navigation système. Le balayage depuis le bord gauche fonctionne encore.
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack {
            // On réutilise `CircleIconButton` (composant de Home) : même bouton rond en verre.
            CircleIconButton(systemName: "chevron.left", accessibilityLabel: "Back") { dismiss() }
            Spacer()
            Button {
                withAnimation(.snappy) { viewModel.markAllAsRead() }
            } label: {
                Text("Mark all as read")
                    .font(.appChip)
                    .foregroundStyle(Color.appPrimaryStrong)
                    .padding(.horizontal, Spacing.xs)
                    .frame(minHeight: Size.circleButton)
            }
            .buttonStyle(.plain)
            // Rien à marquer : le bouton s'estompe et n'est plus actif.
            .disabled(!viewModel.hasUnread)
            .opacity(viewModel.hasUnread ? 1 : 0.4)
        }
    }

    private func section(_ group: NotificationsViewModel.Group) -> some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text(group.title)
                .font(.appFieldLabel)
                .foregroundStyle(Color.textSecondary)
                // ⚛️ React : `textCase` ≈ `textTransform: 'uppercase'`, et `tracking` ≈ `letterSpacing`.
                .textCase(.uppercase)
                .tracking(0.6)
                .accessibilityAddTraits(.isHeader)
                .padding(.top, Spacing.xs)
            ForEach(group.items) { notification in
                NotificationRowView(
                    notification: notification,
                    timeLabel: viewModel.label(for: notification),
                    onTap: { open(notification) }
                )
            }
        }
    }

    // Toucher une notification la marque comme lue ; le rapport hebdomadaire ouvre en plus Analytics.
    private func open(_ notification: AppNotification) {
        withAnimation(.snappy) { viewModel.markAsRead(notification) }
        if notification.kind == .weeklyReport {
            onOpenAnalytics()
        }
    }
}

#Preview {
    NavigationStack {
        NotificationsView(viewModel: NotificationsViewModel(), onOpenAnalytics: {})
    }
}
