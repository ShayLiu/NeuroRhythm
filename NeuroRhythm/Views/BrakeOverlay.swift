import SwiftUI

struct BrakeOverlay: View {
    @Environment(NeuroRhythmViewModel.self) private var viewModel
    @State private var auroraOffset: CGFloat = 0

    private let lavender = Color(hex: "B8A9D0")
    private let mint = Color(hex: "7DBCB5")

    var body: some View {
        ZStack {
            Color(hex: "F5F7FA").opacity(0.88)
                .ignoresSafeArea()

            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [lavender.opacity(0.12), lavender.opacity(0.0)]),
                        center: .center,
                        startRadius: 40,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(y: auroraOffset)

            VStack(spacing: NeuroDesign.lg) {
                Image(systemName: "wave.3.left")
                    .font(.system(size: 52, weight: .thin))
                    .foregroundColor(lavender)

                Text("神经制动")
                    .font(.system(size: 30, weight: .light, design: .rounded))
                    .foregroundColor(NeuroDesign.textPrimary)

                Text("边缘系统过载正在溶解")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(NeuroDesign.textSecondary)

                VStack(spacing: NeuroDesign.md) {
                    Button(action: {
                        viewModel.showBrakeOverlay = false
                        viewModel.showBreathingSheet = true
                    }) {
                        HStack {
                            Image(systemName: "wind")
                            Text("4-7-8 呼吸")
                        }
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(NeuroDesign.textPrimary)
                        .padding(.horizontal, NeuroDesign.xl)
                        .padding(.vertical, NeuroDesign.md)
                        .background(
                            Capsule()
                                .fill(mint.opacity(0.18))
                                .overlay(
                                    Capsule()
                                        .stroke(mint.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }

                    Button(action: {
                        viewModel.showBrakeOverlay = false
                        viewModel.triggerIntervention("switchToDAN")
                    }) {
                        HStack {
                            Image(systemName: "arrow.triangle.branch")
                            Text("切换至 #DAN 任务")
                        }
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(NeuroDesign.textSecondary)
                        .padding(.horizontal, NeuroDesign.lg)
                        .padding(.vertical, NeuroDesign.sm)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.4))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
                                )
                        )
                    }

                    Button(action: { viewModel.showBrakeOverlay = false }) {
                        Text("我知道了")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(NeuroDesign.textTertiary)
                    }
                    .padding(.top, NeuroDesign.sm)
                }
            }
            .padding(NeuroDesign.xl)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                auroraOffset = -30
            }
        }
    }
}
