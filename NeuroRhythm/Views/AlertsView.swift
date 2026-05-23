import SwiftUI

struct AlertsView: View {
    @Environment(NeuroRhythmViewModel.self) private var viewModel
    @State private var expandedNotes: Set<UUID> = []

    private var rhythmCount: Int {
        viewModel.alertNodes.filter { $0.source == .rhythm }.count
    }

    private var stateTriggeredCount: Int {
        viewModel.alertNodes.filter { $0.source == .state && $0.triggered }.count
    }

    private var timeFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: NeuroDesign.md) {
                    headerSection
                    phaseCard
                    timelineBody
                }
                .padding(.horizontal, NeuroDesign.md)
                .padding(.bottom, NeuroDesign.xxl)
            }
            .background(NeuroDesign.bg)

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
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: NeuroDesign.xs) {
            Text("神经时间轴")
                .font(.system(size: 28, weight: .thin, design: .rounded))
                .foregroundColor(NeuroDesign.textPrimary)
                .padding(.top, NeuroDesign.md)

            Text("节律轨 \(rhythmCount) 个节点 \u{00B7} 状态轨 \(stateTriggeredCount) 个已触发")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(NeuroDesign.textSecondary)
        }
    }

    // MARK: - Phase Card

    private var phaseCard: some View {
        HStack(spacing: NeuroDesign.md) {
            VStack(alignment: .leading, spacing: NeuroDesign.xs) {
                Text("当前阶段")
                    .font(NeuroDesign.neuroLabel(size: 11))
                    .foregroundColor(NeuroDesign.textTertiary)
                Text(nfiLabel)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(NeuroDesign.textPrimary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: NeuroDesign.xs) {
                Text("FPN 容量")
                    .font(NeuroDesign.neuroLabel(size: 11))
                    .foregroundColor(NeuroDesign.textTertiary)
                Text("\(Int(viewModel.currentState?.fpnCapacity ?? 0))%")
                    .font(NeuroDesign.neuroData(size: 22))
                    .foregroundColor(NeuroDesign.accentSage)
            }
        }
        .padding(NeuroDesign.md)
        .background(Color.white.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: NeuroDesign.radiusMd, style: .continuous))
        .shadow(color: NeuroDesign.accentSage.opacity(0.04), radius: 24, x: 0, y: 8)
    }

    private var nfiLabel: String {
        guard let state = viewModel.currentState else { return "---" }
        switch state.nfi {
        case .central: return "中枢疲劳"
        case .peripheral: return "外周疲劳"
        case .mixed: return "混合疲劳"
        }
    }

    // MARK: - Timeline Body

    private var timelineBody: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            if viewModel.alertNodes.isEmpty {
                emptyState
            } else {
                ForEach(Array(viewModel.alertNodes.enumerated()), id: \.element.id) { index, node in
                    timelineRow(node: node, isLast: index == viewModel.alertNodes.count - 1)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: NeuroDesign.md) {
            Image(systemName: "waveform.path.ecg")
                .font(.largeTitle)
                .foregroundColor(NeuroDesign.textTertiary)
            Text("暂无节点")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(NeuroDesign.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, NeuroDesign.xxl)
    }

    // MARK: - Timeline Row

    private func timelineRow(node: AlertNode, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // LEFT: vertical line + dot
            timelineDot(node: node, isLast: isLast)
            // RIGHT: glass card
            nodeCard(node: node)
        }
    }

    private func timelineDot(node: AlertNode, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            ZStack {
                if node.isRealTime {
                    // Pulsing coral ring for real-time state nodes
                    Circle()
                        .stroke(NeuroDesign.accentCoral.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 18, height: 18)
                        .modifier(PulsingModifier())
                    Circle()
                        .fill(NeuroDesign.accentCoral)
                        .frame(width: 8, height: 8)
                } else if node.triggered {
                    // Solid mint dot for triggered
                    Circle()
                        .fill(NeuroDesign.accentSage)
                        .frame(width: 8, height: 8)
                } else {
                    // Empty circle for pending rhythm
                    Circle()
                        .stroke(NeuroDesign.textTertiary, lineWidth: 2)
                        .frame(width: 8, height: 8)
                }
            }
            .frame(width: 20, height: 20)

            if !isLast {
                Rectangle()
                    .fill(NeuroDesign.accentSage.opacity(0.2))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: 20)
    }

    private func nodeCard(node: AlertNode) -> some View {
        let isExpanded = expandedNotes.contains(node.id)
        let tintColor = node.source == .rhythm ? NeuroDesign.accentSage : NeuroDesign.accentCoral

        return VStack(alignment: .leading, spacing: NeuroDesign.sm) {
            // Top row: time + track badge
            HStack {
                Text(timeFormatter.string(from: node.triggerTime))
                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                    .foregroundColor(NeuroDesign.textSecondary)
                Spacer()
                trackBadge(source: node.source)
            }

            // Title
            Text(node.title)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(NeuroDesign.textPrimary)

            // Body
            Text(node.body)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(NeuroDesign.textSecondary)
                .lineSpacing(4)

            // "Why now?" expandable
            if node.scienceNote != nil {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        if isExpanded {
                            expandedNotes.remove(node.id)
                        } else {
                            expandedNotes.insert(node.id)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: isExpanded ? "chevron.up" : "questionmark.circle")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                        Text("为什么现在？")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(tintColor)
                }
                .buttonStyle(.plain)

                if isExpanded, let note = node.scienceNote {
                    Text(note)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(NeuroDesign.textSecondary)
                        .lineSpacing(3)
                        .padding(NeuroDesign.sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(tintColor.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: NeuroDesign.radiusSm, style: .continuous))
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }

            // Intervention button
            if !node.triggered, let intervention = node.interventionType {
                Button {
                    viewModel.triggerIntervention(intervention)
                } label: {
                    HStack(spacing: NeuroDesign.sm) {
                        Image(systemName: interventionIcon(intervention))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                        Text(interventionLabel(intervention))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(tintColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.45))
                    .clipShape(RoundedRectangle(cornerRadius: NeuroDesign.radiusSm, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: NeuroDesign.radiusSm, style: .continuous)
                            .stroke(tintColor.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }

            // Triggered state
            if node.triggered {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 13, weight: .medium))
                    Text("已完成")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                }
                .foregroundColor(NeuroDesign.accentSage)
            }
        }
        .padding(NeuroDesign.md)
        .background(node.triggered ? Color.white.opacity(0.35) : Color.white.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: NeuroDesign.radiusMd, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: NeuroDesign.radiusMd, style: .continuous)
                .stroke(node.isRealTime ? NeuroDesign.accentCoral.opacity(0.6) : Color.clear, lineWidth: 1)
        )
        .shadow(color: NeuroDesign.accentSage.opacity(0.04), radius: 24, x: 0, y: 8)
        .padding(.bottom, NeuroDesign.md)
    }

    // MARK: - Track Badge

    private func trackBadge(source: AlertSource) -> some View {
        let isRhythm = source == .rhythm
        let color = isRhythm ? NeuroDesign.accentSage : NeuroDesign.accentCoral
        let label = isRhythm ? "节律轨" : "状态轨"

        return Text(label)
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }

    // MARK: - Intervention Helpers

    private func interventionIcon(_ type: String) -> String {
        switch type {
        case "478breath": return "wind"
        case "archive": return "tray.and.arrow.down"
        case "switchToDAN": return "arrow.triangle.swap"
        default: return "bolt"
        }
    }

    private func interventionLabel(_ type: String) -> String {
        switch type {
        case "478breath": return "开始 4-7-8 呼吸"
        case "archive": return "执行思绪归档"
        case "switchToDAN": return "切换至 DAN 任务"
        default: return "执行干预"
        }
    }
}

// MARK: - Pulsing Animation Modifier

private struct PulsingModifier: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.6 : 1.0)
            .opacity(isPulsing ? 0 : 0.6)
            .animation(
                .easeInOut(duration: 1.5).repeatForever(autoreverses: false),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}
