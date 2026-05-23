import Foundation
import SwiftUI

@Observable
class NeuroRhythmViewModel {
    var todayTasks: [NeuroTask] = []
    var alertNodes: [AlertNode] = []
    var calendarEvents: [CalendarEvent] = []
    var currentState: NeuroState?
    var profile = NeuroProfile()
    let healthKitManager = HealthKitManager()
    let eventKitManager = EventKitManager()
    let nfiCalc = NFICalculator()
    let emotionEngine = EmotionEngine()
    let scheduler = BrainRegionScheduler()
    let ultradian = UltradianEngine()
    let alertEngine = AlertEngine()
    var selectedTab = 0
    var showBreathingSheet = false
    var showArchiveSheet = false
    var showBrakeOverlay = false
    var toastMessage: String?

    // Calendar sync confirmation
    var showCalendarSyncAlert = false
    var pendingCalendarTask: NeuroTask?
    var pendingCalendarInterval: DateInterval?

    // Auth
    var isAuthenticated = false
    var appleUserID: String?
    var userName: String?

    init() {
        isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        appleUserID = UserDefaults.standard.string(forKey: "appleUserID")
        userName = UserDefaults.standard.string(forKey: "userName")
        if isAuthenticated {
            loadDemoTasks()
            Task { await initialize() }
        }
    }

    func requestAllPermissions() async {
        await healthKitManager.requestAuthorization()
        await eventKitManager.requestAccess()
        await refreshState()
        generateSystemTasks()
    }

    func initialize() async {
        await refreshState()
        generateSystemTasks()
    }

    @MainActor
    func refreshState() async {
        let hrv = await healthKitManager.fetchLatestHRV()
        let sleep = await healthKitManager.fetchLastNightSleep()

        let hour = Calendar.current.component(.hour, from: Date())

        // Simulated HRV/HR/sleep when no real data (e.g. Simulator)
        let simRmssd: Double? = hrv.rmssd ?? (hour < 12 ? 45 : (hour < 17 ? 32 : 25))
        let simHR: Double? = hrv.restingHR ?? (hour < 12 ? 65 : (hour < 17 ? 72 : 78))
        let simSpo2: Double? = hrv.spo2 ?? 97
        let simHF: Double? = hrv.hf ?? simRmssd.map { $0 * 0.7 }
        let simDeep: Double? = sleep.deep ?? 1.8
        let simRem: Double? = sleep.rem ?? 1.2

        let (nfiType, nfiScore) = nfiCalc.calculate(hrvHF: simHF, restingHR: simHR, spo2: simSpo2, activityEnergy: nil, subjectiveType: nil)

        // Compute emotion based on time when no real sensor data
        let emotionQuadrant: EmotionQuadrant
        let valence: Double
        let arousal: Double
        if hrv.rmssd != nil {
            let result = emotionEngine.defaultState()
            valence = result.valence
            arousal = result.arousal
            emotionQuadrant = result.quadrant
        } else {
            if hour < 12 { emotionQuadrant = .lowArousalPositive }
            else if hour < 15 { emotionQuadrant = .lowArousalNegative }
            else if hour < 20 { emotionQuadrant = .highArousalPositive }
            else { emotionQuadrant = .highArousalNegative }
            valence = emotionQuadrant == .lowArousalPositive || emotionQuadrant == .highArousalPositive ? 0.3 : -0.3
            arousal = emotionQuadrant == .highArousalPositive || emotionQuadrant == .highArousalNegative ? 0.7 : 0.3
        }

        var state = NeuroState(timestamp: Date(), nfi: nfiType, nfiScore: nfiScore, emotion: emotionQuadrant, valence: valence, arousal: arousal, hrvRMSSD: simRmssd, hrvHF: simHF, restingHR: simHR, spo2: simSpo2, deepSleepHours: simDeep, remSleepHours: simRem)
        let caps = scheduler.calculateCapacities(state: state, profile: profile)
        state.fpnCapacity = caps[.fpn] ?? 0
        state.dmnCapacity = caps[.dmn] ?? 0
        state.memoryCapacity = caps[.memory] ?? 0
        state.danCapacity = caps[.dan] ?? 0
        self.currentState = state
        evaluateTasks()
        self.alertNodes = alertEngine.generateAlerts(for: state, tasks: todayTasks, profile: profile)
        if alertNodes.contains(where: { $0.level == .brake && !$0.triggered }) { showBrakeOverlay = true }
    }

    func evaluateTasks() {
        guard let state = currentState else { return }
        for i in todayTasks.indices {
            let result = scheduler.matchTask(todayTasks[i], to: state, profile: profile)
            todayTasks[i].feasibilityScore = result.feasibility
            todayTasks[i].predictedQuality = result.quality
            todayTasks[i].riskNote = result.risk
        }
        todayTasks.sort { ($0.feasibilityScore ?? 0) > ($1.feasibilityScore ?? 0) }
    }

    func acceptSchedule(for task: NeuroTask, at interval: DateInterval) {
        if let idx = todayTasks.firstIndex(where: { $0.id == task.id }) {
            todayTasks[idx].scheduledTime = interval
            // Store pending and show confirmation
            pendingCalendarTask = todayTasks[idx]
            pendingCalendarInterval = interval
            showCalendarSyncAlert = true
        }
    }

    func confirmCalendarSync() {
        guard let task = pendingCalendarTask, let interval = pendingCalendarInterval else { return }
        Task {
            await eventKitManager.addEvent(
                title: task.title,
                startDate: interval.start,
                endDate: interval.end,
                notes: "\(task.brainRegion.rawValue) · \(regionTypeDescription(task.brainRegion)) · 认知负荷 \(task.cognitiveLoad)/5 · 预计质量 \(task.predictedQuality ?? "?")"
            )
            await refreshCalendar()
            if eventKitManager.lastError == nil {
                toastMessage = "已同步到苹果日历"
            } else {
                toastMessage = eventKitManager.lastError
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.toastMessage = nil }
            pendingCalendarTask = nil
            pendingCalendarInterval = nil
        }
    }

    func skipCalendarSync() {
        pendingCalendarTask = nil
        pendingCalendarInterval = nil
    }

    private func regionTypeDescription(_ region: BrainRegion) -> String {
        switch region {
        case .fpn: return "逻辑推理与决策任务"
        case .dmn: return "发散创意与联想任务"
        case .memory: return "记忆编码与巩固任务"
        case .dan: return "持续注意与常规操作"
        }
    }

    func editTask(id: UUID, title: String, duration: Int) {
        if let idx = todayTasks.firstIndex(where: { $0.id == id }) {
            todayTasks[idx].title = title
            todayTasks[idx].estimatedDuration = duration
            if let scheduled = todayTasks[idx].scheduledTime {
                todayTasks[idx].scheduledTime = DateInterval(start: scheduled.start, duration: TimeInterval(duration * 60))
            }
            evaluateTasks()
        }
    }

    func deleteTask(id: UUID) {
        todayTasks.removeAll { $0.id == id }
    }

    func triggerIntervention(_ type: String) {
        switch type {
        case "478breath": showBreathingSheet = true
        case "archive":
            let now = Date()
            let unfinished = todayTasks.filter { !$0.isCompleted && !$0.isArchived }
            let toArchive = unfinished.filter { task in
                guard let time = task.scheduledTime else { return true }
                return time.end < now || time.start > now
            }
            for task in toArchive {
                if let idx = todayTasks.firstIndex(where: { $0.id == task.id }) {
                    todayTasks[idx].isArchived = true
                }
            }
            toastMessage = "\(toArchive.count) 个任务已归档至明日"
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.toastMessage = nil }
        case "switchToDAN":
            let now = Date()
            // Find current or next FPN task based on scheduled time
            let fpnTasks = todayTasks.filter { $0.brainRegion == .fpn && !$0.isCompleted && !$0.isArchived }
            let currentFPN = fpnTasks.first { task in
                guard let time = task.scheduledTime else { return false }
                return time.contains(now)
            } ?? fpnTasks.first { task in
                guard let time = task.scheduledTime else { return false }
                return time.start > now
            } ?? fpnTasks.first

            if let target = currentFPN, let idx = todayTasks.firstIndex(where: { $0.id == target.id }) {
                let oldTitle = todayTasks[idx].title
                todayTasks[idx].brainRegion = .dan
                evaluateTasks()
                toastMessage = "「\(oldTitle)」已切换至 #DAN 模式"
            } else {
                toastMessage = "没有待执行的 FPN 任务"
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.toastMessage = nil }
        default: break
        }
    }

    private func loadDemoTasks() {
        todayTasks = [
            NeuroTask(id: UUID(), title: "撰写课题申请书核心论证", brainRegion: .fpn, cognitiveLoad: 5, estimatedDuration: 90),
            NeuroTask(id: UUID(), title: "文献泛读与灵感收集", brainRegion: .dmn, cognitiveLoad: 2, estimatedDuration: 45),
            NeuroTask(id: UUID(), title: "背诵实验方案关键参数", brainRegion: .memory, cognitiveLoad: 3, estimatedDuration: 30),
            NeuroTask(id: UUID(), title: "整理实验数据表格", brainRegion: .dan, cognitiveLoad: 2, estimatedDuration: 40),
            NeuroTask(id: UUID(), title: "审阅合同条款并决策", brainRegion: .fpn, cognitiveLoad: 4, estimatedDuration: 60),
        ]
    }

    func generateSystemTasks() {
        Task {
            calendarEvents = await eventKitManager.fetchTodayEvents(for: Date())

            var suggestions: [NeuroTask] = []
            for event in calendarEvents where !event.isNeuroEvent {
                let duration = Int(event.endDate.timeIntervalSince(event.startDate) / 60)
                if duration > 10 {
                    suggestions.append(NeuroTask(
                        id: UUID(),
                        title: event.title,
                        brainRegion: duration > 60 ? .fpn : .dan,
                        cognitiveLoad: duration > 60 ? 4 : 2,
                        estimatedDuration: min(duration, 120),
                        optimalWindow: DateInterval(start: event.startDate, end: event.endDate),
                        scheduledTime: DateInterval(start: event.startDate, end: event.endDate),
                        isSystemGenerated: true
                    ))
                }
            }

            if suggestions.isEmpty && todayTasks.isEmpty {
                loadDemoTasks()
            } else if !suggestions.isEmpty {
                let existingTitles = Set(todayTasks.map { $0.title })
                let newSuggestions = suggestions.filter { !existingTitles.contains($0.title) }
                todayTasks = todayTasks + newSuggestions
            }
            evaluateTasks()
        }
    }

    func refreshCalendar() async {
        calendarEvents = await eventKitManager.fetchTodayEvents(for: Date())
    }

    func completeLogin() {
        UserDefaults.standard.set(true, forKey: "isAuthenticated")
        UserDefaults.standard.set(appleUserID, forKey: "appleUserID")
        UserDefaults.standard.set(userName, forKey: "userName")
        isAuthenticated = true
        loadDemoTasks()
    }

    func signOut() {
        UserDefaults.standard.removeObject(forKey: "isAuthenticated")
        UserDefaults.standard.removeObject(forKey: "appleUserID")
        UserDefaults.standard.removeObject(forKey: "userName")
        isAuthenticated = false
        todayTasks = []
        alertNodes = []
        currentState = nil
    }
}
