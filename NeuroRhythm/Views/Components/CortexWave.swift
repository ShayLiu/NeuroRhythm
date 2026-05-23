import SwiftUI

struct CortexWaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        for x in stride(from: 0, through: rect.width, by: 1) {
            let y = rect.height - sin(x * 0.05) * 8
            path.addLine(to: CGPoint(x: x, y: y))
        }
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.closeSubpath()
        return path
    }
}

struct CortexCard<Content: View>: View {
    var accentColor: Color = NeuroDesign.accentMist
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            CortexWaveShape()
                .fill(accentColor.opacity(0.05))
                .frame(height: 20)

            content()
        }
        .background(
            RoundedRectangle(cornerRadius: NeuroDesign.radiusMd)
                .fill(.white.opacity(0.5))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: NeuroDesign.radiusMd))
        )
        .clipShape(RoundedRectangle(cornerRadius: NeuroDesign.radiusMd))
        .shadow(color: NeuroDesign.accentSage.opacity(0.06), radius: 12, y: 2)
    }
}
