import Charts
import SwiftUI

// Carte « Focus time » : le total de la période et un histogramme (Swift Charts).
// Composant présentationnel : il reçoit le titre, le total et les barres.
struct FocusChartCard: View {
    let title: String
    let total: TimeInterval
    let bars: [FocusBar]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m + 2) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.appStatLabel)
                        .foregroundStyle(Color.textSecondary)
                    Text(totalText)
                        .foregroundStyle(Color.textPrimary)
                        // Les chiffres défilent quand on change de période (voir CONCEPTS.md#symbol-effect).
                        .contentTransition(.numericText())
                }
                Spacer()
                Image(systemName: "clock")
                    .font(.appStatIcon)
                    .foregroundStyle(Color.textOnAccent)
                    .frame(width: Size.statIcon, height: Size.statIcon)
                    .background(
                        Circle().fill(
                            LinearGradient(
                                colors: [Color.statFocusLight, Color.statFocusDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    )
                    .accessibilityHidden(true)
            }
            chart
        }
        .padding(Spacing.l + 2)
        .glassCard(cornerRadius: Radius.card, fill: Color.notificationUnreadFill, stroke: Color.notificationUnreadStroke)
        .accessibilityElement(children: .contain)
    }

    // « 15h 42m » avec de grands chiffres et de petites unités.
    private var totalText: AttributedString {
        let minutes = Int(total) / 60
        return .stat([(minutes / 60, "h"), (minutes % 60, "m")], valueFont: .appChartValue, unitFont: .appChartUnit)
    }

    // ⚛️ React : `Chart` ≈ un composant de graphique (Victory, `react-native-chart-kit`) mais natif et DÉCLARATIF :
    // pour chaque donnée on décrit une « marque » (`BarMark`) et ses propriétés (x, y, couleur). Les axes, l'échelle et
    // les animations sont calculés par le framework. C'est du SDK Apple : aucune dépendance tierce (D-011, D-032).
    private var chart: some View {
        let tallest = bars.map(\.seconds).max() ?? 0
        // Marge au-dessus de la plus haute barre pour l'infobulle ; hauteur minimale d'une barre « vide ».
        let yMax = max(tallest * 1.45, 3600)
        let minimumVisible = yMax * 0.06

        return Chart(bars) { bar in
            BarMark(
                // ⚛️ React : une abscisse de type TEXTE (≈ une échelle `band` de d3) : chaque barre occupe une « case » de
                // largeur égale, et `.ratio(0.7)` en remplit 70 %. Avec un nombre en abscisse, la largeur n'était pas définie.
                x: .value("Period", bar.name),
                y: .value("Focus", max(bar.seconds, minimumVisible)),
                width: .ratio(0.7)
            )
            .foregroundStyle(style(for: bar))
            .cornerRadius(Radius.tag)
            // ⚛️ React : `annotation` ≈ un tooltip positionné sur la barre (`position: 'absolute'`), mais ancré à la
            // marque : il suit la barre quand l'échelle change.
            .annotation(position: .top, spacing: Spacing.xs + 2, overflowResolution: .init(x: .fit(to: .chart), y: .disabled)) {
                if bar.isCurrent { tooltip(bar) }
            }
            // VoiceOver lit chaque barre : « Wednesday, 6h 24m ».
            .accessibilityLabel(bar.name)
            .accessibilityValue(bar.seconds.shortDurationLabel)
        }
        .chartYScale(domain: 0...yMax)
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks(values: bars.map(\.name)) { value in
                AxisValueLabel(centered: true) {
                    if let name = value.as(String.self), let bar = bars.first(where: { $0.name == name }) {
                        Text(bar.label)
                            .font(bar.isCurrent ? .appCaption.weight(.bold) : .appCaption)
                            .foregroundStyle(bar.isCurrent ? Color.appPrimaryStrong : Color.textSecondary)
                    }
                }
            }
        }
        .frame(height: Size.chartHeight)
        // Les barres changent de hauteur en douceur quand on change de période.
        .animation(.snappy, value: bars.map(\.seconds))
    }

    // ⚛️ voir CONCEPTS.md#any-shape-style : un `switch` qui renvoie tantôt un dégradé, tantôt une couleur.
    private func style(for bar: FocusBar) -> AnyShapeStyle {
        if bar.isCurrent {
            return AnyShapeStyle(LinearGradient(
                colors: [Color.ringGradientStart, Color.appPrimaryStrong],
                startPoint: .top,
                endPoint: .bottom
            ))
        }
        return AnyShapeStyle(bar.isFuture ? Color.chartBarFuture : Color.chartBarPast)
    }

    private func tooltip(_ bar: FocusBar) -> some View {
        Text(bar.seconds.shortDurationLabel)
            .font(.appTag.weight(.bold))
            .foregroundStyle(Color.textOnAccent)
            .padding(.horizontal, Spacing.xs + 2)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: Radius.segment - 4, style: .continuous)
                    .fill(Color.textPrimary)
            )
    }
}

#Preview {
    FocusChartCard(
        title: "Focus time this week",
        total: 15 * 3600 + 42 * 60,
        bars: AnalyticsViewModel().bars(todayFocus: 6 * 3600 + 24 * 60)
    )
    .padding(Spacing.screen)
    .background { AppBackground() }
}
