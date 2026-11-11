import SwiftUI

// Repère « maintenant » : l'heure, un point et une ligne, inséré entre les tâches passées et à venir.
struct NowIndicatorView: View {
    let label: String

    var body: some View {
        HStack(spacing: Spacing.s) {
            Text(label)
                .font(.appCaption.weight(.bold))
                .foregroundStyle(Color.appPrimaryStrong)
                .frame(width: Size.timeColumn + Spacing.xs + 2, alignment: .leading)
            Circle()
                .fill(Color.appPrimaryStrong)
                .frame(width: Size.badge, height: Size.badge)
            Capsule()
                .fill(Color.appPrimaryStrong.opacity(0.6))
                .frame(height: Size.nowLine)
        }
        .padding(.leading, Spacing.xs + 2)
        // Une seule annonce VoiceOver : « Now, 3:20 PM ».
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Now, \(label)")
    }
}

#Preview {
    NowIndicatorView(label: "3:20 PM")
        .padding(Spacing.screen)
        .background { AppBackground() }
}
