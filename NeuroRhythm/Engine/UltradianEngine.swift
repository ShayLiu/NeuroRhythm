import Foundation

class UltradianEngine {
    func calculateCycle(profile: NeuroProfile, deepSleep: Double?, morningHR: Double?) -> Double {
        var cycle = profile.ultradianCycleMinutes
        if let ds = deepSleep {
            if ds < 1.0 { cycle -= 15 }
            if ds > 2.0 { cycle += 5 }
        }
        if let hr = morningHR {
            if hr > 75 { cycle -= 10 }
        }
        return max(75, min(120, cycle))
    }
}
