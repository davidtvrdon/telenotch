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

// MARK: - Top-Attached Shape (flat top, rounded bottom)

/// A rectangle that is flat on top and rounded only on the bottom corners.
struct TopAttachedShape: Shape {
    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        path.addArc(
            center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
        path.addArc(
            center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Overlay View

struct OverlayView: View {
    @Environment(TeleprompterState.self) var state
    @State private var showControls = false

    /// Extra top padding to push text below the menu-bar / notch region
    private var topInset: CGFloat {
        DisplayUtilities.menuBarHeight
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Solid black background — flat on top, rounded on bottom
            TopAttachedShape(cornerRadius: 14)
                .fill(Color.black)

            // Scrolling text container — offset down so text doesn't hide behind menu bar
            GeometryReader { geometry in
                Text(state.scriptText)
                    .font(.system(size: state.fontSize, weight: .medium))
                    .foregroundColor(.white)
                    .lineSpacing(state.fontSize * 0.4)
                    .padding(.horizontal, 16)
                    .padding(.top, topInset + 6)
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

            // Bottom fade-out gradient — text fades into black at the bottom
            VStack {
                Spacer()
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0), Color.black]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 30)
                // Clip to match the shape's bottom corners
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 14,
                        bottomTrailingRadius: 14,
                        topTrailingRadius: 0
                    )
                )
            }

            // Scroll wheel interceptor
            ScrollWheelInterceptor { delta in
                state.scrollOffset -= delta
                state.clampScrollOffset()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Always-visible progress indicator — below the menu bar area, top-right
            VStack {
                HStack {
                    Spacer()
                    ProgressIndicator()
                        .environment(state)
                        .padding(.top, topInset + 4)
                        .padding(.trailing, 8)
                }
                Spacer()
            }

            // Countdown overlay
            if state.countdownValue > 0 {
                ZStack {
                    TopAttachedShape(cornerRadius: 14)
                        .fill(Color.black.opacity(0.9))
                    Text("\(state.countdownValue)")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .offset(y: topInset / 2)
                }
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
                .padding(.bottom, 8)
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
            Circle()
                .stroke(Color.green.opacity(0.15), lineWidth: 2)
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
                state.requestPlayPause()
            } label: {
                Image(systemName: state.isPlaying || state.countdownValue > 0 ? "pause.fill" : "play.fill")
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
