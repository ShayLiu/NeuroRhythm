import Foundation

struct NeuroTask: Identifiable, Codable {
    let id: UUID
    var title: String
    var brainRegion: BrainRegion
    var cognitiveLoad: Int
    var estimatedDuration: Int
    var optimalWindow: DateInterval?
    var scheduledTime: DateInterval?
    var feasibilityScore: Double?
    var predictedQuality: String?
    var riskNote: String?
    var isCompleted: Bool = false
    var isArchived: Bool = false
    var isSystemGenerated: Bool = false
}
