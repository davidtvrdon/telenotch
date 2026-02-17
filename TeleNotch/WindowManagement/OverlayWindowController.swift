import AppKit
import SwiftUI

class OverlayWindowController {
    private var panel: OverlayPanel?
    private let state: TeleprompterState
    private var observationTask: Task<Void, Never>?

    init(state: TeleprompterState) {
        self.state = state
    }

    func showOverlay() {
        guard panel == nil else {
            panel?.orderFrontRegardless()
            return
        }

        let overlayContent = OverlayView()
            .environment(state)

        let newPanel = OverlayPanel(contentView: overlayContent)
        panel = newPanel

        updatePanelFrame()
        newPanel.orderFrontRegardless()

        startObservingState()
    }

    func hideOverlay() {
        panel?.orderOut(nil)
    }

    func toggleVisibility() {
        guard let panel else {
            showOverlay()
            return
        }

        if panel.isVisible {
            hideOverlay()
            state.isOverlayVisible = false
        } else {
            panel.orderFrontRegardless()
            state.isOverlayVisible = true
        }
    }

    private func updatePanelFrame() {
        guard let panel else { return }
        let frame = DisplayUtilities.overlayFrame(
            width: state.overlayWidth,
            height: state.overlayHeight
        )
        panel.setFrame(frame, display: true)
    }

    private func startObservingState() {
        observationTask = Task { @MainActor [weak self] in
            guard let self else { return }
            var lastWidth = state.overlayWidth
            var lastHeight = state.overlayHeight
            var lastVisible = state.isOverlayVisible

            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))

                if state.overlayWidth != lastWidth || state.overlayHeight != lastHeight {
                    lastWidth = state.overlayWidth
                    lastHeight = state.overlayHeight
                    updatePanelFrame()
                }

                if state.isOverlayVisible != lastVisible {
                    lastVisible = state.isOverlayVisible
                    if lastVisible {
                        panel?.orderFrontRegardless()
                    } else {
                        panel?.orderOut(nil)
                    }
                }
            }
        }
    }

    deinit {
        observationTask?.cancel()
    }
}
