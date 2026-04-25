import Foundation
import SwiftUI

class SettingsManager: ObservableObject {
    @AppStorage("dailyTarget") var dailyTarget: Double = 8.0
    @AppStorage("weeklyTarget") var weeklyTarget: Double = 40.0
    @AppStorage("yearlyTarget") var yearlyTarget: Double = 1642.0
    
    @AppStorage("selectedCalendars") private var selectedCalendarsData: Data = Data()
    
    var selectedCalendars: Set<String> {
        get {
            guard let decoded = try? JSONDecoder().decode(Set<String>.self, from: selectedCalendarsData) else {
                return []
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                selectedCalendarsData = encoded
            }
        }
    }
    
    func toggleCalendar(identifier: String) {
        var current = selectedCalendars
        if current.contains(identifier) {
            current.remove(identifier)
        } else {
            current.insert(identifier)
        }
        selectedCalendars = current
    }
}
