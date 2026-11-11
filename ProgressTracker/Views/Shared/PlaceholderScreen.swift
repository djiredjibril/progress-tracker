import SwiftUI

// Écran provisoire des onglets pas encore faits (D-016).
struct PlaceholderScreen: View {
    let title: String
    let systemImage: String

    // ⚛️ React : un second `init` ≈ une « factory » : `PlaceholderScreen(tab: .calendar)` déduit le titre et l'icône
    // de l'onglet.
    init(tab: AppTab) {
        self.init(title: tab.title, systemImage: tab.systemImage)
    }

    init(title: String, systemImage: String) {
        self.title = title
        self.systemImage = systemImage
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
    }
}

#Preview {
    PlaceholderScreen(tab: .calendar)
}
