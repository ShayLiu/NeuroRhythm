import SwiftUI

struct SynapseCapsule: View {
    let value: String
    let label: String
    var color: Color = NeuroDesign.accentSage

    @State private var breatheOpacity: Double = 0.02

    var body: some View {
        VStack(spacing: NeuroDesign.xs) {
            Text(value)
                .font(.system(size: 32, weight: .light, design: .rounded))
                .foregroundColor(color.opacity(0.85))
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(NeuroDesign.textSecondary)
        }
        .padding(.horizontal, NeuroDesign.md)
        .padding(.vertical, NeuroDesign.sm + 4)
        .background(
            ZStack {
                Capsule()
                    .fill(color.opacity(breatheOpacity))

                Capsule()
                    .fill(.white.opacity(0.35))
                    .background(.ultraThinMaterial, in: Capsule())
            }
        )
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.4), lineWidth: 0.5)
        )
        .shadow(color: color.opacity(0.04), radius: 24, y: 4)
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                breatheOpacity = 0.06
            }
        }
    }
}
