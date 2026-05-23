import Foundation

class BrainRegionScheduler {
    func calculateCapacities(state: NeuroState, profile: NeuroProfile) -> [BrainRegion: Double] {
        var caps: [BrainRegion: Double] = [:]
        var fpn = 100.0 - state.nfiScore
        if state.nfi == .central { fpn *= 0.3 }
        if state.emotion == .highArousalNegative { fpn *= 0.2 }
        caps[.fpn] = max(fpn, 0)
        let hour = Calendar.current.component(.hour, from: state.timestamp)
        var dmn = 60.0
        if (14...17).contains(hour) { dmn += 20 }
        if state.emotion == .highArousalPositive { dmn += 15 }
        caps[.dmn] = min(dmn, 100)
        var mem = 70.0
        if state.deepSleepHours ?? 0 > 1.5 { mem += 15 }
        caps[.memory] = min(mem, 100)
        var dan = 85.0
        if state.nfi == .mixed { dan = 60.0 }
        caps[.dan] = dan
        return caps
    }

    func matchTask(_ task: NeuroTask, to state: NeuroState, profile: NeuroProfile) -> (feasibility: Double, quality: String, risk: String?) {
        let caps = calculateCapacities(state: state, profile: profile)
        let cap = caps[task.brainRegion] ?? 0
        let feasibility = cap * (1.0 - Double(task.cognitiveLoad) * 0.15)
        let quality: String
        if feasibility > 80 { quality = "A" }
        else if feasibility > 60 { quality = "B" }
        else if feasibility > 40 { quality = "C" }
        else { quality = "D" }
        var risk: String? = nil
        if state.emotion == .highArousalNegative && task.brainRegion == .fpn {
            risk = "边缘系统激活，决策失败率 >80%"
        }
        if state.nfi == .central && task.cognitiveLoad >= 4 {
            risk = "前额叶葡萄糖耗竭，强行执行将严重透支"
        }
        return (feasibility, quality, risk)
    }
}
