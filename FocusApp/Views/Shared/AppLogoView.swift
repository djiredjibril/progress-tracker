import SwiftUI

// Le logo : un anneau de progression et une coche, dessinés en code. Les proportions sont celles de l'icône (1024 pt).
// Paramétrable pour l'animation du Splash : on peut faire « se dessiner » l'anneau et faire apparaître la coche.
struct AppLogoView: View {
    var size: CGFloat
    var arcProgress: Double = 0.75
    var checkScale: CGFloat = 1
    var checkOpacity: Double = 1

    var body: some View {
        // Toutes les mesures sont des fractions de `size` (référence : un canevas de 1024).
        let unit = size / 1024
        let ringDiameter = 580 * unit
        let ringStroke = 72 * unit

        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.25), lineWidth: ringStroke)
                .frame(width: ringDiameter, height: ringDiameter)
            // ⚛️ voir CONCEPTS.md#trim-ring : l'arc blanc se dessine en animant `trim`.
            Circle()
                .trim(from: 0, to: arcProgress)
                .stroke(Color.white, style: StrokeStyle(lineWidth: ringStroke, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: ringDiameter, height: ringDiameter)
            LogoCheckShape()
                .stroke(Color.white, style: StrokeStyle(lineWidth: 76 * unit, lineCap: .round, lineJoin: .round))
                .frame(width: size, height: size)
                .scaleEffect(checkScale)
                .opacity(checkOpacity)
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("FocusApp")
    }
}

// ⚛️ React : un `Shape` ≈ un `<Path d="…">` SVG : on décrit le tracé, puis on le colore avec `.stroke` / `.fill`.
// Les coordonnées viennent de l'icône (canevas de 1024) et sont mises à l'échelle de la place disponible.
private struct LogoCheckShape: Shape {
    func path(in rect: CGRect) -> Path {
        let unit = rect.width / 1024
        var path = Path()
        path.move(to: CGPoint(x: 392 * unit, y: 522 * unit))
        path.addLine(to: CGPoint(x: 478 * unit, y: 606 * unit))
        path.addLine(to: CGPoint(x: 650 * unit, y: 430 * unit))
        return path
    }
}

#Preview {
    ZStack {
        LinearGradient(colors: [Color.brandStart, Color.brandMid, Color.brandEnd], startPoint: .top, endPoint: .bottom)
        AppLogoView(size: Size.splashLogo)
    }
}
