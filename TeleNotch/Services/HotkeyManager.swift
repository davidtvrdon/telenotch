import AppKit

class HotkeyManager {
    private let state: TeleprompterState
    private let scrollEngine: ScrollEngine
    private var globalMonitor: Any?
    private var localMonitor: Any?

    init(state: TeleprompterState, scrollEngine: ScrollEngine) {
        self.state = state
        self.scrollEngine = scrollEngine
    }

    func registerHotkeys() {
        // Global monitor: key events when TeleNotch is NOT the active app
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
        }

        // Local monitor: key events when TeleNotch IS the active app
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
            return event
        }
    }

    /// Request Accessibility permission if not already granted
    func requestAccessibilityIfNeeded() {
        let trusted = AXIsProcessTrusted()
        if !trusted {
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
            AXIsProcessTrustedWithOptions(options)
        }
    }

    private func handleKeyEvent(_ event: NSEvent) {
        // Ignore events with modifier keys (Cmd, Ctrl, etc.) to avoid conflicts
        guard event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            .subtracting([.capsLock, .numericPad, .function]).isEmpty else {
            return
        }

        switch event.keyCode {
        case 49:  // Spacebar
            scrollEngine.togglePlayPause()
        case 126: // Up arrow
            scrollEngine.adjustSpeed(by: 0.05)
        case 125: // Down arrow
            scrollEngine.adjustSpeed(by: -0.05)
        case 53:  // Escape
            state.isOverlayVisible.toggle()
        default:
            break
        }
    }

    deinit {
        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
        }
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
