import Foundation

enum AlertLevel: String, Codable {
    case info
    case suggest
    case warning
    case brake
}

enum AlertSource: String, Codable {
    case rhythm
    case state
}

struct AlertNode: Identifiable, Codable {
    let id: UUID
    var triggerTime: Date
    var level: AlertLevel
    var title: String
    var body: String
    var triggered: Bool = false
    var acknowledged: Bool = false
    var interventionType: String?
    var relatedTaskID: UUID?
    var source: AlertSource = .rhythm
    var scienceNote: String?

    var isRealTime: Bool { source == .state && !triggered }
}
