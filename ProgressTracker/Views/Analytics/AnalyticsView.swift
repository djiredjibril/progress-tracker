import SwiftUI

// Écran Analytics : période, graphique de focus, tâches faites, meilleure série et répartition par catégorie.
struct AnalyticsView: View {
    // ⚛️ React : `@Bindable` permet de faire un `Binding` (`$viewModel.period`) vers une propriété d'un objet
    // `@Observable` reçu en paramètre : ici pour brancher le contrôle segmenté sur `period`.
    @Bindable var viewModel: AnalyticsViewModel
    // Temps de focus d'aujourd'hui, venu de Home : la barre du jour bouge quand on termine une session.
    let todayFocus: TimeInterval

    var body: some View {
        let summary = viewModel.summary

        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.l) {
                Text("Analytics")
                    .font(.appLargeTitle)
                    .foregroundStyle(Color.textPrimary)
                    .accessibilityAddTraits(.isHeader)

                PillSegmentedControl(
                    selection: $viewModel.period,
                    options: AnalyticsPeriod.allCases,
                    title: \.title,
                    style: .glass
                )

                FocusChartCard(
                    title: viewModel.period.focusTitle,
                    total: viewModel.totalFocus(todayFocus: todayFocus),
                    bars: viewModel.bars(todayFocus: todayFocus)
                )

                HStack(spacing: Spacing.m) {
                    TasksDoneCard(done: summary.tasksDone, planned: summary.tasksPlanned, progress: summary.tasksProgress)
                    StreakCard(days: summary.bestStreakDays)
                }

                CategoryBreakdownCard(shares: summary.shares)
            }
            .padding(.horizontal, Spacing.screen)
            .padding(.top, Spacing.s)
            .padding(.bottom, Spacing.section)
            .animation(.snappy, value: viewModel.period)
        }
        .scrollIndicators(.hidden)
        .background { AppBackground() }
    }
}

// MARK: - Cartes de synthèse (propres à cet écran)

private struct TasksDoneCard: View {
    let done: Int
    let planned: Int
    let progress: Double

    var body: some View {
        HStack(spacing: Spacing.m) {
            ring
            VStack(alignment: .leading, spacing: 2) {
                Text("\(done) / \(planned)")
                    .font(.appRowTitle.weight(.bold))
                    .foregroundStyle(Color.textPrimary)
                    .contentTransition(.numericText())
                    // « 410 / 520 » (période Year) est plus large que « 9 / 12 » : on le garde sur une ligne.
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("Tasks done")
                    .font(.appStatLabel)
                    .foregroundStyle(Color.textSecondary)
                    // Une seule ligne : la carte a peu de place à côté de l'anneau.
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            Spacer(minLength: 0)
        }
        .padding(Spacing.row)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: Radius.stat, hasShadow: false)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Tasks done")
        .accessibilityValue("\(done) of \(planned), \(Int((progress * 100).rounded())) percent")
    }

    // Petit anneau : même principe que le minuteur (`trim`), en plus petit.
    private var ring: some View {
        ZStack {
            Circle().stroke(Color.miniRingTrack, lineWidth: Size.miniRingStroke)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.appPrimary, style: StrokeStyle(lineWidth: Size.miniRingStroke, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int((progress * 100).rounded()))%")
                .font(.appStatLabel.weight(.bold))
                .foregroundStyle(Color.textPrimary)
        }
        .padding(Size.miniRingStroke / 2)
        .frame(width: Size.miniRing, height: Size.miniRing)
        .animation(.snappy, value: progress)
    }
}

private struct StreakCard: View {
    let days: Int

    var body: some View {
        HStack(spacing: Spacing.m) {
            Image(systemName: "flame.fill")
                .font(.appIconButton)
                .foregroundStyle(Color.textOnAccent)
                .frame(width: Size.streakIcon, height: Size.streakIcon)
                .background(
                    Circle().fill(
                        LinearGradient(
                            colors: [Color.statStreakLight, Color.statStreakDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                )
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(days == 1 ? tr("%lld day", days) : tr("%lld days", days))
                    .font(.appRowTitle.weight(.bold))
                    .foregroundStyle(Color.textPrimary)
                Text("Best streak")
                    .font(.appStatLabel)
                    .foregroundStyle(Color.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(Spacing.row)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: Radius.stat, hasShadow: false)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    AnalyticsView(viewModel: AnalyticsViewModel(), todayFocus: MockData.stats.focusTime)
}
