import SwiftUI

struct StateCapsule: View {
    let value: String
    let label: String
    var color: Color = NeuroDesign.accentSage

    var body: some View {
        VStack(spacing: NeuroDesign.xs) {
            Text(value)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(NeuroDesign.textSecondary)
        }
        .padding(.horizontal, NeuroDesign.md)
        .padding(.vertical, NeuroDesign.sm)
        .background(Color.white.opacity(0.8))
        .clipShape(Capsule())
    }
}
