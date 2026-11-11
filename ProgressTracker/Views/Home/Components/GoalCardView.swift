import SwiftUI

// Composant présentationnel (D-006). La phrase « You're 70% closer… » est DÉRIVÉE de `percent`, pas stockée.
// Mesures du canvas : 164 pt de haut, 20 pt de padding, texte en blanc pur, barre de 10 pt.
struct GoalCardView: View {
    let title: String
    let progress: Double        // 0...1, pilote la barre
    let percent: Int            // affiché en texte
    let onTap: () -> Void

    // ⚛️ React : `@Environment` ≈ un `useContext` (voir CONCEPTS.md#environment).
    @Environment(\.redactionReasons) private var redactionReasons

    private let mountainOpacity: Double = 0.9

    var body: some View {
        // ⚛️ React : `Spacer` entre le texte et la barre ≈ `justifyContent: 'space-between'` sur une hauteur fixe.
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: Spacing.s) {
                    Image(systemName: "target")
                        .font(.appEyebrowIcon)
                        .foregroundStyle(Color.brandEnd)
                        .frame(width: Size.eyebrowIcon, height: Size.eyebrowIcon)
                        .background(Circle().fill(Color.eyebrowDisc))
                        .accessibilityHidden(true)
                    Text("Today's Goal")
                        .font(.appCardEyebrow)
                        .foregroundStyle(Color.textOnAccent)
                }
                Text(title)
                    .font(.appCardTitle)
                    .foregroundStyle(Color.textOnAccent)
                // ⚛️ React : `\(percent)` dans la chaîne ≈ le template literal `${percent}` (voir CONCEPTS.md#viewbuilder).
                Text("You're \(percent)% closer to your goal.")
                    .font(.appCardBody)
                    .foregroundStyle(Color.textOnAccent)
            }
            // Le texte ne passe jamais sous le bouton › (largeur max du canvas : 230 pt).
            .frame(maxWidth: 230, alignment: .leading)
            // Accessibilité : VoiceOver lit « Today's Goal, Keep Going!, You're 70% closer… » d'un seul tenant.
            .accessibilityElement(children: .combine)

            Spacer(minLength: Spacing.s)

            HStack(spacing: Spacing.m) {
                ProgressBarView(progress: progress, height: Size.goalProgressBar)
                Text("\(percent)%")
                    .font(.appCardEyebrow.weight(.semibold))
                    .foregroundStyle(Color.textOnAccent)
                    // Doublon : la barre annonce déjà « Progress, 70 percent ».
                    .accessibilityHidden(true)
            }
        }
        .padding(Spacing.card)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: Size.goalCardHeight)
        .background { cardBackground }
        // ⚛️ React : le bouton est posé PAR-DESSUS la carte, à 20 pt de la droite et 52 pt du haut
        // (≈ `position: 'absolute', right: 20, top: 52`). Il est donc au-dessus de la montagne.
        .overlay(alignment: .topTrailing) { arrowButton }
    }

    // Fond : dégradé de la marque + montagne, découpés aux coins arrondis, puis ombre colorée.
    private var cardBackground: some View {
        let shape = RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
        return shape
            // ⚛️ voir CONCEPTS.md#gradient-blur : `110deg` en CSS ≈ de la gauche (un peu en haut) vers la droite (un peu en bas).
            .fill(
                LinearGradient(
                    stops: [
                        .init(color: Color.brandEnd, location: 0),
                        .init(color: Color.brandMid, location: 0.55),
                        .init(color: Color.brandStart, location: 1)
                    ],
                    startPoint: UnitPoint(x: 0.03, y: 0.14),
                    endPoint: UnitPoint(x: 0.97, y: 0.86)
                )
            )
            // ⚛️ voir CONCEPTS.md#layered-card : on clippe seulement la montagne, puis on ajoute l'ombre sur la forme.
            .overlay {
                // ⚛️ voir CONCEPTS.md#environment : pendant le squelette, une image devient un gros rectangle gris :
                // pour une image décorative, on ne dessine rien.
                if !redactionReasons.contains(.placeholder) {
                    GeometryReader { proxy in
                        Image("GoalMountain")
                            .resizable()
                            // ⚛️ React : `scaledToFit` ≈ `resizeMode="contain"` : l'image garde ses proportions.
                            .scaledToFit()
                            .frame(height: Size.goalMountain)
                            .opacity(mountainOpacity)
                            // On agrandit le cadre à toute la carte pour pouvoir coller la montagne en haut à droite.
                            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topTrailing)
                    }
                    .clipShape(shape)
                    // Décoratif : l'image n'apporte aucune information à VoiceOver.
                    .accessibilityHidden(true)
                }
            }
            .shadow(color: Color.goalShadow, radius: Shadow.goalRadius, y: Shadow.goalY)
    }

    private var arrowButton: some View {
        Button(action: onTap) {
            Image(systemName: "chevron.right")
                .font(.appIconButton)
                .foregroundStyle(Color.brandEnd)
                .frame(width: Size.goalArrow, height: Size.goalArrow)
                .background(
                    Circle().fill(Color.textOnAccent)
                        .shadow(color: Color.arrowShadow, radius: Shadow.arrowRadius, y: Shadow.arrowY)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("View today's goal")
        .padding(.top, 52)
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
