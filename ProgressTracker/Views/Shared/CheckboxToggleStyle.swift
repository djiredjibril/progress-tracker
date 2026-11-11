import SwiftUI

// ⚛️ React : un `ToggleStyle` redessine un `Toggle` (≈ un composant `<Checkbox>` sur mesure) SANS perdre ce que le
// `Toggle` apporte : état lié par `Binding`, accessibilité (trait « bouton à bascule ») et action par défaut.
// `configuration.label` est le texte, `configuration.isOn` l'état, `configuration.$isOn` le binding.
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(alignment: .top, spacing: Spacing.m) {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .font(.appSheetTitle.weight(.regular))
                    .foregroundStyle(configuration.isOn ? Color.appPrimaryStrong : Color.textSecondary)
                    .contentTransition(.symbolEffect(.replace))
                configuration.label
                    .font(.appCardBody)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isToggle)
        .accessibilityValue(configuration.isOn ? "Checked" : "Unchecked")
    }
}

extension ToggleStyle where Self == CheckboxToggleStyle {
    static var checkbox: CheckboxToggleStyle { CheckboxToggleStyle() }
}

#Preview {
    @Previewable @State var agrees = true
    return Toggle("I agree to the Terms of Service and Privacy Policy.", isOn: $agrees)
        .toggleStyle(.checkbox)
        .padding(Spacing.screen)
        .background { AppBackground() }
}
