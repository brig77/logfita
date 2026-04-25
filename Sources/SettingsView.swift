import SwiftUI
import EventKit

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var eventManager: EventStoreManager
    
    var body: some View {
        TabView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Targets Configuration")
                    .font(.headline)
                
                HStack {
                    Text("Daily Hours:")
                    Spacer()
                    TextField("8.0", value: $settingsManager.dailyTarget, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                }
                
                HStack {
                    Text("Weekly Hours:")
                    Spacer()
                    TextField("40.0", value: $settingsManager.weeklyTarget, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                }
                
                HStack {
                    Text("Yearly Hours:")
                    Spacer()
                    TextField("1642.0", value: $settingsManager.yearlyTarget, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                }
                
                Spacer()
            }
            .padding()
            .tabItem {
                Label("General", systemImage: "gearshape")
            }
            
            VStack(alignment: .leading) {
                Text("Select Calendars")
                    .font(.headline)
                    .padding(.bottom, 5)
                
                if !eventManager.isAuthorized {
                    VStack {
                        Spacer()
                        Text("Calendar access is not granted.")
                            .foregroundColor(.red)
                        Button("Request Access") {
                            eventManager.requestAccess()
                        }
                        .padding()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    List(eventManager.availableCalendars, id: \.calendarIdentifier) { calendar in
                        let isSelected = settingsManager.selectedCalendars.contains(calendar.calendarIdentifier)
                        HStack {
                            Circle()
                                .fill(Color(calendar.color))
                                .frame(width: 12, height: 12)
                            Text(calendar.title)
                            Spacer()
                            if isSelected {
                                Image(systemName: "checkmark.square.fill")
                                    .foregroundColor(.blue)
                            } else {
                                Image(systemName: "square")
                                    .foregroundColor(.gray)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            settingsManager.toggleCalendar(identifier: calendar.calendarIdentifier)
                        }
                    }
                }
            }
            .padding()
            .tabItem {
                Label("Calendars", systemImage: "calendar")
            }
        }
        .frame(width: 400, height: 350)
    }
}
