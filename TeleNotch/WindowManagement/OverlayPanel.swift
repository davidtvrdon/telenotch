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

        // Floating panel behavior first (this sets level to .floating)
        isFloatingPanel = true
        // Then override level to sit above the menu bar (mainMenu=24, we use 25)
        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.mainMenuWindow)) + 1)

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

    // Prevent macOS from constraining the window below the menu bar
    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        return frameRect
    }
}
