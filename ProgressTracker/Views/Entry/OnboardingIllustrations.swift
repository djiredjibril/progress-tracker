import SwiftUI

// Les trois illustrations de l'onboarding. Elles RÉUTILISENT les vrais composants de l'app (ligne de tâche, anneau du
// minuteur, carte objectif) : c'est du « faux contenu » non interactif, pas de nouveaux dessins à maintenir.

// Pastille flottante (icône colorée + texte) posée sur une illustration.
struct FloatingChip: View {
    let systemImage: String
    let colors: [Color]
    let text: String

    var body: some View {
        HStack(spacing: Spacing.s) {
            Image(systemName: systemImage)
                .font(.appEyebrowIcon)
                .foregroundStyle(Color.textOnAccent)
                .frame(width: 24, height: 24)
                .background(
                    Circle().fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                )
            Text(text)
                .font(.appStatLabel.weight(.semibold))
                .foregroundStyle(Color.textPrimary)
        }
        .padding(.horizontal, Spacing.m)
        .padding(.vertical, Spacing.s)
        .background(Capsule().fill(Color.notificationUnreadFill))
        .overlay(Capsule().strokeBorder(Color.white, lineWidth: 1))
        .shadow(color: Color.cardShadow, radius: Shadow.cardRadius / 2, y: Shadow.cardY)
        .accessibilityHidden(true)
    }
}

// 1. Plan : une ligne de tâche au centre, deux lignes « fantômes » inclinées, et un badge.
struct PlanIllustration: View {
    var body: some View {
        VStack(spacing: Spacing.section) {
            ghostRow(width: 120).rotationEffect(.degrees(-4))
            TaskRowView(task: MockData.tasks[0], onToggle: {}, onEdit: {}, onDelete: {})
                .allowsHitTesting(false)
            ghostRow(width: 90).rotationEffect(.degrees(3))
        }
        // L'overlay est posé AVANT le padding : le badge se cale sur le bord de l'illustration, pas sur celui de l'écran.
        .overlay(alignment: .topTrailing) {
            FloatingChip(
                systemImage: "calendar",
                colors: [Color.appPrimaryLight, Color.appPrimaryStrong],
                text: tr("4 tasks today")
            )
            .offset(x: Spacing.m + 2, y: Spacing.section * 2)
        }
        // Les illustrations sont inscrites à 40 pt des bords (comme le canvas) : le badge, qui déborde un peu, reste visible.
        .padding(.horizontal, Spacing.screen * 2)
    }

    // Une ligne « squelette » : un cercle et deux traits.
    private func ghostRow(width: CGFloat) -> some View {
        HStack(spacing: Spacing.m) {
            Circle().strokeBorder(Color.textTertiary, lineWidth: 2).frame(width: Size.checkbox - 2, height: Size.checkbox - 2)
            VStack(alignment: .leading, spacing: 6) {
                Capsule().fill(Color.textPrimary.opacity(0.18)).frame(width: width, height: 10)
                Capsule().fill(Color.textPrimary.opacity(0.10)).frame(width: width * 0.6, height: 8)
            }
            Spacer()
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity)
        .glassCard(cornerRadius: Radius.task, hasShadow: false)
        .opacity(0.8)
    }
}

// 2. Focus : l'anneau du minuteur et deux pastilles.
struct FocusIllustration: View {
    var body: some View {
        FocusRingView(progress: 0.7) {
            VStack(spacing: 2) {
                Text("25:00")
                    .font(.appTimer)
                    .tracking(-1.2)
                    .foregroundStyle(Color.textPrimary)
                Text("Focus session")
                    .font(.appStatLabel)
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .overlay(alignment: .topLeading) {
            FloatingChip(systemImage: "target", colors: [Color.statTasksLight, Color.statTasksDark], text: "Deep work")
                .offset(x: -Spacing.section, y: Spacing.section)
        }
        .overlay(alignment: .bottomTrailing) {
            FloatingChip(systemImage: "clock", colors: [Color.statFocusLight, Color.statFocusDark], text: "6h 24m today")
                .offset(x: Spacing.section, y: -Spacing.s)
        }
    }
}

// 3. Progress : la carte objectif, une pastille de série et un mini histogramme.
struct ProgressIllustration: View {
    private let barHeights: [CGFloat] = [26, 34, 46, 30, 40, 22, 36]

    var body: some View {
        VStack(spacing: Spacing.l) {
            GoalCardView(title: tr("Keep Going!"), progress: 0.7, percent: 70, onTap: {})
                .allowsHitTesting(false)
                .overlay(alignment: .topLeading) {
                    FloatingChip(
                        systemImage: "flame.fill",
                        colors: [Color.statStreakLight, Color.statStreakDark],
                        text: tr("%lld-day streak", 5)
                    )
                    .offset(x: -Spacing.m, y: -Spacing.section)
                }
            HStack(alignment: .bottom, spacing: Spacing.s) {
                ForEach(Array(barHeights.enumerated()), id: \.offset) { index, height in
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(index == 2
                              ? AnyShapeStyle(LinearGradient(colors: [Color.ringGradientStart, Color.appPrimaryStrong],
                                                             startPoint: .top, endPoint: .bottom))
                              : AnyShapeStyle(Color.chartBarPast))
                        .frame(height: height)
                }
            }
            .padding(Spacing.m)
            .frame(maxWidth: .infinity)
            .glassCard(cornerRadius: Radius.task)
            .padding(.horizontal, Spacing.m)
        }
        .padding(.horizontal, Spacing.screen * 2)
    }
}

#Preview("Plan") { PlanIllustration().padding().background { AppBackground() } }
#Preview("Focus") { FocusIllustration().padding().background { AppBackground() } }
#Preview("Progress") { ProgressIllustration().padding().background { AppBackground() } }
