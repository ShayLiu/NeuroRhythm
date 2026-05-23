import SwiftUI

struct TimelineRow: View {
    let alert: AlertNode
    var onIntervention: ((String) -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: NeuroDesign.md) {
            // Timeline node
            VStack(spacing: 0) {
                ActionPotentialNode(level: alert.level, triggered: alert.triggered)
                Rectangle()
                    .fill(NeuroDesign.textTertiary.opacity(0.4))
                    .frame(width: 2, height: 40)
            }

            // Content
            VStack(alignment: .leading, spacing: NeuroDesign.xs) {
                HStack {
                    Text(alert.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(NeuroDesign.textPrimary)
                    Spacer()
                    Text(timeString)
                        .font(.caption2)
                        .foregroundColor(NeuroDesign.textSecondary)
                }

                Text(alert.body)
                    .font(.caption)
                    .foregroundColor(NeuroDesign.textSecondary)
                    .lineLimit(3)

                if let intervention = alert.interventionType {
                    Button(action: { onIntervention?(intervention) }) {
                        Text(interventionLabel(intervention))
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, NeuroDesign.sm)
                            .padding(.vertical, NeuroDesign.xs)
                            .background(alertColor)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.vertical, NeuroDesign.xs)
    }

    private var alertColor: Color {
        switch alert.level {
        case .info: return NeuroDesign.accentMist
        case .suggest: return NeuroDesign.accentSage
        case .warning: return NeuroDesign.accentAmber
        case .brake: return NeuroDesign.accentCoral
        }
    }

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: alert.triggerTime)
    }

    private func interventionLabel(_ type: String) -> String {
        switch type {
        case "478breath": return "开始 4-7-8 呼吸"
        case "archive": return "执行归档"
        case "switchToDAN": return "切换至 #DAN"
        default: return "执行"
        }
    }
}
