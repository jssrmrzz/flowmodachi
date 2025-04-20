import SwiftUI

struct ConfettiView: View {
    // MARK: - Parameters
    var colors: [Color] = [.red, .yellow, .green, .blue, .purple, .pink, .orange]
    var emojis: [String] = ["💫", "✨","😎", "🧠", "🤓"]
    var particleCount: Int = 50
    var particleSize: CGFloat = 12
    var fallDistance: ClosedRange<CGFloat> = 100...300
    var animationDuration: Double = 1.6

    // MARK: - State
    @State private var isAnimating = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<particleCount, id: \.self) { i in
                    if Bool.random() {
                        Circle()
                            .fill(colors.randomElement() ?? .white)
                            .frame(width: particleSize, height: particleSize)
                            .position(randomStart(in: geometry))
                            .offset(y: isAnimating ? randomFall() : 0)
                            .opacity(isAnimating ? 0 : 1)
                            .animation(.easeOut(duration: animationDuration).delay(Double(i) * 0.02), value: isAnimating)
                    } else {
                        Text(emojis.randomElement() ?? "🎉")
                            .font(.system(size: particleSize))
                            .position(randomStart(in: geometry))
                            .offset(y: isAnimating ? randomFall() : 0)
                            .opacity(isAnimating ? 0 : 1)
                            .animation(.easeOut(duration: animationDuration).delay(Double(i) * 0.02), value: isAnimating)
                    }
                }
            }
            .onAppear {
                isAnimating = true
            }
        }
    }

    // MARK: - Helpers
    private func randomStart(in geometry: GeometryProxy) -> CGPoint {
        CGPoint(
            x: CGFloat.random(in: 0...geometry.size.width),
            y: CGFloat.random(in: 0...(geometry.size.height / 3))
        )
    }

    private func randomFall() -> CGFloat {
        CGFloat.random(in: fallDistance)
    }
}
