import SwiftUI

// Tab bar dessinée à la main : une capsule en verre avec 4 onglets et un bouton + central qui dépasse (D-016).
struct CustomTabBar: View {
    // ⚛️ React : `@Binding` ≈ passer `value` ET `onChange` en props, regroupés en UN seul objet. Le parent possède
    // l'état (`@State` dans RootView) ; ici on peut le LIRE (`selection`) et l'ÉCRIRE (`selection = tab`), et le
    // parent se re-rend. Le parent le passe avec `$` : `CustomTabBar(selection: $selectedTab)`.
    @Binding var selection: AppTab
    let onAdd: () -> Void

    // ⚛️ React : `@Namespace` fournit un « espace de noms » d'animation. Deux vues qui déclarent le même `id` dans
    // le même namespace sont considérées comme LA MÊME pastille : SwiftUI la fait glisser de l'une à l'autre.
    // Pas d'équivalent RN simple (il faudrait mesurer les positions avec `onLayout` et animer à la main).
    @Namespace private var pillNamespace

    var body: some View {
        // ⚛️ React : `allCases` vient de `CaseIterable`. 5 colonnes de même largeur (comme `grid-template-columns: repeat(5, 1fr)`
        // du canvas) : 2 onglets, la colonne du bouton +, puis 2 onglets.
        let tabs = AppTab.allCases
        HStack(spacing: 0) {
            ForEach(tabs.prefix(2)) { tabButton($0) }
            Color.clear.frame(maxWidth: .infinity, maxHeight: 0)
            ForEach(tabs.dropFirst(2)) { tabButton($0) }
        }
        .frame(height: Size.tabBarHeight)
        // Fond du canvas : blanc à 78 %, liseré blanc à 90 %, ombre violette (au lieu de la carte en verre standard).
        .glassCard(
            cornerRadius: Radius.tabBar,
            fill: Color.tabBarFill,
            stroke: Color.tabBarStroke,
            shadowColor: Color.tabBarShadow,
            shadowRadius: Shadow.tabBarRadius,
            shadowY: Shadow.tabBarY
        )
        // ⚛️ React : le bouton + est posé au centre-haut de la barre puis remonté (`offset`) : il dépasse de 16 pt vers
        // le haut sans changer la hauteur de la barre.
        .overlay(alignment: .top) {
            addButton
                .offset(y: -Size.fabRaise)
        }
    }

    private func tabButton(_ tab: AppTab) -> some View {
        let isSelected = selection == tab
        return Button {
            // `withAnimation` : le changement de `selection` fait glisser la pastille (voir matchedGeometryEffect).
            withAnimation(.snappy) { selection = tab }
        } label: {
            VStack(spacing: 3) {
                // La pastille de l'onglet actif est derrière l'ICÔNE seule (48 × 30 pt), pas derrière toute la colonne.
                Image(systemName: tab.systemImage)
                    .font(isSelected ? .appTabIcon.weight(.semibold) : .appTabIcon)
                    .frame(width: Size.tabIconWidth, height: Size.tabIconHeight)
                    .background {
                        if isSelected {
                            // ⚛️ React : la pastille n'existe que derrière l'onglet actif. Comme elle porte le même `id`,
                            // SwiftUI la déplace d'un onglet à l'autre au lieu de la supprimer puis de la recréer.
                            Capsule()
                                .fill(Color.tabPill)
                                .matchedGeometryEffect(id: "activeTabPill", in: pillNamespace)
                        }
                    }
                Text(tab.title)
                    .font(isSelected ? .appTabLabel.weight(.semibold) : .appTabLabel)
            }
            // Violet fort pour l'onglet actif, `textSecondary` (et non `textTertiary`, trop pâle) pour les autres :
            // les deux passent le contraste 4.5:1 du canvas (D-029).
            .foregroundStyle(isSelected ? Color.appPrimaryStrong : Color.textSecondary)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tab.title)
        // ⚛️ React : ≈ `accessibilityState={{ selected }}` de RN.
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var addButton: some View {
        Button(action: onAdd) {
            Image(systemName: "plus")
                .font(.appFabIcon)
                .foregroundStyle(Color.textOnAccent)
                .frame(width: Size.fab, height: Size.fab)
                .background(
                    Circle().fill(
                        LinearGradient(
                            colors: [Color.appPrimaryLight, Color.appPrimaryStrong],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                )
                // Liseré de la couleur du fond : le bouton « découpe » visuellement la barre (D-031).
                .overlay(Circle().strokeBorder(Color.backgroundBottom, lineWidth: Size.fabRing))
                .shadow(color: Color.fabShadow, radius: Shadow.fabRadius, y: Shadow.fabY)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add task")
    }
}

#Preview {
    // ⚛️ React : `@Previewable` permet de déclarer un `@State` DANS un `#Preview` (≈ un `useState` dans une story),
    // pour que le `Binding` soit réellement modifiable en cliquant dans le canevas.
    @Previewable @State var selection: AppTab = .home
    return ZStack(alignment: .bottom) {
        AppBackground()
        CustomTabBar(selection: $selection, onAdd: {})
            .padding(Spacing.screen)
    }
}
