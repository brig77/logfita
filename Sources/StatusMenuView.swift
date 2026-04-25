import SwiftUI

struct StatusMenuView: View {
    @EnvironmentObject var eventManager: EventStoreManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Logfita")
                .font(.headline)
                .padding(.bottom, 5)
            
            if !eventManager.isAuthorized {
                Text("Calendar Access Required")
                    .foregroundColor(.red)
            } else {
                VStack(alignment: .leading, spacing: 5) {
                    ProgressRow(title: "Today", current: eventManager.dailyHours, target: settingsManager.dailyTarget)
                    ProgressRow(title: "This Week", current: eventManager.weeklyHours, target: settingsManager.weeklyTarget)
                    ProgressRow(title: "This Year", current: eventManager.yearlyHours, target: settingsManager.yearlyTarget)
                }
            }
            
            Divider()
            
            Button("Settings...") {
                // Open Settings window
                if #available(macOS 13.0, *) {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                } else {
                    NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                }
            }
            .keyboardShortcut(",", modifiers: .command)
            
            Button("Refresh") {
                eventManager.refreshData()
            }
            .keyboardShortcut("r", modifiers: .command)
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
        .padding()
        .onAppear {
            eventManager.checkStatus()
            eventManager.refreshData()
        }
    }
}

struct ProgressRow: View {
    let title: String
    let current: Double
    let target: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(title)
                Spacer()
                Text(String(format: "%.1f / %.1f", current, target))
                    .foregroundColor(current >= target ? .green : .primary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(current >= target ? Color.green : Color.blue)
                        .frame(width: min(CGFloat(current / max(target, 0.1)) * geometry.size.width, geometry.size.width), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
}
