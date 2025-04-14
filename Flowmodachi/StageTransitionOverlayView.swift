import SwiftUI

// MARK: - Stage 2 Glow Ring
struct Stage2GlowRingView: View {
    var body: some View {
        Circle()
            .stroke(Color.yellow.opacity(0.4), lineWidth: 20)
            .blur(radius: 12)
            .scaleEffect(1.0)
            .blendMode(.screen)
            .transition(.scale)
    }
}

// MARK: - Bolt Jitter Model
private struct BoltJitter: Identifiable {
    let id = UUID()
    var baseOffset: CGSize
    var jitter: CGSize = .zero
    var rotation: Double = 0
}

// MARK: - Stage Transition Overlay
struct StageTransitionOverlayView: View {
    let fromStage: Int
    let toStage: Int

    @Binding var showEggPopFlash: Bool
    @Binding var showStage2Shockwave: Bool
    @Binding var showStage2Flash: Bool
    @Binding var showGlowFlash: Bool
    @Binding var isBursting: Bool
    @Binding var showLightningBolts: Bool

    @State private var boltJitters: [BoltJitter] = []

    var body: some View {
        ZStack {
            // Stage 0 → 1: Egg Pop Flash
            if fromStage == 0 && toStage == 1 && showEggPopFlash {
                EggPopFlashView(isVisible: showEggPopFlash)
            }

            // Stage 1 → 2: Flash, Shockwave, Lightning Bolts
            if fromStage == 1 && toStage == 2 {
                if showStage2Flash {
                    Circle()
                        .fill(Color.white)
                        .scaleEffect(1.5)
                        .opacity(0.6)
                        .blur(radius: 8)
                        .transition(.opacity)
                }

                if showStage2Shockwave {
                    Stage2GlowRingView()
                        .animation(.easeOut(duration: 0.5), value: showStage2Shockwave)
                }

                if showLightningBolts {
                    ForEach(boltJitters) { bolt in
                        Image(systemName: "bolt")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 28)
                            .foregroundColor(.yellow)
                            .opacity(showStage2Flash ? 0.9 : 0.2)
                            .scaleEffect(showStage2Flash ? 1.3 : 0.7)
                            .rotationEffect(.degrees(bolt.rotation))
                            .offset(
                                x: bolt.baseOffset.width + bolt.jitter.width,
                                y: bolt.baseOffset.height + bolt.jitter.height
                            )
                            .animation(
                                .easeInOut(duration: 0.1)
                                    .repeatForever(autoreverses: true),
                                value: bolt.jitter
                            )
                    }
                }
            }

            // Universal: Glow Flash Pulse
            if showGlowFlash {
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .blur(radius: 16)
                    .scaleEffect(isBursting ? 1.4 : 1.0)
                    .transition(.opacity)
            }
        }
        .onAppear {
            if boltJitters.isEmpty {
                boltJitters = (0..<4).map { _ in
                    BoltJitter(
                        baseOffset: CGSize(
                            width: CGFloat.random(in: -60...60),
                            height: CGFloat.random(in: -60...60)
                        ),
                        jitter: CGSize(
                            width: CGFloat.random(in: -3...3),
                            height: CGFloat.random(in: -3...3)
                        ),
                        rotation: Double.random(in: -30...30)
                    )
                }

                // Optionally re-jitter bolts every 0.2s
                Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                    for i in boltJitters.indices {
                        boltJitters[i].jitter = CGSize(
                            width: CGFloat.random(in: -4...4),
                            height: CGFloat.random(in: -4...4)
                        )
                        boltJitters[i].rotation = Double.random(in: -25...25)
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}

