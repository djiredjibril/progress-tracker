import SwiftUI

// Écran provisoire : les onglets autres que Home (D-016) et les écrans empilés pas encore faits (Focus Session).
struct PlaceholderScreen: View {
    let title: String
    let systemImage: String
    // Pour un écran EMPILÉ (pas un onglet) : on affiche un bouton retour, car la barre de navigation système est masquée.
    var showsBackButton = false

    @Environment(\.dismiss) private var dismiss

    // ⚛️ React : un second `init` ≈ une « factory » : `PlaceholderScreen(tab: .calendar)` déduit le titre et l'icône
    // de l'onglet. Les appelants existants n'ont pas changé.
    init(tab: AppTab) {
        self.init(title: tab.title, systemImage: tab.systemImage)
    }

    init(title: String, systemImage: String, showsBackButton: Bool = false) {
        self.title = title
        self.systemImage = systemImage
        self.showsBackButton = showsBackButton
    }

    var body: some View {
        VStack(spacing: Spacing.m) {
            Image(systemName: systemImage)
                .font(.appLargeTitle)
                .foregroundStyle(Color.appPrimary)
            Text(title)
                .font(.appSectionTitle)
                .foregroundStyle(Color.textPrimary)
            Text("Coming soon")
                .font(.appBody)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Une seule phrase pour VoiceOver : « Calendar, Coming soon ».
        .accessibilityElement(children: .combine)
        .background { AppBackground() }
        .overlay(alignment: .topLeading) {
            if showsBackButton {
                CircleIconButton(systemName: "chevron.left", accessibilityLabel: "Back") { dismiss() }
                    .padding(Spacing.screen)
            }
        }
    }
}

#Preview {
    PlaceholderScreen(tab: .calendar)
}
