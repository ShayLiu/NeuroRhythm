import Foundation
import EventKit

class EventKitManager {
    let eventStore = EKEventStore()
    var lastError: String?
    private var hasAccess = false

    func requestAccess() async {
        if #available(iOS 17.0, *) {
            hasAccess = (try? await eventStore.requestFullAccessToEvents()) ?? false
        } else {
            hasAccess = (try? await eventStore.requestAccess(to: .event)) ?? false
        }
        print("[EventKit] 日历授权结果: \(hasAccess)")
    }

    func ensureAccess() async -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        print("[EventKit] 当前授权状态: \(status.rawValue)")

        switch status {
        case .authorized, .fullAccess:
            hasAccess = true
            return true
        case .notDetermined:
            await requestAccess()
            return hasAccess
        default:
            hasAccess = false
            return false
        }
    }

    func addEvent(title: String, startDate: Date, endDate: Date, notes: String, calendarName: String = "神经节律") async {
        guard await ensureAccess() else {
            print("[EventKit] ✗ 无日历权限，无法写入")
            lastError = "未授权日历访问，请在设置中开启"
            return
        }

        let calendar = resolveCalendar(named: calendarName)

        // Step 2: Create and save event
        let event = EKEvent(eventStore: eventStore)
        event.calendar = calendar
        event.title = "🧠 " + title
        event.startDate = startDate
        event.endDate = endDate
        event.notes = notes
        event.addAlarm(EKAlarm(relativeOffset: -300))

        do {
            try eventStore.save(event, span: .thisEvent)
            lastError = nil
            print("[EventKit] ✓ 事件已写入「\(calendar.title)」: \(title)")
        } catch let error {
            lastError = error.localizedDescription
            print("[EventKit] ✗ 写入失败: \(error.localizedDescription)")
            // Retry with default calendar
            if let def = eventStore.defaultCalendarForNewEvents, calendar !== def {
                event.calendar = def
                do {
                    try eventStore.save(event, span: .thisEvent)
                    print("[EventKit] ✓ 已fallback写入默认日历「\(def.title)」")
                } catch {
                    print("[EventKit] ✗ 默认日历也失败: \(error.localizedDescription)")
                }
            }
        }
    }

    func removeEvent(title: String, startDate: Date, endDate: Date) {
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let events = eventStore.events(matching: predicate)
        for event in events where event.title.contains(title) {
            try? eventStore.remove(event, span: .thisEvent)
        }
    }

    func fetchBusyIntervals(for date: Date) -> [DateInterval] {
        let start = Calendar.current.startOfDay(for: date)
        let end = start.addingTimeInterval(86400)
        let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: nil)
        let events = eventStore.events(matching: predicate)
        return events.map { DateInterval(start: $0.startDate, end: $0.endDate) }
    }

    func fetchTodayEvents(for date: Date) async -> [CalendarEvent] {
        guard await ensureAccess() else {
            print("[EventKit] ✗ 无日历权限，无法读取")
            return []
        }

        let start = Calendar.current.startOfDay(for: date)
        let end = start.addingTimeInterval(86400)
        let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: nil)
        let events = eventStore.events(matching: predicate)
        return events.map { event in
            CalendarEvent(
                title: event.title ?? "未命名事件",
                startDate: event.startDate,
                endDate: event.endDate,
                calendarName: event.calendar?.title ?? "",
                isNeuroEvent: event.title?.hasPrefix("🧠") ?? false,
                notes: event.notes
            )
        }.sorted { $0.startDate < $1.startDate }
    }

    func listAllCalendars() -> [(title: String, source: String, type: String)] {
        eventStore.calendars(for: .event).map {
            (title: $0.title, source: $0.source?.title ?? "nil", type: "\($0.source?.sourceType.rawValue ?? -1)")
        }
    }

    private func resolveCalendar(named name: String) -> EKCalendar {
        let allCalendars = eventStore.calendars(for: .event)

        // Print all calendars for debugging
        print("[EventKit] 可用日历:")
        for cal in allCalendars {
            print("  - 「\(cal.title)」 source=\(cal.source?.title ?? "nil") type=\(cal.source?.sourceType.rawValue ?? -1)")
        }

        // Exact match
        if let exact = allCalendars.first(where: { $0.title == name }) {
            print("[EventKit] 找到精确匹配日历: 「\(exact.title)」")
            return exact
        }

        // Fuzzy match (contains)
        if let fuzzy = allCalendars.first(where: { $0.title.contains(name) || name.contains($0.title) }) {
            print("[EventKit] 找到模糊匹配日历: 「\(fuzzy.title)」")
            return fuzzy
        }

        // Try to create it
        if let created = createCalendar(named: name) {
            print("[EventKit] 已创建新日历: 「\(name)」")
            return created
        }

        // Last resort: default
        if let def = eventStore.defaultCalendarForNewEvents {
            print("[EventKit] 使用默认日历: 「\(def.title)」")
            return def
        }

        // Absolutely no calendar available — pick any writable one
        if let any = eventStore.calendars(for: .event).first(where: { $0.allowsContentModifications }) {
            print("[EventKit] 使用可写日历: 「\(any.title)」")
            return any
        }

        // Create a bare minimum local calendar
        let fallback = EKCalendar(for: .event, eventStore: eventStore)
        fallback.title = name
        if let src = eventStore.sources.first {
            fallback.source = src
        }
        try? eventStore.saveCalendar(fallback, commit: true)
        print("[EventKit] 创建兜底日历")
        return fallback
    }

    private func createCalendar(named name: String) -> EKCalendar? {
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.title = name

        let sources = eventStore.sources
        // Prefer iCloud
        if let icloud = sources.first(where: { $0.sourceType == .calDAV }) {
            calendar.source = icloud
        } else if let local = sources.first(where: { $0.sourceType == .local }) {
            calendar.source = local
        } else if let sub = sources.first(where: { $0.sourceType == .subscribed }) {
            calendar.source = sub
        } else {
            return nil
        }

        calendar.cgColor = CGColor(red: 0.49, green: 0.74, blue: 0.71, alpha: 1.0)
        do {
            try eventStore.saveCalendar(calendar, commit: true)
            return calendar
        } catch {
            print("[EventKit] 创建日历失败: \(error.localizedDescription)")
            return nil
        }
    }
}

struct CalendarEvent: Identifiable {
    let id = UUID()
    let title: String
    let startDate: Date
    let endDate: Date
    let calendarName: String
    let isNeuroEvent: Bool
    let notes: String?
}
