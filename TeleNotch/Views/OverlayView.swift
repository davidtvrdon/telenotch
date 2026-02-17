import SwiftUI

// MARK: - Scroll Wheel Interception

/// NSView that intercepts scroll wheel events and forwards the delta to a handler.
class ScrollWheelNSView: NSView {
    var handler: ((CGFloat) -> Void)?

    override func scrollWheel(with event: NSEvent) {
        handler?(event.scrollingDeltaY)
    }
}

/// NSViewRepresentable bridge for scroll wheel interception.
struct ScrollWheelInterceptor: NSViewRepresentable {
    let handler: (CGFloat) -> Void

    func makeNSView(context: Context) -> ScrollWheelNSView {
        let view = ScrollWheelNSView()
        view.handler = handler
        return view
    }

    func updateNSView(_ nsView: ScrollWheelNSView, context: Context) {
        nsView.handler = handler
    }
}

// MARK: - Overlay View

struct OverlayView: View {
    @Environment(TeleprompterState.self) var state
    @State private var showControls = false

    var body: some View {
        ZStack(alignment: .top) {
            // Solid black background
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black)

            // Scrolling text container
            GeometryReader { geometry in
                Text(state.scriptText)
                    .font(.system(size: state.fontSize, weight: .medium))
                    .foregroundColor(.white)
                    .lineSpacing(state.fontSize * 0.4)
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
                    .frame(width: geometry.size.width, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .offset(y: -state.scrollOffset)
                    .background(
                        GeometryReader { textGeometry in
                            Color.clear
                                .preference(key: ContentHeightKey.self, value: textGeometry.size.height)
                        }
                    )
            }
            .clipped()
            .onPreferenceChange(ContentHeightKey.self) { height in
                state.contentHeight = height
            }

            // Scroll wheel interceptor
            ScrollWheelInterceptor { delta in
                state.scrollOffset -= delta
                state.clampScrollOffset()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Always-visible progress indicator in top-right corner
            VStack {
                HStack {
                    Spacer()
                    ProgressIndicator()
                        .environment(state)
                        .padding(.top, 4)
                        .padding(.trailing, 8)
                }
                Spacer()
            }

            // Control bar (bottom-right, appears on hover)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    OverlayControlBar()
                        .environment(state)
                }
                .padding(.trailing, 8)
                .padding(.bottom, 5)
                .opacity(showControls ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: showControls)
            }
        }
        .onHover { hovering in
            showControls = hovering
            state.isHovering = hovering
        }
    }
}

// MARK: - Progress Indicator

struct ProgressIndicator: View {
    @Environment(TeleprompterState.self) var state

    private var progress: Double {
        guard state.contentHeight > state.overlayHeight else { return 0 }
        let maxOffset = state.contentHeight - state.overlayHeight + 40
        guard maxOffset > 0 else { return 0 }
        return min(1.0, max(0.0, Double(state.scrollOffset / maxOffset)))
    }

    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color.green.opacity(0.15), lineWidth: 2)

            // Progress arc — fills up as you scroll toward the end
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.green.opacity(0.6), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 12, height: 12)
    }
}

// MARK: - Overlay Control Bar

struct OverlayControlBar: View {
    @Environment(TeleprompterState.self) var state

    var body: some View {
        HStack(spacing: 4) {
            Button {
                state.isPlaying.toggle()
            } label: {
                Image(systemName: state.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(width: 22, height: 22)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button {
                AppDelegate.shared.openSettings()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(width: 22, height: 22)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.15))
        )
    }
}

// MARK: - Preference Key for Content Height

private struct ContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
