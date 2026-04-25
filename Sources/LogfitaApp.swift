import SwiftUI

@main
struct LogfitaApp: App {
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var eventManager: EventStoreManager
    
    init() {
        let sm = SettingsManager()
        _settingsManager = StateObject(wrappedValue: sm)
        _eventManager = StateObject(wrappedValue: EventStoreManager(settingsManager: sm))
    }
    
    var body: some Scene {
        MenuBarExtra {
            StatusMenuView()
                .environmentObject(settingsManager)
                .environmentObject(eventManager)
        } label: {
            // Dynamic icon depending on whether target is reached
            let reachedDaily = eventManager.dailyHours >= settingsManager.dailyTarget
            Image(systemName: reachedDaily ? "checkmark.circle.fill" : "timer")
        }
        
        Settings {
            SettingsView()
                .environmentObject(settingsManager)
                .environmentObject(eventManager)
        }
    }
}
