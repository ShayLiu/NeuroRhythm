import SwiftUI

struct BreathingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var phase: BreathPhase = .inhale
    @State private var currentRound = 1
    @State private var scale: CGFloat = 0.5
    @State private var timer: Timer?
    @State private var isActive = false
    @State private var phaseTimeRemaining: Int = 4

    private let totalRounds = 4
    private let mintColor = Color(hex: "7DBCB5")

    enum BreathPhase: String {
        case inhale = "吸气"
        case hold = "屏息"
        case exhale = "呼气"
        case rest = "休息"

        var duration: Int {
            switch self {
            case .inhale: return 4
            case .hold: return 7
            case .exhale: return 8
            case .rest: return 2
            }
        }

        var color: Color {
            switch self {
            case .inhale: return Color(hex: "7DBCB5")
            case .hold: return Color(hex: "94B8D6")
            case .exhale: return Color(hex: "B8A9D0")
            case .rest: return Color(hex: "D1D9E0")
            }
        }
    }

    var body: some View {
        VStack(spacing: NeuroDesign.xl) {
            HStack {
                Spacer()
                Button(action: { stopAndDismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(NeuroDesign.textTertiary)
                }
            }
            .padding(.horizontal, NeuroDesign.md)

            Spacer()

            Text("4-7-8 呼吸法")
                .font(.system(size: 24, weight: .light, design: .rounded))
                .foregroundColor(NeuroDesign.textPrimary)

            Text("第 \(currentRound)/\(totalRounds) 轮")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(NeuroDesign.textSecondary)

            ZStack {
                // Water ripple ring 1 (outermost, faintest)
                Circle()
                    .stroke(mintColor.opacity(0.07), lineWidth: 1.2)
                    .frame(width: 240, height: 240)
                    .scaleEffect(scale)

                // Water ripple ring 2
                Circle()
                    .stroke(mintColor.opacity(0.12), lineWidth: 1.2)
                    .frame(width: 180, height: 180)
                    .scaleEffect(scale)

                // Water ripple ring 3 (innermost, most visible)
                Circle()
                    .stroke(mintColor.opacity(0.18), lineWidth: 1.2)
                    .frame(width: 120, height: 120)
                    .scaleEffect(scale)

                // Central radial gradient circle
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [mintColor.opacity(0.2), mintColor.opacity(0.0)]),
                            center: .center,
                            startRadius: 5,
                            endRadius: 45
                        )
                    )
                    .frame(width: 90, height: 90)
                    .scaleEffect(scale * 0.95)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.45), lineWidth: 1)
                            .frame(width: 90, height: 90)
                            .scaleEffect(scale * 0.95)
                    )

                VStack(spacing: NeuroDesign.sm) {
                    Text(phase.rawValue)
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundColor(phase.color)
                    Text("\(phaseTimeRemaining)")
                        .font(.system(size: 44, weight: .light, design: .rounded))
                        .foregroundColor(NeuroDesign.textPrimary)
                }
            }
            .animation(.easeInOut(duration: 1), value: scale)

            Spacer()

            if !isActive {
                Button(action: { startBreathing() }) {
                    Text("开始")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, NeuroDesign.xxl)
                        .padding(.vertical, NeuroDesign.md)
                        .background(mintColor)
                        .clipShape(Capsule())
                }
            }

            Text("吸气4秒 - 屏息7秒 - 呼气8秒")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(NeuroDesign.textSecondary)
                .padding(.bottom, NeuroDesign.lg)
        }
        .background(NeuroDesign.bg)
        .onDisappear { timer?.invalidate() }
    }

    private func startBreathing() {
        isActive = true
        phase = .inhale
        phaseTimeRemaining = phase.duration
        scale = 1.0
        startTimer()
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            phaseTimeRemaining -= 1
            if phaseTimeRemaining <= 0 {
                advancePhase()
            }
        }
    }

    private func advancePhase() {
        switch phase {
        case .inhale:
            phase = .hold
            scale = 1.0
        case .hold:
            phase = .exhale
            scale = 0.5
        case .exhale:
            if currentRound >= totalRounds {
                completeSession()
                return
            }
            phase = .rest
            scale = 0.5
        case .rest:
            currentRound += 1
            phase = .inhale
            scale = 1.0
        }
        phaseTimeRemaining = phase.duration
    }

    private func completeSession() {
        timer?.invalidate()
        isActive = false
        dismiss()
    }

    private func stopAndDismiss() {
        timer?.invalidate()
        dismiss()
    }
}
