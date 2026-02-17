import Foundation
import Observation

@Observable
class TeleprompterState {
    // MARK: - Script Content
    var scriptText: String = "Paste your script here...\n\nThis is TeleNotch, your camera-first teleprompter. The text scrolls upward so you can read while looking directly at your camera.\n\nOpen Settings (Cmd+,) to paste your own script, adjust font size, scroll speed, and overlay dimensions.\n\nPress Space to play/pause. Use Up/Down arrows to adjust speed. Press Esc to hide the overlay."

    // MARK: - Scroll State
    var scrollOffset: CGFloat = 0.0
    var isPlaying: Bool = false
    var isHovering: Bool = false

    // MARK: - Speed (0.0 to 1.0)
    var speedNormalized: CGFloat = 0.03

    /// Speed in points per second, mapped from 0..1 to 20..200
    var pointsPerSecond: CGFloat {
        let minSpeed: CGFloat = 20.0
        let maxSpeed: CGFloat = 200.0
        return minSpeed + speedNormalized * (maxSpeed - minSpeed)
    }

    // MARK: - Display Settings
    var fontSize: CGFloat = 14.0
    var overlayWidth: CGFloat = 300.0
    var overlayHeight: CGFloat = 70.0

    // MARK: - Features
    var loopEnabled: Bool = false
    var isOverlayVisible: Bool = true

    // MARK: - Layout (set by OverlayView after measuring text)
    var contentHeight: CGFloat = 0.0

    // MARK: - Actions
    func resetScroll() {
        scrollOffset = 0.0
    }

    func clampScrollOffset() {
        let maxOffset = max(0, contentHeight - overlayHeight + 40)
        scrollOffset = max(0, min(scrollOffset, maxOffset))
    }
}
