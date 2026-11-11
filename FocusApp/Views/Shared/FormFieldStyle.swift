import SwiftUI

// ⚛️ voir CONCEPTS.md#view-modifier : le même principe que `.glassCard()`, pour l'aspect d'un champ de formulaire.
// Partagé par la feuille « New Task » et les écrans Log In / Sign Up.
struct FormFieldStyle: ViewModifier {
    let isFocused: Bool

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: Radius.field, style: .continuous)
        content
            .padding(.horizontal, Spacing.l)
            .frame(height: Size.field)
            .background(shape.fill(Color.fieldFill))
            .overlay(
                shape.strokeBorder(
                    isFocused ? Color.appPrimaryLight : Color.fieldBorder,
                    lineWidth: isFocused ? 1.5 : 1
                )
            )
            // Halo violet autour du champ qui a le focus (posé DERRIÈRE le champ : seule sa partie extérieure se voit).
            .background(shape.stroke(Color.focusRing, lineWidth: Spacing.s).opacity(isFocused ? 1 : 0))
            .animation(.snappy(duration: 0.15), value: isFocused)
    }
}

extension View {
    func formField(isFocused: Bool = false) -> some View {
        modifier(FormFieldStyle(isFocused: isFocused))
    }
}
