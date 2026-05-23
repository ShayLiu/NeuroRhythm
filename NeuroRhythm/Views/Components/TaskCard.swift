import SwiftUI

struct TaskCard: View {
    let task: NeuroTask
    var onAccept: ((DateInterval) -> Void)?
    var onEdit: ((String, Int) -> Void)?
    var onDelete: (() -> Void)?

    @State private var isEditing = false
    @State private var editTitle: String = ""
    @State private var editDuration: Int = 60
    @State private var showTimePicker = false
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)

    private let mintColor = Color(hex: "7DBCB5")
    private let glacierColor = Color(hex: "94B8D6")

    var body: some View {
        VStack(alignment: .leading, spacing: NeuroDesign.sm) {
            HStack {
                if isEditing {
                    TextField("任务名称", text: $editTitle)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(NeuroDesign.textPrimary)
                        .textFieldStyle(.plain)
                } else {
                    Text(task.title)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(NeuroDesign.textPrimary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    RegionTag(region: task.brainRegion)
                    Text(regionDesc(task.brainRegion))
                        .font(.system(size: 10, design: .rounded))
                        .foregroundColor(NeuroDesign.textSecondary)
                }
            }

            HStack(spacing: NeuroDesign.sm) {
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { i in
                        Image(systemName: i <= task.cognitiveLoad ? "star.fill" : "star")
                            .font(.system(size: 10))
                            .foregroundColor(i <= task.cognitiveLoad ? NeuroDesign.accentAmber : NeuroDesign.textTertiary)
                    }
                }

                if isEditing {
                    HStack(spacing: 4) {
                        TextField("", value: $editDuration, format: .number)
                            .keyboardType(.numberPad)
                            .frame(width: 36)
                            .font(.caption2)
                        Text("min")
                            .font(.caption2)
                            .foregroundColor(NeuroDesign.textSecondary)
                    }
                } else {
                    Text("\(task.estimatedDuration)min")
                        .font(.caption2)
                        .foregroundColor(NeuroDesign.textSecondary)
                }

                Spacer()

                if let quality = task.predictedQuality {
                    Text("Q: \(quality)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(qualityColor(quality))
                }
            }

            if let feasibility = task.feasibilityScore {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(NeuroDesign.textTertiary.opacity(0.3))
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    colors: [mintColor.opacity(0.6), glacierColor.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * min(feasibility / 100.0, 1.0), height: 6)
                    }
                }
                .frame(height: 6)
            }

            if let risk = task.riskNote {
                HStack(spacing: NeuroDesign.xs) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundColor(NeuroDesign.accentCoral)
                    Text(risk)
                        .font(.caption2)
                        .foregroundColor(NeuroDesign.accentCoral)
                }
            }

            // Action buttons
            HStack(spacing: NeuroDesign.sm) {
                if isEditing {
                    Button {
                        onEdit?(editTitle, editDuration)
                        isEditing = false
                    } label: {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("保存")
                        }
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, NeuroDesign.md)
                        .padding(.vertical, NeuroDesign.sm)
                        .background(NeuroDesign.accentSage)
                        .clipShape(Capsule())
                    }
                    Button {
                        isEditing = false
                    } label: {
                        Text("取消")
                            .font(.caption)
                            .foregroundColor(NeuroDesign.textSecondary)
                    }
                } else if task.scheduledTime == nil, onAccept != nil {
                    if showTimePicker {
                        VStack(spacing: NeuroDesign.sm) {
                            DatePicker("开始", selection: $startTime, displayedComponents: .hourAndMinute)
                                .font(.caption)
                            DatePicker("结束", selection: $endTime, in: startTime..., displayedComponents: .hourAndMinute)
                                .font(.caption)
                            if endTime <= startTime {
                                Text("结束时间必须晚于开始时间")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(NeuroDesign.accentCoral)
                            }
                            Button {
                                let safeEnd = endTime > startTime ? endTime : startTime.addingTimeInterval(Double(task.estimatedDuration) * 60)
                                let interval = DateInterval(start: startTime, end: safeEnd)
                                onAccept?(interval)
                                showTimePicker = false
                            } label: {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("确认排程")
                                }
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, NeuroDesign.md)
                                .padding(.vertical, NeuroDesign.sm)
                                .background(NeuroDesign.accentSage)
                                .clipShape(Capsule())
                            }
                        }
                    } else {
                        Button(action: { showTimePicker = true }) {
                            HStack {
                                Image(systemName: "calendar.badge.plus")
                                Text("接受排程")
                            }
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, NeuroDesign.md)
                            .padding(.vertical, NeuroDesign.sm)
                            .background(NeuroDesign.accentSage)
                            .clipShape(Capsule())
                        }
                    }

                    Button {
                        editTitle = task.title
                        editDuration = task.estimatedDuration
                        isEditing = true
                    } label: {
                        Image(systemName: "pencil")
                            .font(.caption)
                            .foregroundColor(NeuroDesign.textSecondary)
                            .padding(NeuroDesign.sm)
                            .background(NeuroDesign.textTertiary.opacity(0.2))
                            .clipShape(Circle())
                    }
                } else if task.scheduledTime != nil {
                    HStack {
                        if let time = task.scheduledTime {
                            Image(systemName: "clock.fill")
                                .font(.caption2)
                                .foregroundColor(NeuroDesign.accentSage)
                            Text(timeString(time))
                                .font(.caption)
                                .foregroundColor(NeuroDesign.accentSage)
                        }
                        Spacer()
                        Button {
                            onEdit?(task.title, task.estimatedDuration)
                            editTitle = task.title
                            editDuration = task.estimatedDuration
                            isEditing = true
                        } label: {
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundColor(NeuroDesign.textSecondary)
                        }
                        Button {
                            onDelete?()
                        } label: {
                            Image(systemName: "trash")
                                .font(.caption)
                                .foregroundColor(NeuroDesign.accentCoral)
                        }
                    }
                }
            }
        }
        .padding(NeuroDesign.md)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: NeuroDesign.radiusMd)
                    .fill(.white.opacity(0.6))
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: NeuroDesign.radiusMd))
                RoundedRectangle(cornerRadius: NeuroDesign.radiusMd)
                    .stroke(Color.white.opacity(0.4), lineWidth: 0.5)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: NeuroDesign.radiusMd))
        .shadow(color: mintColor.opacity(0.06), radius: 12, y: 2)
    }

    private func qualityColor(_ q: String) -> Color {
        switch q {
        case "A": return NeuroDesign.accentSage
        case "B": return NeuroDesign.accentMist
        case "C": return NeuroDesign.accentAmber
        default: return NeuroDesign.accentCoral
        }
    }

    private func feasibilityColor(_ f: Double) -> Color {
        if f > 70 { return NeuroDesign.accentSage }
        if f > 40 { return NeuroDesign.accentAmber }
        return NeuroDesign.accentCoral
    }

    private func timeString(_ interval: DateInterval) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return "\(f.string(from: interval.start))–\(f.string(from: interval.end))"
    }

    private func regionDesc(_ r: BrainRegion) -> String {
        switch r {
        case .fpn: return "逻辑决策"
        case .dmn: return "发散创意"
        case .memory: return "记忆巩固"
        case .dan: return "常规操作"
        }
    }
}
