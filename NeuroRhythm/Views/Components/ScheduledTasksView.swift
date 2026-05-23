import SwiftUI

struct ScheduledTasksView: View {
    @Binding var tasks: [NeuroTask]

    var scheduledTasks: [NeuroTask] {
        tasks.filter { $0.scheduledTime != nil }
            .sorted { ($0.scheduledTime?.start ?? .distantFuture) < ($1.scheduledTime?.start ?? .distantFuture) }
    }

    var body: some View {
        if !scheduledTasks.isEmpty {
            VStack(alignment: .leading, spacing: NeuroDesign.sm) {
                Text("已排程")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(NeuroDesign.textPrimary)

                ForEach(scheduledTasks) { task in
                    HStack(spacing: NeuroDesign.sm) {
                        Button(action: { toggleCompletion(task) }) {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20))
                                .foregroundColor(task.isCompleted ? NeuroDesign.accentSage : NeuroDesign.textTertiary)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(task.title)
                                .font(.subheadline)
                                .foregroundColor(task.isCompleted ? NeuroDesign.textSecondary : NeuroDesign.textPrimary)
                                .strikethrough(task.isCompleted)

                            if let interval = task.scheduledTime {
                                Text(intervalString(interval))
                                    .font(.caption2)
                                    .foregroundColor(NeuroDesign.textSecondary)
                            }
                        }

                        Spacer()
                        RegionTag(region: task.brainRegion)
                    }
                    .padding(.vertical, NeuroDesign.xs)
                }
            }
            .padding(NeuroDesign.md)
            .background(NeuroDesign.card)
            .clipShape(RoundedRectangle(cornerRadius: NeuroDesign.radiusMd))
            .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        }
    }

    private func toggleCompletion(_ task: NeuroTask) {
        if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[idx].isCompleted.toggle()
        }
    }

    private func intervalString(_ interval: DateInterval) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: interval.start)) - \(formatter.string(from: interval.end))"
    }
}
