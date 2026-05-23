import SwiftUI

struct ActionPotentialNode: View {
    let level: AlertLevel
    var triggered: Bool = false

    @State private var ringScale: CGFloat = 1.0
    @State private var ringOpacity: Double = 0.6

    var body: some View {
        ZStack {
            if triggered {
                Circle()
                    .stroke(nodeColor.opacity(ringOpacity), lineWidth: 2)
                    .frame(width: 18, height: 18)
                    .scaleEffect(ringScale)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                            ringScale = 1.5
                            ringOpacity = 0.15
                        }
                    }
            }

            Circle()
                .fill(nodeColor)
                .frame(width: 12, height: 12)
        }
    }

    private var nodeColor: Color {
        switch level {
        case .info: return Color(hex: "7DBCB5")
        case .suggest: return Color(hex: "94B8D6")
        case .warning: return Color(hex: "D4A5A5")
        case .brake: return Color(hex: "D4A5A5")
        }
    }
}
