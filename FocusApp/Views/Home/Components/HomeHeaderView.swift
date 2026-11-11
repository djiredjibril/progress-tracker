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
        VStack(alignment: .leading, spacing: Spacing.m) {
            HStack(spacing: Spacing.s) {
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
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(greeting)
                        .font(.appGreeting)
                        .foregroundStyle(Color.textSecondary)
                    Text("Hello, \(firstName) 👋")
                        .font(.appLargeTitle)
                        .foregroundStyle(Color.textPrimary)
                        // ⚛️ React : ≈ `numberOfLines={1}` + `adjustsFontSizeToFit` : le titre rétrécit au lieu de passer à la ligne.
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    // Saut de ligne explicite pour reproduire la coupe de la maquette (2 lignes).
                    Text("Make today productive\nand achieve your goals.")
                        .font(.appBody)
                        .foregroundStyle(Color.textSecondary)
                        .padding(.top, Spacing.xs)
                }
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
            // ⚛️ React : `offset` ≈ `transform: [{ translateY }]` : il déplace le dessin SANS changer la place
            // réservée dans la mise en page. L'avatar déborde donc sur les cartes de stats (voir `zIndex` dans HomeView).
            .offset(y: Size.avatarOverlap)
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
