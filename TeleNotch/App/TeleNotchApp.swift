import SwiftUI

@main
struct TeleNotchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("TeleNotch", systemImage: "text.viewfinder") {
            MenuBarView()
                .environment(appDelegate.teleprompterState)
        }
        .menuBarExtraStyle(.menu)
    }
}
