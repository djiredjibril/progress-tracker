import SwiftUI

// Composant présentationnel (D-006). La phrase « You're 70% closer… » est DÉRIVÉE de `percent`, pas stockée.
struct GoalCardView: View {
    let title: String
    let progress: Double        // 0...1, pilote la barre
    let percent: Int            // affiché en texte
    let onTap: () -> Void

    // Réglages de la maquette : la montagne occupe ~75 % de la hauteur de la carte, légèrement translucide.
    private let mountainHeightRatio: CGFloat = 0.75
    private let mountainOpacity: Double = 0.9

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Label("Today's Goal", systemImage: "target")
                    .font(.appCardEyebrow)
                    .foregroundStyle(Color.textOnAccentSecondary)
                Text(title)
                    .font(.appCardTitle)
                    .foregroundStyle(Color.textOnAccent)
                // ⚛️ React : `\(percent)` dans la chaîne ≈ le template literal `${percent}` (voir CONCEPTS.md#viewbuilder).
                Text("You're \(percent)% closer to your goal.")
                    .font(.appCardBody)
                    .foregroundStyle(Color.textOnAccentSecondary)
            }
            // On réserve la place du bouton › pour que le texte ne passe jamais dessous.
            .padding(.trailing, Size.goalArrow + Spacing.s)

            HStack(spacing: Spacing.m) {
                ProgressBarView(progress: progress)
                Text("\(percent)%")
                    .font(.appCardEyebrow)
                    .foregroundStyle(Color.textOnAccentSecondary)
            }
            .padding(.top, Spacing.m)
        }
        .padding(Spacing.card)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background { cardBackground }
        // ⚛️ React : le bouton est posé PAR-DESSUS la carte, collé à droite et centré verticalement
        // (≈ `position: 'absolute', right: 20, top: '50%'`). Il est donc au-dessus de la montagne.
        .overlay(alignment: .trailing) { arrowButton }
    }

    // Fond : dégradé + montagne, découpés aux coins arrondis, puis ombre colorée.
    private var cardBackground: some View {
        let shape = RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
        return shape
            .fill(
                LinearGradient(
                    colors: [Color.goalGradientStart, Color.goalGradientMid, Color.goalGradientEnd],
                    startPoint: .bottomLeading,
                    endPoint: .topTrailing
                )
            )
            .overlay {
                // Ici le GeometryReader sert à connaître la hauteur de la carte pour dimensionner la montagne.
                GeometryReader { proxy in
                    Image("GoalMountain")
                        .resizable()
                        // ⚛️ React : `scaledToFit` ≈ `resizeMode="contain"` : l'image garde ses proportions.
                        .scaledToFit()
                        .frame(height: proxy.size.height * mountainHeightRatio)
                        .opacity(mountainOpacity)
                        // On agrandit le cadre à toute la carte pour pouvoir coller la montagne en haut à droite.
                        .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topTrailing)
                }
                .clipShape(shape)
                // Décoratif : l'image n'apporte aucune information à VoiceOver.
                .accessibilityHidden(true)
            }
            .shadow(color: Color.goalShadow, radius: Shadow.goalRadius, y: Shadow.goalY)
    }

    private var arrowButton: some View {
        Button(action: onTap) {
            Image(systemName: "chevron.right")
                .font(.appIconButton)
                .foregroundStyle(Color.appPrimary)
                .frame(width: Size.goalArrow, height: Size.goalArrow)
                .background(Circle().fill(Color.textOnAccent))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("View today's goal")
        .padding(.trailing, Spacing.card)
    }
}

#Preview {
    ZStack {
        AppBackground()
        GoalCardView(
            title: MockData.goal.title,
            progress: MockData.goal.progress,
            percent: MockData.goal.progressPercent,
            onTap: {}
        )
        .padding(Spacing.screen)
    }
}
