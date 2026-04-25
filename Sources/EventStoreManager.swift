import Foundation
import EventKit
import Combine

class EventStoreManager: ObservableObject {
    private let store = EKEventStore()
    
    @Published var isAuthorized = false
    @Published var availableCalendars: [EKCalendar] = []
    
    @Published var dailyHours: Double = 0.0
    @Published var weeklyHours: Double = 0.0
    @Published var yearlyHours: Double = 0.0
    
    private var settingsManager: SettingsManager
    private var cancellables = Set<AnyCancellable>()
    
    init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
        
        NotificationCenter.default.publisher(for: .EKEventStoreChanged, object: store)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.refreshData()
            }
            .store(in: &cancellables)
            
        // Observe settings changes
        settingsManager.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.refreshData()
                }
            }
            .store(in: &cancellables)
    }
    
    func requestAccess() {
        if #available(macOS 14.0, *) {
            store.requestFullAccessToEvents { [weak self] granted, error in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted {
                        self?.loadCalendars()
                        self?.refreshData()
                    }
                }
            }
        } else {
            store.requestAccess(to: .event) { [weak self] granted, error in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted {
                        self?.loadCalendars()
                        self?.refreshData()
                    }
                }
            }
        }
    }
    
    func checkStatus() {
        let status = EKEventStore.authorizationStatus(for: .event)
        isAuthorized = (status == .authorized || status == .fullAccess)
        if isAuthorized {
            loadCalendars()
            refreshData()
        }
    }
    
    private func loadCalendars() {
        availableCalendars = store.calendars(for: .event)
    }
    
    func refreshData() {
        guard isAuthorized else { return }
        
        let selectedIDs = settingsManager.selectedCalendars
        guard !selectedIDs.isEmpty else {
            dailyHours = 0
            weeklyHours = 0
            yearlyHours = 0
            return
        }
        
        let calendarsToSearch = availableCalendars.filter { selectedIDs.contains($0.calendarIdentifier) }
        guard !calendarsToSearch.isEmpty else {
            dailyHours = 0
            weeklyHours = 0
            yearlyHours = 0
            return
        }
        
        dailyHours = calculateHours(for: dateIntervalForToday(), in: calendarsToSearch)
        weeklyHours = calculateHours(for: dateIntervalForThisWeek(), in: calendarsToSearch)
        yearlyHours = calculateHours(for: dateIntervalForThisYear(), in: calendarsToSearch)
    }
    
    private func calculateHours(for interval: DateInterval, in calendars: [EKCalendar]) -> Double {
        let predicate = store.predicateForEvents(withStart: interval.start, end: interval.end, calendars: calendars)
        let events = store.events(matching: predicate).filter { !$0.isAllDay }
        
        // We only care about the intersection of the event's duration with the requested interval
        // Also we must merge overlapping intervals to avoid double counting duplicate events
        var intervals: [DateInterval] = []
        for event in events {
            guard let eventStart = event.startDate, let eventEnd = event.endDate else { continue }
            
            // Clip event to the requested interval boundaries
            let actualStart = max(eventStart, interval.start)
            let actualEnd = min(eventEnd, interval.end)
            
            if actualStart < actualEnd {
                intervals.append(DateInterval(start: actualStart, end: actualEnd))
            }
        }
        
        // Merge intervals
        let mergedIntervals = merge(intervals)
        let totalSeconds = mergedIntervals.reduce(0) { $0 + $1.duration }
        
        return totalSeconds / 3600.0
    }
    
    private func merge(_ intervals: [DateInterval]) -> [DateInterval] {
        guard !intervals.isEmpty else { return [] }
        
        let sorted = intervals.sorted { $0.start < $1.start }
        var merged: [DateInterval] = [sorted[0]]
        
        for i in 1..<sorted.count {
            let current = sorted[i]
            let last = merged.last!
            
            if current.start <= last.end {
                // Overlap found, update the end date of the last interval
                let newEnd = max(last.end, current.end)
                merged[merged.count - 1] = DateInterval(start: last.start, end: newEnd)
            } else {
                merged.append(current)
            }
        }
        return merged
    }
    
    // MARK: - Date Intervals
    private func dateIntervalForToday() -> DateInterval {
        let now = Date()
        let start = Calendar.current.startOfDay(for: now)
        var components = DateComponents()
        components.day = 1
        let end = Calendar.current.date(byAdding: components, to: start)!
        return DateInterval(start: start, end: end)
    }
    
    private func dateIntervalForThisWeek() -> DateInterval {
        let now = Date()
        var startOfWeek = Date()
        var interval: TimeInterval = 0
        _ = Calendar.current.dateInterval(of: .weekOfYear, start: &startOfWeek, interval: &interval, for: now)
        return DateInterval(start: startOfWeek, end: startOfWeek.addingTimeInterval(interval))
    }
    
    private func dateIntervalForThisYear() -> DateInterval {
        let now = Date()
        var startOfYear = Date()
        var interval: TimeInterval = 0
        _ = Calendar.current.dateInterval(of: .year, start: &startOfYear, interval: &interval, for: now)
        return DateInterval(start: startOfYear, end: startOfYear.addingTimeInterval(interval))
    }
}
