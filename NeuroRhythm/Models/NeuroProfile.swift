import Foundation

struct NeuroProfile: Codable {
    var peakWindow1Start: DateComponents = DateComponents(hour: 9, minute: 30)
    var peakWindow2Start: DateComponents = DateComponents(hour: 16, minute: 0)
    var ultradianCycleMinutes: Double = 90.0
    var isHighVagalResponder: Bool?
    var isEnvironmentSwitcher: Bool?
    var optimalSleepHours: Double = 7.5
    var dailyFPNBudgetMinutes: Double = 240.0
}
