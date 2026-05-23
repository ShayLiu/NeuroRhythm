import Foundation

enum NFIType: String, Codable {
    case central
    case peripheral
    case mixed
}

enum EmotionQuadrant: String, Codable {
    case highArousalNegative
    case lowArousalNegative
    case highArousalPositive
    case lowArousalPositive
}

enum BrainRegion: String, Codable, CaseIterable {
    case fpn = "#FPN"
    case dmn = "#DMN"
    case memory = "#Memory"
    case dan = "#DAN"
}

struct NeuroState: Codable {
    var timestamp: Date
    var nfi: NFIType
    var nfiScore: Double
    var emotion: EmotionQuadrant
    var valence: Double
    var arousal: Double
    var fpnCapacity: Double = 0
    var dmnCapacity: Double = 0
    var memoryCapacity: Double = 0
    var danCapacity: Double = 0
    var hrvRMSSD: Double?
    var hrvHF: Double?
    var restingHR: Double?
    var spo2: Double?
    var deepSleepHours: Double?
    var remSleepHours: Double?
}
