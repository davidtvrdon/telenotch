import SwiftUI

struct SettingsView: View {
    @Environment(TeleprompterState.self) var state

    var body: some View {
        @Bindable var state = state

        TabView {
            // MARK: - Script Tab
            VStack(alignment: .leading, spacing: 12) {
                Text("Script")
                    .font(.headline)

                TextEditor(text: $state.scriptText)
                    .font(.system(size: 14, design: .monospaced))
                    .frame(minHeight: 200)
                    .scrollContentBackground(.visible)

                HStack {
                    Button("Reset Scroll") {
                        state.resetScroll()
                    }

                    Spacer()

                    Toggle("Loop when finished", isOn: $state.loopEnabled)
                }
            }
            .padding()
            .tabItem { Label("Script", systemImage: "doc.text") }

            // MARK: - Display Tab
            VStack(alignment: .leading, spacing: 16) {
                Text("Display Settings")
                    .font(.headline)

                // Speed
                VStack(alignment: .leading, spacing: 4) {
                    Text("Scroll Speed: \(Int(state.speedNormalized * 100))%")
                    Slider(value: $state.speedNormalized, in: 0...1)
                }

                Divider()

                // Font Size
                VStack(alignment: .leading, spacing: 4) {
                    Text("Font Size: \(Int(state.fontSize))pt")
                    Slider(value: $state.fontSize, in: 16...72, step: 1)
                }

                Divider()

                // Overlay Dimensions
                VStack(alignment: .leading, spacing: 4) {
                    Text("Overlay Width: \(Int(state.overlayWidth))px")
                    Slider(value: $state.overlayWidth, in: 300...1000, step: 10)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Overlay Height: \(Int(state.overlayHeight))px")
                    Slider(value: $state.overlayHeight, in: 50...250, step: 10)
                }
            }
            .padding()
            .tabItem { Label("Display", systemImage: "textformat.size") }
        }
        .frame(width: 500, height: 400)
    }
}
