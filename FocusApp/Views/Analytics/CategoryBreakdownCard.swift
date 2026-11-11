import SwiftUI

// Carte « Time by category » : une barre horizontale par catégorie.
struct CategoryBreakdownCard: View {
    let shares: [CategoryShare]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text("Time by category")
                .font(.appHeadline)
                .foregroundStyle(Color.textPrimary)
                .accessibilityAddTraits(.isHeader)
            ForEach(shares) { share in
                row(share)
            }
        }
        .padding(Spacing.l)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: Radius.stat, hasShadow: false)
    }

    private func row(_ share: CategoryShare) -> some View {
        VStack(spacing: 6) {
            HStack {
                Text(share.category.title)
                    .font(.appStatLabel.weight(.medium))
                    .foregroundStyle(Color.textPrimary)
                Spacer()
                Text("\(share.percent)%")
                    .font(.appStatLabel)
                    .foregroundStyle(Color.textSecondary)
                    .contentTransition(.numericText())
            }
            // ⚛️ voir CONCEPTS.md#geometry-reader : la largeur du remplissage est un pourcentage de la piste.
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.categoryTrack)
                    Capsule()
                        .fill(share.category.tint)
                        .frame(width: proxy.size.width * CGFloat(share.percent) / 100)
                }
            }
            .frame(height: Size.progressBar)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(share.category.title)
        .accessibilityValue("\(share.percent) percent")
    }
}

#Preview {
    CategoryBreakdownCard(shares: MockData.analytics.summaries[.week]?.shares ?? [])
        .padding(Spacing.screen)
        .background { AppBackground() }
}
