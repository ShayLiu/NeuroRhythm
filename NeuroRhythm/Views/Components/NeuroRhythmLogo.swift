import SwiftUI

struct NeuroRhythmLogo: View {
    var size: CGFloat = 200
    var showWordmark: Bool = false
    var variant: LogoVariant = .main

    enum LogoVariant {
        case main
        case monochrome
        case dark
    }

    private var scale: CGFloat { size / 1024.0 }

    var body: some View {
        VStack(spacing: size * 0.06) {
            ZStack {
                breathingRing
                brainWaveLine
                synapseDots
                cellBody
            }
            .frame(width: size, height: size)

            if showWordmark {
                Text("NeuroRhythm")
                    .font(.system(size: size * 0.11, weight: .light, design: .default))
                    .tracking(size * 0.002)
                    .foregroundColor(wordmarkColor)
            }
        }
    }

    // MARK: - Breathing Ring (open arc)
    private var breathingRing: some View {
        Circle()
            .trim(from: 0.05, to: 0.95)
            .stroke(
                ringColor,
                style: StrokeStyle(lineWidth: 46 * scale, lineCap: .round)
            )
            .frame(width: 820 * scale, height: 820 * scale)
            .rotationEffect(.degrees(-45))
    }

    // MARK: - Brain Wave Line
    private var brainWaveLine: some View {
        BrainWaveShape()
            .stroke(
                waveColor,
                style: StrokeStyle(lineWidth: 36 * scale, lineCap: .round, lineJoin: .round)
            )
            .frame(width: 600 * scale, height: 200 * scale)
    }

    // MARK: - Cell Body (soma)
    private var cellBody: some View {
        ZStack {
            // Main body with gradient
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [somaTopColor, somaBottomColor]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 143 * scale
                    )
                )
                .frame(width: 286 * scale, height: 286 * scale)
                .shadow(color: shadowColor, radius: 60 * scale, x: 0, y: 0)

            // Glass highlight
            Circle()
                .fill(Color.white.opacity(highlightOpacity))
                .frame(width: 120 * scale, height: 120 * scale)
                .blur(radius: 15 * scale)
                .offset(x: -40 * scale, y: -40 * scale)
        }
    }

    // MARK: - Synapse Dots
    private var synapseDots: some View {
        let radius: CGFloat = 300 * scale
        let dotSize: CGFloat = 102 * scale
        let angles: [Double] = [-90, 30, 150]

        return ForEach(0..<3, id: \.self) { i in
            Circle()
                .fill(synapseColor)
                .frame(width: dotSize, height: dotSize)
                .shadow(color: synapseColor.opacity(0.3), radius: 20 * scale)
                .offset(
                    x: radius * cos(angles[i] * .pi / 180),
                    y: radius * sin(angles[i] * .pi / 180)
                )
        }
    }

    // MARK: - Colors per variant
    private var ringColor: Color {
        switch variant {
        case .main: return Color(hex: "94B8D6").opacity(0.5)
        case .monochrome: return Color(hex: "334155").opacity(0.4)
        case .dark: return Color(hex: "94B8D6").opacity(0.7)
        }
    }

    private var waveColor: Color {
        switch variant {
        case .main: return Color(hex: "7DBCB5").opacity(0.75)
        case .monochrome: return Color(hex: "334155").opacity(0.8)
        case .dark: return Color(hex: "7DBCB5")
        }
    }

    private var somaTopColor: Color {
        switch variant {
        case .main: return Color(hex: "7DBCB5").opacity(0.9)
        case .monochrome: return Color(hex: "334155")
        case .dark: return Color(hex: "7DBCB5")
        }
    }

    private var somaBottomColor: Color {
        switch variant {
        case .main: return Color(hex: "6BA39D")
        case .monochrome: return Color(hex: "334155").opacity(0.85)
        case .dark: return Color(hex: "6BA39D")
        }
    }

    private var synapseColor: Color {
        switch variant {
        case .main: return Color(hex: "B8A9D0").opacity(0.85)
        case .monochrome: return Color(hex: "334155").opacity(0.6)
        case .dark: return Color(hex: "B8A9D0")
        }
    }

    private var shadowColor: Color {
        switch variant {
        case .main: return Color(hex: "7DBCB5").opacity(0.15)
        case .monochrome: return Color(hex: "334155").opacity(0.1)
        case .dark: return Color(hex: "7DBCB5").opacity(0.25)
        }
    }

    private var highlightOpacity: Double {
        switch variant {
        case .main: return 0.25
        case .monochrome: return 0.15
        case .dark: return 0.4
        }
    }

    private var wordmarkColor: Color {
        switch variant {
        case .main, .monochrome: return Color(hex: "334155")
        case .dark: return Color(hex: "E2E8F0")
        }
    }
}

// MARK: - Brain Wave Shape
struct BrainWaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cycles: Double = 2.5
        let amplitude = rect.height * 0.4
        let midY = rect.midY
        let steps = 100

        for i in 0...steps {
            let x = rect.width * CGFloat(i) / CGFloat(steps)
            let angle = 2 * .pi * cycles * Double(i) / Double(steps)
            let y = midY + amplitude * CGFloat(sin(angle))

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        return path
    }
}
