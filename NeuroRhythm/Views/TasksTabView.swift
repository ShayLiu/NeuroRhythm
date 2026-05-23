import SwiftUI

struct TasksTabView: View {
    @Environment(NeuroRhythmViewModel.self) private var viewModel
    @State private var showAddTask = false

    private var scheduledTasks: [NeuroTask] {
        viewModel.todayTasks
            .filter { $0.scheduledTime != nil && !$0.isArchived }
            .sorted { ($0.scheduledTime?.start ?? .distantFuture) < ($1.scheduledTime?.start ?? .distantFuture) }
    }

    private var pendingTasks: [NeuroTask] {
        viewModel.todayTasks.filter { $0.scheduledTime == nil && !$0.isArchived && !$0.isCompleted }
    }

    private var completedTasks: [NeuroTask] {
        viewModel.todayTasks.filter { $0.isCompleted }
    }

    private var archivedTasks: [NeuroTask] {
        viewModel.todayTasks.filter { $0.isArchived }
    }

    var body: some View {
        ZStack {
            NeuroDesign.bg.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: NeuroDesign.lg) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("任务")
                                .font(.system(size: 28, weight: .thin, design: .rounded))
                                .tracking(1)
                                .foregroundColor(NeuroDesign.textPrimary)
                            Text("今日 \(viewModel.todayTasks.filter { !$0.isArchived }.count) 个任务 · \(completedTasks.count) 已完成")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(NeuroDesign.textSecondary)
                        }
                        Spacer()
                        Button { showAddTask = true } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(NeuroDesign.accentSage)
                        }
                    }
                    .padding(.top, NeuroDesign.lg)

                    // Scheduled (timeline)
                    if !scheduledTasks.isEmpty {
                        sectionHeader("已排程", icon: "calendar.badge.clock", count: scheduledTasks.count)

                        ForEach(scheduledTasks) { task in
                            scheduledTaskRow(task)
                        }
                    }

                    // Apple Calendar events
                    if !viewModel.calendarEvents.isEmpty {
                        sectionHeader("今日日历", icon: "calendar", count: viewModel.calendarEvents.count)

                        ForEach(viewModel.calendarEvents) { event in
                            calendarEventRow(event)
                        }
                    }

                    // Pending
                    if !pendingTasks.isEmpty {
                        sectionHeader("待排程", icon: "clock.badge.questionmark", count: pendingTasks.count)

                        ForEach(pendingTasks) { task in
                            pendingTaskRow(task)
                        }
                    }

                    // Completed
                    if !completedTasks.isEmpty {
                        sectionHeader("已完成", icon: "checkmark.circle", count: completedTasks.count)

                        ForEach(completedTasks) { task in
                            completedTaskRow(task)
                        }
                    }

                    // Archived
                    if !archivedTasks.isEmpty {
                        sectionHeader("已归档", icon: "archivebox", count: archivedTasks.count)

                        ForEach(archivedTasks) { task in
                            archivedTaskRow(task)
                        }
                    }

                    Spacer().frame(height: NeuroDesign.xxl)
                }
                .padding(.horizontal, NeuroDesign.lg)
                .padding(.bottom, NeuroDesign.xxl)
            }
        }
        .sheet(isPresented: $showAddTask) { AddTaskView() }
        .task { await viewModel.refreshCalendar() }
    }

    // MARK: - Calendar Event Row
    private func calendarEventRow(_ event: CalendarEvent) -> some View {
        HStack(spacing: NeuroDesign.md) {
            VStack(spacing: 2) {
                Text(timeStr(event.startDate))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(NeuroDesign.textPrimary)
                Text(timeStr(event.endDate))
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(NeuroDesign.textSecondary)
            }
            .frame(width: 44)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(event.title)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(NeuroDesign.textPrimary)
                    Spacer()
                    if event.isNeuroEvent {
                        Text("NeuroRhythm")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(NeuroDesign.accentSage)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(NeuroDesign.accentSage.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
                HStack(spacing: NeuroDesign.sm) {
                    Image(systemName: "calendar")
                        .font(.system(size: 10))
                        .foregroundColor(NeuroDesign.textTertiary)
                    Text(event.calendarName)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(NeuroDesign.textSecondary)
                    if let notes = event.notes, !notes.isEmpty {
                        Text("·")
                            .foregroundColor(NeuroDesign.textTertiary)
                        Text(notes.prefix(30) + (notes.count > 30 ? "..." : ""))
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(NeuroDesign.textTertiary)
                    }
                }
            }
        }
        .padding(NeuroDesign.md)
        .background(event.isNeuroEvent ? NeuroDesign.accentSage.opacity(0.04) : NeuroDesign.card)
        .clipShape(RoundedRectangle(cornerRadius: NeuroDesign.radiusMd))
        .shadow(color: .black.opacity(0.03), radius: 8, y: 2)
    }

    // MARK: - Section Header
    private func sectionHeader(_ title: String, icon: String, count: Int) -> some View {
        HStack(spacing: NeuroDesign.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(NeuroDesign.accentSage)
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(NeuroDesign.textPrimary)
            Text("\(count)")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(NeuroDesign.textSecondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(NeuroDesign.textTertiary.opacity(0.3))
                .clipShape(Capsule())
            Spacer()
        }
        .padding(.top, NeuroDesign.sm)
    }

    // MARK: - Scheduled Task Row
    private func scheduledTaskRow(_ task: NeuroTask) -> some View {
        HStack(spacing: NeuroDesign.md) {
            // Time column
            if let time = task.scheduledTime {
                VStack(spacing: 2) {
                    Text(timeStr(time.start))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(NeuroDesign.textPrimary)
                    Text(timeStr(time.end))
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(NeuroDesign.textSecondary)
                }
                .frame(width: 44)
            }

            // Task info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(task.title)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(task.isCompleted ? NeuroDesign.textSecondary : NeuroDesign.textPrimary)
                        .strikethrough(task.isCompleted)
                    Spacer()
                    RegionTag(region: task.brainRegion)
                }
                Text(regionTypeDescription(task.brainRegion))
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(NeuroDesign.textSecondary)
            }

            // Complete button
            Button {
                if let idx = viewModel.todayTasks.firstIndex(where: { $0.id == task.id }) {
                    viewModel.todayTasks[idx].isCompleted.toggle()
                }
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(task.isCompleted ? NeuroDesign.accentSage : NeuroDesign.textTertiary)
            }
        }
        .padding(NeuroDesign.md)
        .background(NeuroDesign.card)
        .clipShape(RoundedRectangle(cornerRadius: NeuroDesign.radiusMd))
        .shadow(color: NeuroDesign.accentSage.opacity(0.04), radius: 8, y: 2)
    }

    // MARK: - Pending Task Row
    private func pendingTaskRow(_ task: NeuroTask) -> some View {
        HStack(spacing: NeuroDesign.md) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(task.title)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(NeuroDesign.textPrimary)
                    Spacer()
                    RegionTag(region: task.brainRegion)
                }
                HStack(spacing: NeuroDesign.sm) {
                    Text(regionTypeDescription(task.brainRegion))
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(NeuroDesign.textSecondary)
                    Text("·")
                        .foregroundColor(NeuroDesign.textTertiary)
                    Text("\(task.estimatedDuration)min")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(NeuroDesign.textSecondary)
                }
            }

            Button {
                viewModel.deleteTask(id: task.id)
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(NeuroDesign.accentCoral.opacity(0.7))
            }
        }
        .padding(NeuroDesign.md)
        .background(NeuroDesign.card)
        .clipShape(RoundedRectangle(cornerRadius: NeuroDesign.radiusMd))
        .shadow(color: .black.opacity(0.03), radius: 8, y: 2)
    }

    // MARK: - Completed/Archived
    private func completedTaskRow(_ task: NeuroTask) -> some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(NeuroDesign.accentSage)
            Text(task.title)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(NeuroDesign.textSecondary)
                .strikethrough()
            Spacer()
            if let time = task.scheduledTime {
                Text(timeStr(time.start))
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(NeuroDesign.textTertiary)
            }
        }
        .padding(NeuroDesign.sm + 4)
        .background(NeuroDesign.card.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: NeuroDesign.radiusSm))
    }

    private func archivedTaskRow(_ task: NeuroTask) -> some View {
        HStack {
            Image(systemName: "archivebox")
                .foregroundColor(NeuroDesign.accentMist)
            Text(task.title)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(NeuroDesign.textTertiary)
            Spacer()
            RegionTag(region: task.brainRegion)
        }
        .padding(NeuroDesign.sm + 4)
        .background(NeuroDesign.card.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: NeuroDesign.radiusSm))
    }

    // MARK: - Helpers
    private func timeStr(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }

    private func regionTypeDescription(_ region: BrainRegion) -> String {
        switch region {
        case .fpn: return "逻辑推理与决策"
        case .dmn: return "发散创意与联想"
        case .memory: return "记忆编码与巩固"
        case .dan: return "持续注意与操作"
        }
    }
}
