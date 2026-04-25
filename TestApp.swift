import SwiftUI

@main
struct TestApp: App {
    var body: some Scene {
        MenuBarExtra("Test", systemImage: "star") {
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}
