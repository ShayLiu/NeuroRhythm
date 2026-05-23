import Foundation
import HealthKit

class HealthKitManager {
    let healthStore = HKHealthStore()

    var readTypes: Set<HKObjectType> {
        var types: [HKObjectType] = []
        if let t = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) { types.append(t) }
        if let t = HKQuantityType.quantityType(forIdentifier: .heartRate) { types.append(t) }
        if let t = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation) { types.append(t) }
        if let t = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) { types.append(t) }
        if let t = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) { types.append(t) }
        return Set(types)
    }

    var writeTypes: Set<HKSampleType> {
        var types: [HKSampleType] = []
        if let t = HKCategoryType.categoryType(forIdentifier: .mindfulSession) { types.append(t) }
        return Set(types)
    }

    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        try? await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
    }

    func fetchLatestHRV() async -> (rmssd: Double?, hf: Double?, restingHR: Double?, spo2: Double?) {
        async let rmssd = fetchLatestQuantity(.heartRateVariabilitySDNN, unit: HKUnit.secondUnit(with: .milli))
        async let hr = fetchLatestQuantity(.heartRate, unit: HKUnit(from: "count/min"))
        async let spo2 = fetchLatestQuantity(.oxygenSaturation, unit: HKUnit.percent())
        let rmssdVal = await rmssd
        let hrVal = await hr
        let spo2Val = await spo2
        return (rmssdVal, rmssdVal.map { $0 * 0.7 }, hrVal, spo2Val.map { $0 * 100 })
    }

    func fetchLastNightSleep() async -> (deep: Double?, rem: Double?, total: Double?) {
        guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else { return (nil, nil, nil) }
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .hour, value: -24, to: now)!
        let predicate = HKQuery.predicateForSamples(withStart: yesterday, end: now, options: .strictEndDate)
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                guard let samples = samples as? [HKCategorySample] else { continuation.resume(returning: (nil, nil, nil)); return }
                var deep: TimeInterval = 0, rem: TimeInterval = 0, total: TimeInterval = 0
                for sample in samples {
                    let duration = sample.endDate.timeIntervalSince(sample.startDate)
                    total += duration
                    if #available(iOS 16.0, *) {
                        switch HKCategoryValueSleepAnalysis(rawValue: sample.value) {
                        case .asleepDeep: deep += duration
                        case .asleepREM: rem += duration
                        default: break
                        }
                    }
                }
                continuation.resume(returning: (deep / 3600, rem / 3600, total / 3600))
            }
            healthStore.execute(query)
        }
    }

    func saveBreathingSession(minutes: Int) {
        guard let mindfulType = HKCategoryType.categoryType(forIdentifier: .mindfulSession) else { return }
        let start = Date().addingTimeInterval(-Double(minutes) * 60)
        let sample = HKCategorySample(type: mindfulType, value: HKCategoryValue.notApplicable.rawValue, start: start, end: Date())
        healthStore.save(sample) { _, _ in }
    }

    private func fetchLatestQuantity(_ identifier: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double? {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: identifier) else { return nil }
        let now = Date()
        let start = Calendar.current.date(byAdding: .hour, value: -24, to: now)!
        let predicate = HKQuery.predicateForSamples(withStart: start, end: now, options: .strictEndDate)
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
                guard let sample = samples?.first as? HKQuantitySample else { continuation.resume(returning: nil); return }
                continuation.resume(returning: sample.quantity.doubleValue(for: unit))
            }
            healthStore.execute(query)
        }
    }
}
