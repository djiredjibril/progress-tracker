import SwiftUI

// État vide réutilisable : une icône, un titre, une phrase et (en option) un bouton. Une installation neuve démarre sans
// aucune donnée (D-047) : chaque écran explique quoi faire au lieu d'afficher une page blanche.
// ⚛️ React : ≈ un composant `<EmptyState icon title message action />` de design system. Il est présentationnel : le bouton
// est une closure reçue en prop.
struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: Spacing.s) {
            Image(systemName: systemImage)
                .font(.appLargeTitle)
                .foregroundStyle(Color.appPrimary)
                .accessibilityHidden(true)
            Text(title)
                .font(.appHeadline)
                .foregroundStyle(Color.textPrimary)
                .multilineTextAlignment(.center)
            Text(message)
                .font(.appBody)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.appLink)
                        .foregroundStyle(Color.appPrimaryStrong)
                        .padding(.horizontal, Spacing.l)
                        .frame(minHeight: Size.circleButton)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.l)
        .padding(.horizontal, Spacing.l)
    }
}

#Preview {
    EmptyStateView(
        systemImage: "checklist",
        title: "No tasks today",
        message: "Add your first task to start your day.",
        actionTitle: "Add a task",
        action: {}
    )
    .background { AppBackground() }
}
