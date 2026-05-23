import SwiftUI

struct NeuroBudgetView: View {
    let fpnUsed: Double
    let fpnTotal: Double
    let limbicResilience: Double
    let memoryWindows: Int

    var body: some View {
        VStack(alignment: .leading, spacing: NeuroDesign.md) {
            Text("神经预算")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(NeuroDesign.textPrimary)

            HStack(spacing: NeuroDesign.xl) {
                budgetCircle(
                    value: fpnUsed / fpnTotal,
                    label: "FPN预算",
                    detail: "\(Int(fpnUsed))/\(Int(fpnTotal))min",
                    color: NeuroDesign.fpnText
                )
                budgetCircle(
                    value: limbicResilience / 100.0,
                    label: "边缘韧性",
                    detail: "\(Int(limbicResilience))%",
                    color: NeuroDesign.accentAmber
                )
                budgetCircle(
                    value: Double(memoryWindows) / 4.0,
                    label: "记忆窗口",
                    detail: "\(memoryWindows)/4",
                    color: NeuroDesign.memoryText
                )
            }
            .frame(maxWidth: .infinity)
        }
        .padding(NeuroDesign.md)
        .background(NeuroDesign.card)
        .clipShape(RoundedRectangle(cornerRadius: NeuroDesign.radiusMd))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    @ViewBuilder
    private func budgetCircle(value: Double, label: String, detail: String, color: Color) -> some View {
        VStack(spacing: NeuroDesign.sm) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 6)
                    .frame(width: 50, height: 50)
                Circle()
                    .trim(from: 0, to: min(value, 1.0))
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
            }
            Text(label)
                .font(.caption2)
                .foregroundColor(NeuroDesign.textSecondary)
            Text(detail)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(NeuroDesign.textPrimary)
        }
    }
}
