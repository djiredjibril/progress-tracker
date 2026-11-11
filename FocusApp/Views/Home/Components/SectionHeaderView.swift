import SwiftUI

// En-tête de section : un titre à gauche et un lien d'action à droite (« My Tasks » … « See All › »).
struct SectionHeaderView: View {
    let title: String
    let actionTitle: String
    let onAction: () -> Void

    var body: some View {
        // Hauteur minimale de 44 pt (zone tactile du lien « See All ») ; titre et lien sont centrés verticalement, comme
        // dans le canvas.
        HStack(alignment: .center) {
            Text(title)
                .font(.appSectionTitle)
                .foregroundStyle(Color.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            Button(action: onAction) {
                HStack(spacing: Spacing.xs) {
                    Text(actionTitle)
                        .font(.appLink)
                    Image(systemName: "chevron.right")
                        .font(.appLinkChevron)
                        .accessibilityHidden(true)
                }
                .foregroundStyle(Color.textSecondary)
            }
            .buttonStyle(.plain)
            // « See All » seul est ambigu en navigation VoiceOver : on annonce « See All My Tasks ».
            .accessibilityLabel("\(actionTitle) \(title)")
        }
        .frame(minHeight: Size.circleButton)
    }
}

#Preview {
    ZStack {
        AppBackground()
        SectionHeaderView(title: "My Tasks", actionTitle: "See All", onAction: {})
            .padding(Spacing.screen)
    }
}
