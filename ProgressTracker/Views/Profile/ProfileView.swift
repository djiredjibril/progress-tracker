import SwiftUI

// Écran Profile : identité, statistiques, réglages et déconnexion.
struct ProfileView: View {
    let user: User
    let stats: UserStats
    // Branché à l'étape 14 (flux d'entrée) : pour l'instant l'écran de connexion n'existe pas encore.
    let onLogOut: () -> Void
    let onSaveProfile: (ProfileDraft) -> Void

    // ⚛️ React : `@AppStorage` ≈ un `useState` PERSISTÉ dans `AsyncStorage` : la valeur est relue au lancement, et
    // toute vue qui utilise la même clé (ici aussi `RootView`) se met à jour quand elle change. `$notificationsEnabled`
    // donne un `Binding` pour le `Toggle`. Différence : c'est synchrone, sans `await`, et sans provider à écrire.
    @AppStorage(SettingsKey.notificationsEnabled) private var notificationsEnabled = true
    @AppStorage(SettingsKey.dailyGoal) private var dailyGoal = SettingsOptions.defaultDailyGoal
    @AppStorage(SettingsKey.focusMinutes) private var focusMinutes = SettingsOptions.defaultFocusMinutes
    @AppStorage(SettingsKey.appearance) private var appearanceValue = AppearanceMode.system.rawValue

    @State private var isConfirmingLogOut = false
    @State private var isEditingProfile = false
    // ⚛️ React : ≈ `const [visible, setVisible] = useState(false)` d'un `<Modal presentationStyle="fullScreen">`.
    @State private var isReplayingIntro = false

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.l) {
                header
                identity
                statsStrip
                preferences
                support
            }
            .padding(.horizontal, Spacing.screen)
            .padding(.top, Spacing.s)
            .padding(.bottom, Spacing.section)
        }
        .scrollIndicators(.hidden)
        .background { AppBackground() }
        .sheet(isPresented: $isEditingProfile) {
            EditProfileView(user: user, onSave: onSaveProfile)
        }
        // ⚛️ React : `fullScreenCover` ≈ un `<Modal presentationStyle="fullScreen">` : il recouvre TOUT l'écran (tab bar comprise),
        // contrairement à `sheet` qui laisse voir l'écran dessous. On réutilise `OnboardingView` tel quel : seul son POINT DE SORTIE
        // change. Au premier lancement `onExit` mène à Sign Up / Log In ; ici, quelle que soit la sortie, on referme simplement.
        .fullScreenCover(isPresented: $isReplayingIntro) {
            OnboardingView { _ in isReplayingIntro = false }
        }
        // ⚛️ React : `confirmationDialog` ≈ `Alert.alert(title, message, [{ text, style: 'destructive' }, { style: 'cancel' }])`.
        // Sur iPhone c'est une feuille d'actions qui monte du bas ; l'action `.destructive` est en rouge.
        .confirmationDialog("Log out of Progress Tracker?", isPresented: $isConfirmingLogOut, titleVisibility: .visible) {
            Button("Log out", role: .destructive, action: onLogOut)
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Sections

    private var header: some View {
        HStack {
            Text("Profile")
                .font(.appLargeTitle)
                .foregroundStyle(Color.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            CircleIconButton(systemName: "pencil", accessibilityLabel: "Edit profile") { isEditingProfile = true }
        }
    }

    private var identity: some View {
        VStack(spacing: Spacing.xs) {
            AvatarImage(assetName: user.avatarName, url: user.avatarURL)
                .scaledToFill()
                .frame(width: Size.profileAvatar, height: Size.profileAvatar)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(Color.avatarBorder, lineWidth: 4))
                .shadow(color: Color.avatarShadow, radius: Shadow.avatarRadius, y: Shadow.avatarY)
                .padding(.bottom, Spacing.s)
                .accessibilityHidden(true)
            Text(user.firstName)
                .font(.appStatValue)
                .foregroundStyle(Color.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text(user.email)
                .font(.appCardBody)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private var statsStrip: some View {
        HStack(spacing: 0) {
            stat(value: "\(stats.tasksDone)", label: "Tasks Done")
            divider
            stat(value: "\(stats.focusHours)h \(stats.focusMinutes)m", label: "Focus Time")
            divider
            stat(value: "\(stats.streakDays)", label: "Day Streak")
        }
        .padding(.vertical, Spacing.m + 2)
        .glassCard(cornerRadius: Radius.stat)
    }

    private func stat(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.appProfileValue)
                .foregroundStyle(Color.textPrimary)
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(label)
                .font(.appCaption)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private var divider: some View {
        Rectangle().fill(Color.statDivider).frame(width: 1).padding(.vertical, 2)
    }

    private var preferences: some View {
        SettingsGroup {
            SettingsRow(
                systemImage: "bell",
                iconForeground: .appPrimaryStrong,
                iconBackground: .tabPill,
                title: "Notifications",
                showsTopDivider: false
            ) {
                // ⚛️ React : ≈ `<Switch value onValueChange />`, branché par `Binding` sur le réglage persisté.
                Toggle("Notifications", isOn: $notificationsEnabled)
                    .labelsHidden()
                    .tint(Color.appPrimaryStrong)
            }

            // ⚛️ voir CONCEPTS.md#form-controls : `Menu` + `Picker` ≈ un `<select>`. Le choix est écrit dans `dailyGoal`,
            // donc sauvegardé tout de suite grâce à `@AppStorage`.
            Menu {
                Picker("Daily goal", selection: $dailyGoal) {
                    ForEach(SettingsOptions.dailyGoalRange, id: \.self) { count in
                        Text(SettingsOptions.dailyGoalLabel(count)).tag(count)
                    }
                }
            } label: {
                SettingsRow(
                    systemImage: "target",
                    iconForeground: .appPrimaryStrong,
                    iconBackground: .tabPill,
                    title: "Daily goal"
                ) { SettingsValueTrailing(value: SettingsOptions.dailyGoalLabel(dailyGoal)) }
            }
            .accessibilityValue(SettingsOptions.dailyGoalLabel(dailyGoal))

            Menu {
                Picker("Focus session", selection: $focusMinutes) {
                    ForEach(SettingsOptions.focusMinuteOptions, id: \.self) { minutes in
                        Text(SettingsOptions.focusLabel(minutes)).tag(minutes)
                    }
                }
            } label: {
                SettingsRow(
                    systemImage: "clock",
                    iconForeground: .settingsBlueForeground,
                    iconBackground: .settingsBlueFill,
                    title: "Focus session"
                ) { SettingsValueTrailing(value: SettingsOptions.focusLabel(focusMinutes)) }
            }
            .accessibilityValue(SettingsOptions.focusLabel(focusMinutes))

            // ⚛️ Même mécanisme que les deux lignes précédentes : `@AppStorage` + `Menu` + `Picker`. `AppFlowView` relit ce
            // réglage et applique le mode à toute l'app : le changement est immédiat.
            Menu {
                Picker("Appearance", selection: $appearanceValue) {
                    ForEach(AppearanceMode.allCases) { mode in
                        Label(mode.title, systemImage: mode.systemImage).tag(mode.rawValue)
                    }
                }
            } label: {
                SettingsRow(
                    systemImage: AppearanceMode(storedValue: appearanceValue).systemImage,
                    iconForeground: .settingsCoralForeground,
                    iconBackground: .settingsCoralFill,
                    title: "Appearance"
                ) { SettingsValueTrailing(value: AppearanceMode(storedValue: appearanceValue).title) }
            }
            .accessibilityValue(AppearanceMode(storedValue: appearanceValue).title)
        }
    }

    private var support: some View {
        SettingsGroup {
            Button { isReplayingIntro = true } label: {
                SettingsRow(
                    systemImage: "play.circle",
                    iconForeground: .appPrimaryStrong,
                    iconBackground: .tabPill,
                    title: "Replay introduction",
                    showsTopDivider: false
                ) {
                    Image(systemName: "chevron.right")
                        .font(.appLinkChevron)
                        .foregroundStyle(Color.textSecondary)
                        .accessibilityHidden(true)
                }
            }
            .buttonStyle(.plain)

            // Action mock : pas d'écran d'aide dans le design.
            Button {} label: {
                SettingsRow(
                    systemImage: "questionmark.circle",
                    iconForeground: .textPrimary,
                    iconBackground: .closeFill,
                    title: "Help & Support"
                ) {
                    Image(systemName: "chevron.right")
                        .font(.appLinkChevron)
                        .foregroundStyle(Color.textSecondary)
                        .accessibilityHidden(true)
                }
            }
            .buttonStyle(.plain)

            Button { isConfirmingLogOut = true } label: {
                SettingsRow(
                    systemImage: "rectangle.portrait.and.arrow.right",
                    iconForeground: .destructive,
                    iconBackground: .settingsDestructiveFill,
                    title: "Log out",
                    titleFont: .appRowLabel.weight(.semibold),
                    titleColor: .destructive
                ) { EmptyView() }
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    ProfileView(user: MockData.user, stats: MockData.stats, onLogOut: {}, onSaveProfile: { _ in })
}
