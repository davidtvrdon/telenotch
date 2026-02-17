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

    // MARK: - Countdown
    var countdownValue: Int = 0
    private var countdownTimer: Timer?

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
    var overlayHeight: CGFloat = 100.0

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

    /// Called when user presses play/pause (Space key or button).
    /// If paused → starts a 3-2-1 countdown then plays.
    /// If playing or counting down → stops immediately.
    func requestPlayPause() {
        if isPlaying || countdownValue > 0 {
            // Stop immediately
            cancelCountdown()
            isPlaying = false
        } else {
            // Start countdown
            startCountdown()
        }
    }

    private func startCountdown() {
        countdownValue = 3
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self else { timer.invalidate(); return }
            DispatchQueue.main.async {
                self.countdownValue -= 1
                if self.countdownValue <= 0 {
                    timer.invalidate()
                    self.countdownTimer = nil
                    self.countdownValue = 0
                    self.isPlaying = true
                }
            }
        }
    }

    private func cancelCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        countdownValue = 0
    }
}
