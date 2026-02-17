import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    static private(set) var shared: AppDelegate!

    let teleprompterState = TeleprompterState()
    var overlayController: OverlayWindowController!
    var scrollEngine: ScrollEngine!
    var hotkeyManager: HotkeyManager!
    private var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self

        // Create overlay window
        overlayController = OverlayWindowController(state: teleprompterState)
        overlayController.showOverlay()

        // Start scroll engine
        scrollEngine = ScrollEngine(state: teleprompterState)

        // Register global hotkeys
        hotkeyManager = HotkeyManager(state: teleprompterState, scrollEngine: scrollEngine)
        hotkeyManager.requestAccessibilityIfNeeded()
        hotkeyManager.registerHotkeys()
    }

    func openSettings() {
        if let window = settingsWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let settingsView = SettingsView()
            .environment(teleprompterState)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 420),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "TeleNotch Settings"
        window.contentView = NSHostingView(rootView: settingsView)
        window.center()
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow = window
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        return .terminateNow
    }
}
