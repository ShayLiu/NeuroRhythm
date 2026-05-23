import SwiftUI

struct NeuroDesign {
    // MARK: - Colors (Muted Clear — Morning Lab Glass)
    static let bg = Color(hex: "F5F7FA")
    static let card = Color.white.opacity(0.55)
    static let textPrimary = Color(hex: "334155")
    static let textSecondary = Color(hex: "8896A4")
    static let textTertiary = Color(hex: "D1D9E0")

    static let accentSage = Color(hex: "7DBCB5")       // grey celadon (primary)
    static let accentAmber = Color(hex: "94B8D6")       // mist blue
    static let accentCoral = Color(hex: "D4A5A5")       // muted rose (warning)
    static let accentMist = Color(hex: "B8A9D0")        // grey lavender (recovery)
    static let accentGABA = Color(hex: "D8D0E6")        // lavender ice
    static let dopamineGlow = Color(hex: "D6C98A")      // muted gold
    static let acetylcholineGlow = Color(hex: "7DBCB5") // celadon glow

    // MARK: - Fonts
    static func neuroData(size: CGFloat) -> Font {
        .system(size: size, weight: .light, design: .rounded)
    }
    static func neuroLabel(size: CGFloat) -> Font {
        .system(size: size, weight: .medium, design: .rounded).smallCaps()
    }

    // MARK: - Brain Region Colors (Muted)
    static let fpnBg = Color(hex: "E2E8F0").opacity(0.5)
    static let fpnText = Color(hex: "5A6B7D")
    static let dmnBg = Color(hex: "D8D0E6").opacity(0.35)
    static let dmnText = Color(hex: "7A6B8E")
    static let memoryBg = Color(hex: "C8E0DC").opacity(0.4)
    static let memoryText = Color(hex: "5A8A82")
    static let danBg = Color(hex: "F0E6D2").opacity(0.35)
    static let danText = Color(hex: "9A8B6E")

    // MARK: - Spacing
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48

    // MARK: - Radii
    static let radiusSm: CGFloat = 8
    static let radiusMd: CGFloat = 16
    static let radiusLg: CGFloat = 24
    static let radiusXl: CGFloat = 28

    // MARK: - Region helpers
    static func regionBackground(_ region: BrainRegion) -> Color {
        switch region {
        case .fpn: return fpnBg
        case .dmn: return dmnBg
        case .memory: return memoryBg
        case .dan: return danBg
        }
    }

    static func regionForeground(_ region: BrainRegion) -> Color {
        switch region {
        case .fpn: return fpnText
        case .dmn: return dmnText
        case .memory: return memoryText
        case .dan: return danText
        }
    }
}
