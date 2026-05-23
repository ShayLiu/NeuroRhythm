import SwiftUI

struct AddTaskView: View {
    @Environment(NeuroRhythmViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var selectedRegion: BrainRegion = .fpn
    @State private var cognitiveLoad = 3
    @State private var duration = 60
    @State private var setTime = false
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)

    private let durationOptions = [30, 45, 60, 90, 120]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: NeuroDesign.lg) {
                    // Title
                    VStack(alignment: .leading, spacing: NeuroDesign.sm) {
                        Text("任务名称")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(NeuroDesign.textPrimary)
                        TextField("输入任务名称", text: $title)
                            .textFieldStyle(.plain)
                            .foregroundColor(NeuroDesign.textPrimary)
                            .padding(NeuroDesign.md)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: NeuroDesign.radiusSm))
                            .overlay(
                                RoundedRectangle(cornerRadius: NeuroDesign.radiusSm)
                                    .stroke(NeuroDesign.textTertiary.opacity(0.5), lineWidth: 1)
                            )
                    }

                    // Brain region
                    VStack(alignment: .leading, spacing: NeuroDesign.sm) {
                        Text("脑区分配")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(NeuroDesign.textPrimary)

                        ForEach(BrainRegion.allCases, id: \.self) { region in
                            Button(action: { selectedRegion = region }) {
                                HStack {
                                    RegionTag(region: region)
                                    Text(regionDescription(region))
                                        .font(.caption)
                                        .foregroundColor(NeuroDesign.textSecondary)
                                    Spacer()
                                    if selectedRegion == region {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(NeuroDesign.accentSage)
                                    }
                                }
                                .padding(NeuroDesign.sm)
                                .background(selectedRegion == region ? NeuroDesign.regionBackground(region).opacity(0.3) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: NeuroDesign.radiusSm))
                            }
                        }
                    }

                    // Cognitive load
                    VStack(alignment: .leading, spacing: NeuroDesign.sm) {
                        Text("认知负荷")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(NeuroDesign.textPrimary)

                        HStack(spacing: NeuroDesign.sm) {
                            ForEach(1...5, id: \.self) { i in
                                Button(action: { cognitiveLoad = i }) {
                                    Image(systemName: i <= cognitiveLoad ? "star.fill" : "star")
                                        .font(.title2)
                                        .foregroundColor(i <= cognitiveLoad ? NeuroDesign.accentAmber : NeuroDesign.textTertiary)
                                }
                            }
                        }
                    }

                    // Duration
                    VStack(alignment: .leading, spacing: NeuroDesign.sm) {
                        Text("预计时长")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(NeuroDesign.textPrimary)

                        HStack(spacing: NeuroDesign.sm) {
                            ForEach(durationOptions, id: \.self) { mins in
                                Button(action: { duration = mins }) {
                                    Text("\(mins)min")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, NeuroDesign.md)
                                        .padding(.vertical, NeuroDesign.sm)
                                        .background(duration == mins ? NeuroDesign.accentSage : Color.white)
                                        .foregroundColor(duration == mins ? .white : NeuroDesign.textPrimary)
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule().stroke(duration == mins ? Color.clear : NeuroDesign.textTertiary.opacity(0.5), lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }

                    // Schedule time
                    VStack(alignment: .leading, spacing: NeuroDesign.sm) {
                        Toggle("设定执行时间", isOn: $setTime)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(NeuroDesign.textPrimary)
                            .tint(NeuroDesign.accentSage)

                        if setTime {
                            DatePicker("开始时间", selection: $startTime, displayedComponents: .hourAndMinute)
                                .font(.subheadline)
                            DatePicker("结束时间", selection: $endTime, in: startTime..., displayedComponents: .hourAndMinute)
                                .font(.subheadline)
                            if endTime <= startTime {
                                Text("结束时间必须晚于开始时间")
                                    .font(.caption)
                                    .foregroundColor(NeuroDesign.accentCoral)
                            }
                        }
                    }
                }
                .padding(NeuroDesign.md)
            }
            .background(NeuroDesign.bg)
            .navigationTitle("新增任务")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                        .foregroundColor(NeuroDesign.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("添加") { addTask() }
                        .fontWeight(.medium)
                        .foregroundColor(title.isEmpty ? NeuroDesign.textTertiary : NeuroDesign.accentSage)
                        .disabled(title.isEmpty)
                }
            }
        }
    }

    private func addTask() {
        var task = NeuroTask(
            id: UUID(),
            title: title,
            brainRegion: selectedRegion,
            cognitiveLoad: cognitiveLoad,
            estimatedDuration: duration
        )
        if setTime {
            let safeEnd = endTime > startTime ? endTime : startTime.addingTimeInterval(Double(duration) * 60)
            let interval = DateInterval(start: startTime, end: safeEnd)
            task.scheduledTime = interval
        }
        viewModel.todayTasks.append(task)
        viewModel.evaluateTasks()
        if setTime {
            let safeEnd = endTime > startTime ? endTime : startTime.addingTimeInterval(Double(duration) * 60)
            let interval = DateInterval(start: startTime, end: safeEnd)
            viewModel.acceptSchedule(for: task, at: interval)
        }
        dismiss()
    }

    private func regionDescription(_ region: BrainRegion) -> String {
        switch region {
        case .fpn: return "逻辑推理、决策、深度分析"
        case .dmn: return "发散联想、创意、灵感收集"
        case .memory: return "记忆编码、背诵、巩固"
        case .dan: return "持续注意、数据整理、常规操作"
        }
    }
}
