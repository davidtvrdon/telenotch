import Foundation

class ScrollEngine {
    private let state: TeleprompterState
    private var timer: Timer?
    private let frameRate: TimeInterval = 1.0 / 60.0

    init(state: TeleprompterState) {
        self.state = state
        startTimer()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(
            withTimeInterval: frameRate,
            repeats: true
        ) { [weak self] _ in
            self?.tick()
        }
        // Fire during event tracking (menu open, drag, etc.)
        if let timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }

    private func tick() {
        guard state.isPlaying, !state.isHovering else { return }

        let delta = state.pointsPerSecond * frameRate
        state.scrollOffset += delta

        // Check if we've scrolled past the content
        let maxOffset = max(0, state.contentHeight - state.overlayHeight + 40)
        if state.scrollOffset >= maxOffset {
            if state.loopEnabled {
                state.scrollOffset = 0
            } else {
                state.isPlaying = false
                state.scrollOffset = maxOffset
            }
        }
    }

    func togglePlayPause() {
        state.requestPlayPause()
    }

    func adjustSpeed(by delta: CGFloat) {
        state.speedNormalized = max(0, min(1, state.speedNormalized + delta))
    }

    func resetToBeginning() {
        state.scrollOffset = 0
        state.isPlaying = false
    }

    deinit {
        timer?.invalidate()
    }
}
