import SwiftUI

struct AuraRingView: View {
    let rotationAngle: Double
    let isPulsing: Bool
    let particles: [SparkleParticle]
    let auraColor: Color
    let isFloating: Bool

    var body: some View {
        ZStack {
            // Glow background
            Circle()
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.purple, .blue, .mint, .green, .yellow, .orange, .pink, .purple]),
                        center: .center
                    ),
                    lineWidth: 10
                )
                .scaleEffect(isPulsing ? 1.3 : 1.2)
                .blur(radius: 12)
                .opacity(0.4)
                .rotationEffect(.degrees(rotationAngle))

            // Zen sparkles
            ForEach(particles) { particle in
                Circle()
                    .fill(auraColor)
                    .frame(width: particle.size, height: particle.size)
                    .offset(
                        x: particle.baseX + (isFloating ? particle.driftAmount : -particle.driftAmount),
                        y: particle.baseY + (isFloating ? -particle.driftAmount : particle.driftAmount)
                    )
                    .opacity(isFloating ? 0.7 : 0.4)
                    .animation(
                        Animation.easeInOut(duration: 4.0)
                            .repeatForever(autoreverses: true)
                            .delay(particle.delay),
                        value: isFloating
                    )
            }
        }
    }
}
