import SwiftUI

// Écran provisoire des onglets autres que Home (D-016).
struct PlaceholderScreen: View {
    let tab: AppTab

    var body: some View {
        VStack(spacing: Spacing.m) {
            Image(systemName: tab.systemImage)
                .font(.appLargeTitle)
                .foregroundStyle(Color.appPrimary)
            Text(tab.title)
                .font(.appSectionTitle)
                .foregroundStyle(Color.textPrimary)
            Text("Coming soon")
                .font(.appBody)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { AppBackground() }
        // Une seule phrase pour VoiceOver : « Calendar, Coming soon ».
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    PlaceholderScreen(tab: .calendar)
}
