import SwiftUI

struct ReadingGuideView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 40)

            Rectangle()
                .fill(Color.red.opacity(0.3))
                .frame(height: 2)

            // Small downward-pointing triangle indicator
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 8))
                .foregroundColor(Color.red.opacity(0.3))

            Spacer()
        }
    }
}
