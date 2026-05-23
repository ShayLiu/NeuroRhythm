import Foundation

class AlertEngine {
    func generateAlerts(for state: NeuroState, tasks: [NeuroTask], profile: NeuroProfile) -> [AlertNode] {
        var alerts: [AlertNode] = []
        let now = Date()
        let cal = Calendar.current
        if let morningTime = cal.date(bySettingHour: 7, minute: 30, second: 0, of: now) {
            alerts.append(AlertNode(id: UUID(), triggerTime: morningTime, level: .info, title: "晨间神经基线扫描", body: "深睡 \(String(format: "%.1f", state.deepSleepHours ?? 0))h，REM \(String(format: "%.1f", state.remSleepHours ?? 0))h，第一窗口预计 \(profile.peakWindow1Start.hour ?? 9):\(String(format: "%02d", profile.peakWindow1Start.minute ?? 30))", source: .rhythm, scienceNote: "睡眠期间胶质淋巴系统清除代谢废物，深睡时长直接决定次日前额叶葡萄糖储备和 HRV 基线恢复程度。"))
        }
        if let noonTime = cal.date(bySettingHour: 13, minute: 45, second: 0, of: now) {
            alerts.append(AlertNode(id: UUID(), triggerTime: noonTime, level: .suggest, title: "午后低谷预警", body: "认知低谷将至，已为你预留 #DAN 安全任务", interventionType: "switchToDAN", source: .rhythm, scienceNote: "午后 13:00-15:00，皮质醇自然下降，腺苷累积，前额叶葡萄糖供给减少。此时强行执行 FPN 任务效率下降 40-60%。"))
        }
        if state.emotion == .highArousalNegative && state.nfiScore > 60 {
            alerts.append(AlertNode(id: UUID(), triggerTime: now, level: .brake, title: "神经制动", body: "杏仁核劫持风险高，当前禁止 FPN 决策，建议 478 呼吸或切换至 #DAN", interventionType: "478breath", source: .state, scienceNote: "杏仁核过度激活时，前额叶-杏仁核连接被劫持，决策质量降至随机水平。478 呼吸通过激活迷走神经释放乙酰胆碱，4 轮后杏仁核活性下降约 30%。"))
        }
        if let eveningTime = cal.date(bySettingHour: 21, minute: 0, second: 0, of: now) {
            alerts.append(AlertNode(id: UUID(), triggerTime: eveningTime, level: .suggest, title: "晚间临界点", body: "前额叶日预算已耗尽，剩余任务已预写入明日，执行思绪归档", interventionType: "archive", source: .rhythm, scienceNote: "前额叶每日可用葡萄糖有限，约 4 小时高负荷后进入保护性低功耗。未完成任务在睡眠 REM 期会被海马体重编码，次日执行效率反而更高。"))
        }
        return alerts.sorted { $0.triggerTime < $1.triggerTime }
    }
}
