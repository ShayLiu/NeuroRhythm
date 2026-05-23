import SwiftUI

struct NeuralBackground: View {
    @State private var phase: Double = 0

    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let lineColor = Color(hex: "D1D9E0").opacity(0.2)
            let dotColor = Color(hex: "7DBCB5")

            // 3 simple curves (reduced from 6)
            let curves: [(CGPoint, CGPoint, CGPoint, CGPoint, Double)] = [
                (CGPoint(x: w * 0.15, y: h), CGPoint(x: w * 0.35, y: 0), CGPoint(x: w * 0.1, y: h * 0.6), CGPoint(x: w * 0.4, y: h * 0.3), 0.12),
                (CGPoint(x: w * 0.5, y: h), CGPoint(x: w * 0.6, y: 0), CGPoint(x: w * 0.6, y: h * 0.7), CGPoint(x: w * 0.45, y: h * 0.25), 0.09),
                (CGPoint(x: w * 0.8, y: h), CGPoint(x: w * 0.2, y: 0), CGPoint(x: w * 0.9, y: h * 0.5), CGPoint(x: w * 0.3, y: h * 0.3), 0.07),
            ]

            for (start, end, cp1, cp2, speed) in curves {
                var path = Path()
                path.move(to: start)
                path.addCurve(to: end, control1: cp1, control2: cp2)
                context.stroke(path, with: .color(lineColor), lineWidth: 0.6)

                // Static endpoint dots
                let endDot = Path(ellipseIn: CGRect(x: end.x - 3, y: end.y - 3, width: 6, height: 6))
                context.fill(endDot, with: .color(dotColor.opacity(0.2)))

                // Moving dot
                let t = (phase * speed).truncatingRemainder(dividingBy: 1.0)
                let pos = bezier(t: t, p0: start, p1: cp1, p2: cp2, p3: end)
                let dot = Path(ellipseIn: CGRect(x: pos.x - 3, y: pos.y - 3, width: 6, height: 6))
                context.fill(dot, with: .color(dotColor.opacity(0.3)))
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                phase = 1.0
            }
        }
    }

    private func bezier(t: Double, p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint) -> CGPoint {
        let mt = 1.0 - t
        let mt2 = mt * mt
        let mt3 = mt2 * mt
        let t2 = t * t
        let t3 = t2 * t
        return CGPoint(
            x: mt3 * p0.x + 3 * mt2 * t * p1.x + 3 * mt * t2 * p2.x + t3 * p3.x,
            y: mt3 * p0.y + 3 * mt2 * t * p1.y + 3 * mt * t2 * p2.y + t3 * p3.y
        )
    }
}
