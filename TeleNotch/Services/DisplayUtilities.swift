import AppKit

enum DisplayUtilities {

    /// Whether the primary screen has a camera notch
    static var hasNotch: Bool {
        guard let screen = NSScreen.main else { return false }
        return screen.safeAreaInsets.top > 0
    }

    /// Menu bar height in points
    static var menuBarHeight: CGFloat {
        guard let screen = NSScreen.main else { return 24 }
        return screen.frame.maxY - screen.visibleFrame.maxY
    }

    /// Calculate the overlay frame centered below the menu bar
    static func overlayFrame(width: CGFloat, height: CGFloat) -> NSRect {
        guard let screen = NSScreen.main else {
            return NSRect(x: 0, y: 0, width: width, height: height)
        }

        let x = screen.frame.midX - width / 2.0
        let y = screen.visibleFrame.maxY - height

        return NSRect(x: x, y: y, width: width, height: height)
    }
}
