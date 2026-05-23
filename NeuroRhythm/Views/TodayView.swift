import SwiftUI

struct TodayView: View {
    @Environment(NeuroRhythmViewModel.self) private var viewModel

    @State private var showAddTask = false
    @State private var showNeuroScience = false

    var body: some View {
        @Bindable var vm = viewModel
        ZStack {
            NeuralBackground()
                .opacity(0.6)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: NeuroDesign.lg) {
                    headerSection

                    stateCapsules

                    peakWindowSection

                    ScheduledTasksView(tasks: $vm.todayTasks)

                    taskMatchingSection

                    if let state = viewModel.currentState {
                        let fpnUsedMinutes = viewModel.todayTasks
                            .filter { $0.isCompleted && $0.brainRegion == .fpn }
                            .reduce(0.0) { $0 + Double($1.estimatedDuration) }

                        NeuroBudgetView(
                            fpnUsed: fpnUsedMinutes,
                            fpnTotal: viewModel.profile.dailyFPNBudgetMinutes,
                            limbicResilience: state.emotion == .highArousalNegative ? 30 :
                                              (state.emotion == .lowArousalNegative ? 50 : 75),
                            memoryWindows: state.deepSleepHours ?? 0 > 1.5 ? 3 : (state.deepSleepHours ?? 0 > 0.8 ? 2 : 1)
                        )
                    }

                    Button(action: { showNeuroScience = true }) {
                        HStack {
                            Image(systemName: "brain")
                            Text("了解神经科学原理")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .font(.system(size: 16))
                        .foregroundColor(NeuroDesign.accentSage)
                        .padding(NeuroDesign.md)
                        .background(NeuroDesign.card)
                        .clipShape(RoundedRectangle(cornerRadius: NeuroDesign.radiusMd))
                        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
                    }

                    Spacer().frame(height: NeuroDesign.xl)
                }
                .padding(.horizontal, NeuroDesign.lg)
                .padding(.top, NeuroDesign.sm)
                .padding(.bottom, NeuroDesign.xxl)
            }
        }
        .background(NeuroDesign.bg)
        .sheet(isPresented: $vm.showBreathingSheet) { BreathingView() }
        .sheet(isPresented: $showAddTask) { AddTaskView() }
        .sheet(isPresented: $showNeuroScience) { NeuroScienceView() }
        .overlay {
            if viewModel.showBrakeOverlay { BrakeOverlay() }
        }
        .overlay {
            if let msg = viewModel.toastMessage {
                VStack {
                    Spacer()
                    Text(msg)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(NeuroDesign.accentSage.opacity(0.9))
                        .clipShape(Capsule())
                        .padding(.bottom, 100)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.easeInOut, value: viewModel.toastMessage)
            }
        }
        .alert("同步到苹果日历", isPresented: $vm.showCalendarSyncAlert) {
            Button("同步") { viewModel.confirmCalendarSync() }
            Button("不同步", role: .cancel) { viewModel.skipCalendarSync() }
        } message: {
            if let task = viewModel.pendingCalendarTask, let interval = viewModel.pendingCalendarInterval {
                let f = DateFormatter()
                let _ = f.dateFormat = "HH:mm"
                Text("将「\(task.title)」\n\(f.string(from: interval.start)) - \(f.string(from: interval.end))\n写入苹果日历？")
            } else {
                Text("是否将此任务写入苹果日历？")
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack(alignment: .center, spacing: NeuroDesign.sm) {
            NeuroRhythmLogo(size: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text("NeuroRhythm")
                    .font(.system(size: 20, weight: .thin, design: .rounded))
                    .tracking(1.5)
                    .foregroundColor(NeuroDesign.textPrimary)
                Text(dateString)
                    .font(NeuroDesign.neuroData(size: 12))
                    .foregroundColor(NeuroDesign.textSecondary)
            }
            Spacer()
        }
        .padding(.top, NeuroDesign.lg)
    }

    // MARK: - State Capsules
    private var stateCapsules: some View {
        HStack(spacing: NeuroDesign.md) {
            if let state = viewModel.currentState {
                StateCapsule(
                    value: "\(Int(state.fpnCapacity))%",
                    label: "FPN",
                    color: NeuroDesign.fpnText
                )
                StateCapsule(
                    value: emotionLabel(state.emotion),
                    label: "情绪",
                    color: state.emotion == .highArousalNegative ? NeuroDesign.accentCoral : NeuroDesign.accentSage
                )
                StateCapsule(
                    value: state.nfi.rawValue,
                    label: "NFI",
                    color: NeuroDesign.accentAmber
                )
            }
        }
    }

    // MARK: - Peak Window
    private var peakWindowSection: some View {
        HStack(spacing: NeuroDesign.md) {
            windowCard(
                icon: "sun.max.fill",
                iconColor: NeuroDesign.accentAmber,
                label: "第一窗口",
                hour: viewModel.profile.peakWindow1Start.hour ?? 9,
                minute: viewModel.profile.peakWindow1Start.minute ?? 30,
                tint: NeuroDesign.accentAmber
            )

            windowCard(
                icon: "moon.stars.fill",
                iconColor: NeuroDesign.accentMist,
                label: "第二窗口",
                hour: viewModel.profile.peakWindow2Start.hour ?? 16,
                minute: viewModel.profile.peakWindow2Start.minute ?? 0,
                tint: NeuroDesign.accentMist
            )
        }
    }

    private func windowCard(icon: String, iconColor: Color, label: String, hour: Int, minute: Int, tint: Color) -> some View {
        VStack(spacing: NeuroDesign.sm) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(iconColor)

            Text(label)
                .font(NeuroDesign.neuroLabel(size: 13))
                .foregroundColor(NeuroDesign.textSecondary)

            Text("\(hour):\(String(format: "%02d", minute))")
                .font(NeuroDesign.neuroData(size: 30))
                .foregroundColor(NeuroDesign.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, NeuroDesign.lg)
        .background(
            RoundedRectangle(cornerRadius: NeuroDesign.radiusLg)
                .fill(tint.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: NeuroDesign.radiusLg)
                        .stroke(tint.opacity(0.12), lineWidth: 1)
                )
        )
    }

    // MARK: - Task Matching
    private var taskMatchingSection: some View {
        VStack(alignment: .leading, spacing: NeuroDesign.md) {
            HStack {
                Text("任务匹配")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(NeuroDesign.textPrimary)
                Spacer()
                Button(action: { showAddTask = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(NeuroDesign.accentSage)
                }
            }

            ForEach(viewModel.todayTasks.filter { !$0.isArchived && $0.scheduledTime == nil }) { task in
                HStack(alignment: .center, spacing: NeuroDesign.sm) {
                    AxonConnector(active: true)
                        .frame(height: 80)

                    TaskCard(
                        task: task,
                        onAccept: { interval in
                            viewModel.acceptSchedule(for: task, at: interval)
                        },
                        onEdit: { newTitle, newDuration in
                            viewModel.editTask(id: task.id, title: newTitle, duration: newDuration)
                        },
                        onDelete: {
                            viewModel.deleteTask(id: task.id)
                        }
                    )
                }
            }
        }
    }

    // MARK: - Helpers
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日 EEEE"
        return formatter.string(from: Date())
    }

    private func emotionLabel(_ e: EmotionQuadrant) -> String {
        switch e {
        case .highArousalPositive: return "高激活+"
        case .lowArousalPositive: return "低激活+"
        case .highArousalNegative: return "高激活-"
        case .lowArousalNegative: return "低激活-"
        }
    }
}
