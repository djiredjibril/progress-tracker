import SwiftUI

struct HomeHeaderView: View {
    let greeting: String
    let firstName: String
    let avatarName: String
    let hasUnreadNotifications: Bool
    let onSearch: () -> Void
    let onNotifications: () -> Void

    var body: some View {
        // ⚛️ React : `VStack` ≈ `<View style={{ flexDirection: 'column' }}>`, `HStack` ≈ `flexDirection: 'row'`.
        // `alignment` ≈ `alignItems` (ici sur l'axe transversal), `spacing` ≈ `gap`.
        VStack(alignment: .leading, spacing: Spacing.l) {
            HStack(spacing: Spacing.s + 2) {
                // ⚛️ React : `Spacer` ≈ `<View style={{ flex: 1 }} />` : il prend tout l'espace libre et pousse
                // les boutons à droite (≈ `justifyContent: 'flex-end'`).
                Spacer()
                CircleIconButton(
                    systemName: "magnifyingglass",
                    accessibilityLabel: "Search",
                    action: onSearch
                )
                CircleIconButton(
                    systemName: "bell",
                    accessibilityLabel: "Notifications",
                    showsBadge: hasUnreadNotifications,
                    action: onNotifications
                )
            }

            HStack(alignment: .top, spacing: Spacing.m) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(greeting)
                        .font(.appGreeting)
                        .foregroundStyle(Color.textSecondary)
                    Text("Hello, \(firstName) 👋")
                        .font(.appLargeTitle)
                        .tracking(-0.5)
                        .foregroundStyle(Color.textPrimary)
                        // ⚛️ React : ≈ `numberOfLines={1}` + `adjustsFontSizeToFit` : le titre rétrécit au lieu de passer à la ligne.
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        // ⚛️ React : ≈ `accessibilityRole="header"` : VoiceOver permet de sauter de titre en titre.
                        // Le label remplace le texte lu, pour ne pas prononcer « waving hand » après le prénom.
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityLabel("Hello, \(firstName)")
                    // Saut de ligne explicite pour reproduire la coupe de la maquette (2 lignes).
                    Text("Make today productive\nand achieve your goals.")
                        .font(.appBody)
                        .foregroundStyle(Color.textSecondary)
                        .padding(.top, Spacing.xs)
                }
                .padding(.top, Spacing.xs)
                Spacer(minLength: 0)
                avatar
            }
        }
    }

    private var avatar: some View {
        // ⚛️ React : `Image("Avatar")` charge un asset du catalogue par son nom ≈ `<Image source={require('./avatar.png')} />`.
        // `resizable()` est obligatoire pour que l'image puisse être redimensionnée (sinon elle garde sa taille native).
        Image(avatarName)
            .resizable()
            // ⚛️ React : `scaledToFill` ≈ `resizeMode="cover"` (`scaledToFit` ≈ `contain`).
            .scaledToFill()
            .frame(width: Size.avatar, height: Size.avatar)
            // ⚛️ React : `clipShape(Circle())` ≈ `borderRadius: size / 2` + `overflow: 'hidden'`.
            // Important : le `frame` est posé AVANT le clip, sinon on découperait l'image non redimensionnée.
            .clipShape(Circle())
            // Ombre violette du canvas (0 12 28 rgba(108,108,245,.25)). L'avatar ne chevauche plus les cartes de stats :
            // le canvas les place 16 pt plus bas (D-042).
            .shadow(color: Color.avatarShadow, radius: Shadow.avatarRadius, y: Shadow.heroAvatarY)
            // Décoratif : VoiceOver l'ignore.
            .accessibilityHidden(true)
    }
}

#Preview {
    ZStack(alignment: .top) {
        AppBackground()
        HomeHeaderView(
            greeting: "Good Morning",
            firstName: MockData.user.firstName,
            avatarName: MockData.user.avatarName,
            hasUnreadNotifications: true,
            onSearch: {},
            onNotifications: {}
        )
        .padding(Spacing.screen)
    }
}
