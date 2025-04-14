import SwiftUI

struct BackgroundRingView: View {
    let isSleeping: Bool
    let isPulsing: Bool
    let flowProgress: Double

    var body: some View {
        Group {
            if isSleeping {
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 8)
                    .scaleEffect(isPulsing ? 1.1 : 0.9)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isPulsing)
            } else {
                Circle()
                    .trim(from: 0, to: flowProgress)
                    .stroke(Color.purple, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.4), value: flowProgress)
            }
        }
    }
}

