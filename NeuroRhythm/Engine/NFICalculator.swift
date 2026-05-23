import Foundation

class NFICalculator {
    func calculate(hrvHF: Double?, restingHR: Double?, spo2: Double?, activityEnergy: Double?, subjectiveType: NFIType?) -> (type: NFIType, score: Double) {
        var centralScore: Double = 0
        var peripheralScore: Double = 0
        if let hf = hrvHF, hf < 500 { centralScore += 40 }
        if let sp = spo2, sp < 95 { centralScore += 30 }
        if let hr = restingHR, hr > 80 { centralScore += 30 }
        if let ae = activityEnergy, ae > 800 { peripheralScore += 50 }
        let score = max(centralScore, peripheralScore)
        let type: NFIType
        if centralScore > 60 && peripheralScore > 60 { type = .mixed }
        else if centralScore > peripheralScore { type = .central }
        else { type = .peripheral }
        return (type, min(score, 100))
    }
}
