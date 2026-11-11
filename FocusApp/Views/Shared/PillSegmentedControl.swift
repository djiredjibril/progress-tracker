import SwiftUI

// Contrôle segmenté sur mesure (le `Picker(.segmented)` natif ne se stylise pas assez). Il sera réutilisé par
// Analytics (Week / Month / Year).
// ⚛️ React : `<Option: Hashable>` est un *générique* : ≈ `function SegmentedControl<T>({ value, options, label })` en
// TypeScript. Le même composant sert pour une priorité, une période… : c'est l'appelant qui choisit le type.
struct PillSegmentedControl<Option: Hashable>: View {
    // ⚛️ voir CONCEPTS.md#binding : le parent possède la sélection, ce composant la lit et l'écrit.
    @Binding var selection: Option
    let options: [Option]
    let title: (Option) -> String
    // `neutral` : piste grise (priorité d'une tâche). `glass` : piste en verre et texte violet (période d'Analytics).
    var style: Style = .neutral

    enum Style { case neutral, glass }

    // ⚛️ voir CONCEPTS.md#matched-geometry : la pastille blanche glisse d'une option à l'autre.
    @Namespace private var thumbNamespace

    var body: some View {
        HStack(spacing: 0) {
            // `id: \.self` : l'option elle-même sert de clé (c'est `Hashable`), comme `key={option}` en React.
            ForEach(options, id: \.self) { option in
                segment(option)
            }
        }
        .padding(Spacing.xs)
        .background(track)
        // Une seule annonce pour VoiceOver : « Priority » puis la valeur choisie.
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var track: some View {
        let shape = RoundedRectangle(cornerRadius: Radius.field, style: .continuous)
        switch style {
        case .neutral:
            shape.fill(Color.segmentTrack)
        case .glass:
            shape.fill(Color.glassFill).overlay(shape.strokeBorder(Color.glassStroke, lineWidth: 1))
        }
    }

    private func segment(_ option: Option) -> some View {
        let isSelected = option == selection
        return Button {
            withAnimation(.snappy) { selection = option }
        } label: {
            Text(title(option))
                .font(isSelected ? .appChip : .appLink)
                .foregroundStyle(isSelected ? (style == .glass ? Color.appPrimaryStrong : Color.textPrimary) : Color.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: Size.segmentHeight)
                .background {
                    if isSelected {
                        RoundedRectangle(cornerRadius: Radius.segment, style: .continuous)
                            .fill(Color.fieldFill)
                            .shadow(color: Color.cardShadow, radius: Shadow.segmentRadius, y: Shadow.segmentY)
                            .matchedGeometryEffect(id: "thumb", in: thumbNamespace)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    @Previewable @State var priority: TaskPriority = .medium
    return PillSegmentedControl(selection: $priority, options: TaskPriority.allCases, title: \.title)
        .padding(Spacing.screen)
        .background { AppBackground() }
}
