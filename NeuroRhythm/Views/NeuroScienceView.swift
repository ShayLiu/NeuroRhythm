import SwiftUI

struct NeuroScienceView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: NeuroDesign.lg) {
                    scienceSection(
                        title: "NFI 神经疲劳指数",
                        icon: "brain.head.profile",
                        content: """
                        NFI (Neuro-Fatigue Index) 基于三维度评估：
                        - 中枢疲劳 (Central): HRV-HF 降低、血氧下降、静息心率升高，提示前额叶葡萄糖代谢受限
                        - 外周疲劳 (Peripheral): 活动能量消耗过高，肌肉代谢产物积累
                        - 混合疲劳 (Mixed): 两者叠加，认知与体能均受限
                        当 NFI 评分 >60 时，FPN 决策质量显著下降。
                        """
                    )

                    scienceSection(
                        title: "情绪象限模型",
                        icon: "heart.circle",
                        content: """
                        基于 Russell 环形情绪模型 (Circumplex Model)：
                        - 高激活正向: 兴奋、创造力高峰，适合 DMN 发散思维
                        - 低激活正向: 平静、专注，FPN 最佳工作状态
                        - 高激活负向: 焦虑、杏仁核劫持，禁止 FPN 决策
                        - 低激活负向: 倦怠，适合 DAN 常规任务
                        """
                    )

                    scienceSection(
                        title: "四脑区协作",
                        icon: "cpu",
                        content: """
                        - #FPN (前额叶网络): 执行控制、逻辑推理、决策判断。日预算有限，约 4 小时深度工作。
                        - #DMN (默认模式网络): 发散联想、创意灵感、自传记忆。午后激活度高。
                        - #Memory (海马记忆系统): 编码与巩固。依赖深度睡眠，晨间窗口最佳。
                        - #DAN (背侧注意网络): 持续注意、数据整理。韧性最强，疲劳时的安全选择。
                        """
                    )

                    scienceSection(
                        title: "超日节律",
                        icon: "waveform.path.ecg",
                        content: """
                        人体存在约 90 分钟的 BRAC (Basic Rest-Activity Cycle)。
                        每个周期包含：高效区 (60-70min) + 自然低谷 (20-30min)。
                        深睡不足或晨间心率偏高时，周期缩短至 75 分钟。
                        尊重节律，在低谷期切换至低负荷任务或短休。
                        """
                    )

                    scienceSection(
                        title: "4-7-8 呼吸机制",
                        icon: "wind",
                        content: """
                        Andrew Weil 博士提出的迷走神经激活技术：
                        - 吸气 4 秒: 交感神经适度激活
                        - 屏息 7 秒: CO2 轻度升高，触发化学感受器
                        - 呼气 8 秒: 延长呼气相激活迷走神经，副交感系统主导
                        4 个周期后 HRV-HF 显著回升，杏仁核活动降低。
                        """
                    )
                }
                .padding(NeuroDesign.md)
                .padding(.bottom, NeuroDesign.xxl)
            }
            .background(NeuroDesign.bg)
            .navigationTitle("神经科学原理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                        .foregroundColor(NeuroDesign.accentSage)
                }
            }
        }
    }

    @ViewBuilder
    private func scienceSection(title: String, icon: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: NeuroDesign.sm) {
            HStack(spacing: NeuroDesign.sm) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(NeuroDesign.accentSage)
                Text(title)
                    .font(.headline)
                    .foregroundColor(NeuroDesign.textPrimary)
            }
            Text(content)
                .font(.subheadline)
                .foregroundColor(NeuroDesign.textSecondary)
                .lineSpacing(4)
        }
        .padding(NeuroDesign.md)
        .background(NeuroDesign.card)
        .clipShape(RoundedRectangle(cornerRadius: NeuroDesign.radiusMd))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }
}
