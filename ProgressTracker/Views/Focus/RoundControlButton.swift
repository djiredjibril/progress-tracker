import SwiftUI

// Bouton rond du minuteur : petit en verre (reset, skip) ou grand en dégradé (play / pause).
struct RoundControlButton: View {
    enum Style { case secondary, primary }

    let systemName: String
    let accessibilityLabel: String
    var style: Style = .secondary
    let action: () -> Void

    var body: some View {
        let isPrimary = style == .primary
        let size = isPrimary ? Size.controlPrimary : Size.controlSecondary

        Button(action: action) {
            Image(systemName: systemName)
                .font(isPrimary ? .appControlPrimaryIcon : .appControlIcon)
                .foregroundStyle(isPrimary ? Color.textOnAccent : Color.textPrimary)
                // ⚛️ React : pas d'équivalent direct (il faudrait animer deux icônes à la main) : quand `systemName`
                // change (play ↔ pause), le symbole se transforme en douceur au lieu de sauter.
                .contentTransition(.symbolEffect(.replace))
                .frame(width: size, height: size)
                .background {
                    if isPrimary {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.appPrimaryLight, Color.appPrimaryStrong],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color.fabShadow, radius: Shadow.controlRadius, y: Shadow.controlY)
                    } else {
                        Circle().fill(Color.glassFill)
                            .overlay(Circle().strokeBorder(Color.glassStroke, lineWidth: 1))
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

#Preview {
    HStack(spacing: Spacing.section) {
        RoundControlButton(systemName: "arrow.counterclockwise", accessibilityLabel: "Reset") {}
        RoundControlButton(systemName: "pause.fill", accessibilityLabel: "Pause", style: .primary) {}
        RoundControlButton(systemName: "forward.end.fill", accessibilityLabel: "Skip to break") {}
    }
    .padding(Spacing.screen)
    .background { AppBackground() }
}
