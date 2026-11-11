import SwiftUI

// Ligne de notification : composant présentationnel. Une notification NON LUE est plus opaque, avec ombre et un point ;
// une notification lue s'efface (voile plus discret, pas d'ombre).
struct NotificationRowView: View {
    let notification: AppNotification
    let timeLabel: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: Spacing.m) {
                iconBadge
                VStack(alignment: .leading, spacing: 3) {
                    HStack(alignment: .firstTextBaseline, spacing: Spacing.s) {
                        Text(notification.title)
                            .font(.appRowTitle)
                            .foregroundStyle(Color.textPrimary)
                        Spacer(minLength: 0)
                        Text(timeLabel)
                            .font(.appCaption)
                            .foregroundStyle(Color.textSecondary)
                            // ⚛️ React : ≈ `numberOfLines={1}` : l'âge (« Yesterday ») ne passe jamais à la ligne.
                            .lineLimit(1)
                            .fixedSize()
                    }
                    Text(notification.message)
                        .font(.appCardBody)
                        .foregroundStyle(Color.textSecondary)
                        .lineSpacing(2)
                        // ⚛️ React : sans `fixedSize(vertical: true)`, un texte de plusieurs lignes peut être tronqué
                        // quand le parent manque de hauteur ; ici la ligne grandit avec son contenu.
                        .fixedSize(horizontal: false, vertical: true)
                }
                if !notification.isRead {
                    Circle()
                        .fill(Color.appPrimaryStrong)
                        .frame(width: Size.badge, height: Size.badge)
                        // Centré verticalement sur la ligne, comme dans le canvas.
                        .frame(maxHeight: .infinity)
                        .accessibilityHidden(true)
                }
            }
            .padding(Spacing.row)
            .frame(maxWidth: .infinity, alignment: .leading)
            // Même modifier que les autres cartes, avec un voile et un liseré qui dépendent de l'état lu / non lu.
            .glassCard(
                cornerRadius: Radius.task,
                fill: notification.isRead ? Color.notificationReadFill : Color.notificationUnreadFill,
                stroke: notification.isRead ? Color.glassStroke : Color.notificationUnreadStroke,
                hasShadow: !notification.isRead
            )
        }
        .buttonStyle(.plain)
        // Une seule annonce VoiceOver : « Focus session complete, You focused…, Just now, Unread ».
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(notification.title), \(notification.message), \(timeLabel)")
        .accessibilityValue(notification.isRead ? "" : tr("Unread"))
    }

    private var iconBadge: some View {
        Image(systemName: notification.kind.systemImage)
            .font(.appIconButton)
            .foregroundStyle(iconForeground)
            .frame(width: Size.notificationIcon, height: Size.notificationIcon)
            .background(Circle().fill(iconFill))
            .accessibilityHidden(true)
    }

    // Les rappels (rapport, objectif) ont une pastille pâle ; les événements, un dégradé coloré comme les stats de Home.
    private var iconForeground: Color {
        switch notification.kind {
        case .weeklyReport, .dailyGoal: Color.appPrimaryStrong
        default: Color.textOnAccent
        }
    }

    private var iconFill: AnyShapeStyle {
        switch notification.kind {
        case .focusSession: gradient(Color.statFocusLight, Color.statFocusDark)
        case .streak: gradient(Color.statStreakLight, Color.statStreakDark)
        case .taskCompleted: gradient(Color.statTasksLight, Color.statTasksDark)
        case .weeklyReport, .dailyGoal: AnyShapeStyle(Color.tabPill)
        }
    }

    // ⚛️ React : `AnyShapeStyle` ≈ un type « n'importe quel style » : il permet de renvoyer tantôt une couleur, tantôt
    // un dégradé depuis le même `switch` (≈ une union `Color | Gradient` en TypeScript).
    private func gradient(_ light: Color, _ dark: Color) -> AnyShapeStyle {
        AnyShapeStyle(LinearGradient(colors: [light, dark], startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}

#Preview {
    ZStack {
        AppBackground()
        VStack(spacing: Spacing.m) {
            ForEach(MockData.notifications) { notification in
                NotificationRowView(notification: notification, timeLabel: "2h ago", onTap: {})
            }
        }
        .padding(Spacing.screen)
    }
}
