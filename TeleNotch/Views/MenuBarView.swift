import SwiftUI

struct MenuBarView: View {
    @Environment(TeleprompterState.self) var state

    var body: some View {
        Button(state.isPlaying ? "Pause" : "Play") {
            state.isPlaying.toggle()
        }
        .keyboardShortcut(.space, modifiers: [])

        Button("Reset to Beginning") {
            state.resetScroll()
        }

        Divider()

        Button(state.isOverlayVisible ? "Hide Overlay" : "Show Overlay") {
            state.isOverlayVisible.toggle()
        }
        .keyboardShortcut(.escape, modifiers: [])

        Divider()

        Button("Settings...") {
            AppDelegate.shared.openSettings()
        }
        .keyboardShortcut(",", modifiers: .command)

        Divider()

        Button("Quit TeleNotch") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: .command)
    }
}
