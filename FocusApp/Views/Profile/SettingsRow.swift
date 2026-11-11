import SwiftUI

// Une ligne de réglage : pastille d'icône colorée, titre, puis un contenu à droite (valeur + chevron, interrupteur…).
// ⚛️ voir CONCEPTS.md#viewbuilder-prop : `Trailing` est un générique rempli par `@ViewBuilder` : l'appelant choisit ce
// qui apparaît à droite, comme avec une prop `children` / un render prop.
struct SettingsRow<Trailing: View>: View {
    let systemImage: String
    let iconForeground: Color
    let iconBackground: Color
    let title: String
    var titleFont: Font = .appRowLabel
    var titleColor: Color = .textPrimary
    // Le trait de séparation du haut : absent sur la première ligne d'un groupe.
    var showsTopDivider = true
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        HStack(spacing: Spacing.m) {
            Image(systemName: systemImage)
                .font(.appStatLabel.weight(.medium))
                .foregroundStyle(iconForeground)
                .frame(width: Size.settingsIcon, height: Size.settingsIcon)
                .background(
                    RoundedRectangle(cornerRadius: Radius.tag, style: .continuous).fill(iconBackground)
                )
                .accessibilityHidden(true)
            Text(title)
                .font(titleFont)
                .foregroundStyle(titleColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            trailing()
        }
        .padding(.leading, Spacing.row)
        .padding(.trailing, Spacing.m)
        .frame(height: Size.settingsRow)
        .overlay(alignment: .top) {
            if showsTopDivider {
                Rectangle().fill(Color.rowDivider).frame(height: 1)
            }
        }
        .contentShape(Rectangle())
    }
}

// Valeur grise suivie d'un chevron : le côté droit d'une ligne qui ouvre un choix.
struct SettingsValueTrailing: View {
    let value: String

    var body: some View {
        HStack(spacing: Spacing.s) {
            Text(value)
                .font(.appCardBody)
                .foregroundStyle(Color.textSecondary)
                .contentTransition(.numericText())
            Image(systemName: "chevron.right")
                .font(.appLinkChevron)
                .foregroundStyle(Color.textSecondary)
                .accessibilityHidden(true)
        }
    }
}

// Conteneur en verre qui regroupe plusieurs lignes.
struct SettingsGroup<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0, content: content)
            .padding(.vertical, Spacing.xs)
            .glassCard(cornerRadius: Radius.stat, hasShadow: false)
    }
}

#Preview {
    SettingsGroup {
        SettingsRow(
            systemImage: "target",
            iconForeground: .appPrimaryStrong,
            iconBackground: .tabPill,
            title: "Daily goal",
            showsTopDivider: false
        ) { SettingsValueTrailing(value: "5 tasks") }
        SettingsRow(
            systemImage: "arrow.right.square",
            iconForeground: .destructive,
            iconBackground: .settingsDestructiveFill,
            title: "Log out",
            titleFont: .appRowLabel.weight(.semibold),
            titleColor: .destructive
        ) { EmptyView() }
    }
    .padding(Spacing.screen)
    .background { AppBackground() }
}
