import AppKit
import SwiftUI

class OverlayPanel: NSPanel {

    init<Content: View>(contentView: Content) {
        super.init(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        // Always on top
        level = .floating
        isFloatingPanel = true

        // Transparent background
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false

        // Ghost Mode — screen share invisibility (best-effort)
        sharingType = .none

        // Collection behaviors
        collectionBehavior = [
            .canJoinAllSpaces,
            .stationary,
            .fullScreenAuxiliary,
            .transient,
            .ignoresCycle,
        ]

        // Interaction
        isMovableByWindowBackground = false
        acceptsMouseMovedEvents = true
        hidesOnDeactivate = false
        canHide = false

        // Title bar
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        styleMask.insert(.fullSizeContentView)

        // SwiftUI content
        let hostingView = NSHostingView(rootView: contentView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView = hostingView
    }

    // Allow button clicks inside the panel while nonactivatingPanel prevents app activation
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}
