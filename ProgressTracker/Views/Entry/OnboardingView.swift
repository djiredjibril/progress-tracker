import SwiftUI

// Les trois pages de l'onboarding.
private enum OnboardingPage: Int, CaseIterable {
    case plan, focus, progress

    var title: String {
        switch self {
        case .plan: tr("Plan your day with ease")
        case .focus: tr("Stay in the zone")
        case .progress: tr("Watch your progress grow")
        }
    }

    var message: String {
        switch self {
        case .plan: tr("Organize your tasks, set a time for each one and see your whole day at a glance.")
        case .focus: tr("Start focus sessions, take breaks at the right time and track the hours you spend on what matters.")
        case .progress: tr("Build streaks, reach your daily goals and see how far you have come each week.")
        }
    }

    var blob: Color {
        switch self {
        case .plan: Color.onboardingBlobPlan
        case .focus: Color.onboardingBlobFocus
        case .progress: Color.onboardingBlobProgress
        }
    }
}

// Où mène la fin de l'onboarding.
enum OnboardingExit {
    case signUp         // « Get Started »
    case logIn          // « Skip » ou « I already have an account »
}

struct OnboardingView: View {
    let onExit: (OnboardingExit) -> Void

    // ⚛️ React : ≈ l'index courant d'un `FlatList` paginé / d'un `PagerView` : `TabView(selection:)` lit et écrit ce
    // `@State` (un `Binding`), donc glisser change la page ET changer la page par code fait glisser.
    @State private var page: OnboardingPage = .plan

    var body: some View {
        ZStack {
            AppBackground()
            // Une grande tache floue dont la couleur change avec la page.
            Circle()
                .fill(page.blob)
                .frame(width: Size.blob, height: Size.blob)
                .blur(radius: Size.blobBlur)
                .offset(y: -80)
                .animation(.smooth, value: page)
                .accessibilityHidden(true)

            VStack(spacing: 0) {
                skipRow
                // ⚛️ React : `.page` ≈ un `ScrollView horizontal pagingEnabled`. `indexDisplayMode: .never` masque les
                // points système : on dessine les nôtres (violet fort, point actif allongé).
                TabView(selection: $page) {
                    ForEach(OnboardingPage.allCases, id: \.self) { item in
                        pageContent(item).tag(item)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                bottomControls
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Sections

    private var skipRow: some View {
        HStack {
            Spacer()
            Button { onExit(.logIn) } label: {
                Text("Skip")
                    .font(.appRowLabel.weight(.semibold))
                    .foregroundStyle(Color.textSecondary)
                    .padding(.horizontal, Spacing.xs + 2)
                    .frame(minHeight: Size.circleButton)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.screen)
    }

    private func pageContent(_ item: OnboardingPage) -> some View {
        VStack(spacing: Spacing.section) {
            illustration(item)
                .frame(height: Size.onboardingArt)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)
            VStack(spacing: Spacing.m) {
                Text(item.title)
                    .font(.appDisplayTitle)
                    .tracking(-0.4)
                    .foregroundStyle(Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                Text(item.message)
                    .font(.appFieldText)
                    .lineSpacing(5)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, Spacing.section + Spacing.s)
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private func illustration(_ item: OnboardingPage) -> some View {
        switch item {
        case .plan: PlanIllustration()
        case .focus: FocusIllustration()
        case .progress: ProgressIllustration()
        }
    }

    private var bottomControls: some View {
        VStack(spacing: Spacing.section + Spacing.xs) {
            pageDots
            VStack(spacing: Spacing.s) {
                Button(page == .progress ? tr("Get Started") : tr("Next")) { advance() }
                    .buttonStyle(.primary)
                // Même emplacement sur toutes les pages : le bouton ne saute pas quand le lien apparaît.
                Button { onExit(.logIn) } label: {
                    Text("I already have an account")
                        .font(.appRowLabel.weight(.semibold))
                        .foregroundStyle(Color.appPrimaryStrong)
                        .frame(maxWidth: .infinity, minHeight: Size.circleButton)
                }
                .buttonStyle(.plain)
                .opacity(page == .progress ? 1 : 0)
                .disabled(page != .progress)
                .accessibilityHidden(page != .progress)
            }
        }
        .padding(.horizontal, Spacing.screen)
        .padding(.bottom, Spacing.row)
    }

    private var pageDots: some View {
        HStack(spacing: 6) {
            ForEach(OnboardingPage.allCases, id: \.self) { item in
                Capsule()
                    .fill(item == page ? Color.appPrimaryStrong : Color.pageDotInactive)
                    .frame(width: item == page ? Size.pageDotActiveWidth : Size.pageDot, height: Size.pageDot)
            }
        }
        .animation(.snappy, value: page)
        // « Step 1 of 3 » : un seul élément pour VoiceOver.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(tr("Step %lld of %lld", page.rawValue + 1, OnboardingPage.allCases.count))
    }

    private func advance() {
        if page == .progress {
            onExit(.signUp)
        } else if let next = OnboardingPage(rawValue: page.rawValue + 1) {
            withAnimation(.snappy) { page = next }
        }
    }
}

#Preview {
    OnboardingView(onExit: { _ in })
}
