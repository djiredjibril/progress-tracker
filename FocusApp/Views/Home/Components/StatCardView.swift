import SwiftUI

// Composant présentationnel : il reçoit des valeurs, ignore le ViewModel (D-006).
struct StatCardView: View {
    let icon: String                    // nom du SF Symbol
    let iconColors: [Color]             // dégradé de la puce, du clair au foncé
    // ⚛️ React : `AttributedString` ≈ du texte riche (des « runs » avec chacun leur police/couleur).
    // Ici il permet de mélanger « 6 » (grand) et « h » (petit) dans UN seul texte aligné sur la ligne de base.
    let value: AttributedString
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            iconChip
                .padding(.bottom, Spacing.s)
            Text(value)
                .foregroundStyle(Color.textPrimary)
                // ⚛️ React : pas d'équivalent direct (il faudrait un compteur animé maison). `numericText` fait
                // défiler les chiffres quand la valeur change à l'intérieur d'un `withAnimation`.
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(label)
                .font(.appStatLabel)
                .foregroundStyle(Color.textSecondary)
                .lineLimit(1)
        }
        .padding(Spacing.m)
        // ⚛️ React : ≈ `flex: 1` : chaque carte prend une part ÉGALE de la largeur du HStack.
        // `alignment: .leading` recolle le contenu à gauche dans ce cadre élargi.
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: Radius.stat)
        // ⚛️ React : fusionne les enfants en UN seul élément d'accessibilité : VoiceOver lira « 12, Tasks Done »
        // d'un trait (≈ `accessible={true}` sur le conteneur en RN).
        .accessibilityElement(children: .combine)
    }

    private var iconChip: some View {
        Image(systemName: icon)
            .font(.appStatIcon)
            .foregroundStyle(Color.textOnAccent)
            .frame(width: Size.statIcon, height: Size.statIcon)
            .background(
                Circle().fill(
                    LinearGradient(colors: iconColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            )
            .accessibilityHidden(true)
    }
}

extension AttributedString {
    // Construit « 6h 24m » : chaque nombre en `appStatValue`, chaque unité en `appStatUnit`.
    // Une unité vide donne simplement « 12 ».
    static func stat(_ parts: [(value: Int, unit: String)]) -> AttributedString {
        var result = AttributedString()
        // ⚛️ React : `enumerated()` ≈ `.map((item, index) => …)` : on reçoit (index, élément).
        for (index, part) in parts.enumerated() {
            if index > 0 {
                var space = AttributedString(" ")
                space.font = .appStatUnit
                result += space
            }
            var number = AttributedString("\(part.value)")
            number.font = .appStatValue
            result += number

            if !part.unit.isEmpty {
                var unit = AttributedString(part.unit)
                unit.font = .appStatUnit
                result += unit
            }
        }
        return result
    }
}

#Preview {
    ZStack {
        AppBackground()
        HStack(spacing: Spacing.m) {
            StatCardView(
                icon: "chart.bar.fill",
                iconColors: [Color.statTasksLight, Color.statTasksDark],
                value: .stat([(MockData.stats.tasksDone, "")]),
                label: "Tasks Done"
            )
            StatCardView(
                icon: "clock",
                iconColors: [Color.statFocusLight, Color.statFocusDark],
                value: .stat([(MockData.stats.focusHours, "h"), (MockData.stats.focusMinutes, "m")]),
                label: "Focus Time"
            )
            StatCardView(
                icon: "flame.fill",
                iconColors: [Color.statStreakLight, Color.statStreakDark],
                value: .stat([(MockData.stats.streakDays, "")]),
                label: "Day Streak"
            )
        }
        .padding(Spacing.screen)
    }
}
