import Foundation
import HealthKit

class EmotionEngine {
    func quadrant(valence: Double, arousal: Double) -> EmotionQuadrant {
        if valence >= 0 && arousal >= 0.5 { return .highArousalPositive }
        if valence >= 0 && arousal < 0.5 { return .lowArousalPositive }
        if valence < 0 && arousal >= 0.5 { return .highArousalNegative }
        return .lowArousalNegative
    }

    func defaultState() -> (valence: Double, arousal: Double, quadrant: EmotionQuadrant) {
        return (0.2, 0.4, .lowArousalPositive)
    }
}
