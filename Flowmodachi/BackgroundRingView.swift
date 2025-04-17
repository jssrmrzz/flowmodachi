import SwiftUI

struct BackgroundRingView: View {
    let isSleeping: Bool
    let isPulsing: Bool
    let flowProgress: Double

    var body: some View {
        ZStack {
            if isSleeping {
                // 🌫️ Soft pulsing glow
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .scaleEffect(isPulsing ? 1.05 : 0.95)
                    .blur(radius: 20)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isPulsing)

                // 💠 Breathing ring base
                Circle()
                    .stroke(Color.blue.opacity(0.15), lineWidth: 8)
                    .scaleEffect(isPulsing ? 1.05 : 0.95)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isPulsing)

                // 🌈 Gradient progress ring
                Circle()
                    .trim(from: 0, to: flowProgress)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                .blue, .mint, .teal, .blue
                            ]),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .scaleEffect(isPulsing ? 1.05 : 0.95)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isPulsing)
                    .animation(.easeInOut(duration: 0.3), value: flowProgress)
            } else {
                // 🟣 Default focus ring
                Circle()
                    .trim(from: 0, to: flowProgress)
                    .stroke(Color.purple, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.4), value: flowProgress)
            }
        }
    }
}
