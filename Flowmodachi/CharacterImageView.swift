import SwiftUI

// MARK: - Character Image View
struct CharacterImageView: View {
    // MARK: - Props
    let imageName: String
    let characterId: String
    let stage: Int

    let wobble: Bool
    let isHopping: Bool
    let isWiggling: Bool
    let isBouncing: Bool
    let isFloating: Bool
    let isBursting: Bool
    let showGlowFlash: Bool

    // MARK: - State
    @State private var fadeIn = false
    @State private var orbitAngle: Double = 0
    @State private var timer: Timer?
    @State private var rippleTrigger = false

    // MARK: - Body
    var body: some View {
        ZStack {
            // 🎯 Stage 1: Ripple Effect on Hop
            if stage == 1 {
                ZStack {
                    ForEach(0..<4) { i in
                        Circle()
                            .stroke(Color.white.opacity(0.25), lineWidth: 2)
                            .scaleEffect(rippleTrigger ? 1.0 + CGFloat(i) * 0.3 : 0.5)
                            .opacity(rippleTrigger ? 0.0 : 0.5)
                            .animation(
                                .easeOut(duration: 0.6)
                                    .delay(Double(i) * 0.1),
                                value: rippleTrigger
                            )
                    }
                }
                .frame(width: 80, height: 80)
                .zIndex(4)
            }

            // ⚡️ Stage 2: Orbiting Bolt Effect
            if stage == 2 {
                orbitingBolts
            }

            // 🌟 Shared: Glow Flash on Evolution
            if showGlowFlash {
                Circle()
                    .fill(Color.white)
                    .frame(width: characterSize + 20, height: characterSize + 20)
                    .opacity(0.6)
                    .blur(radius: 10)
                    .transition(.opacity)
                    .zIndex(1)
            }

            // 🧬 Main Character
            Image(imageName)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: characterSize, height: characterSize)
                .rotationEffect(rotationAngle)
                .scaleEffect(isBursting ? 1.3 : scaleAmount)
                .offset(y: verticalOffset)
                .opacity(fadeIn ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.4), value: wobble)
                .animation(.easeInOut(duration: 0.3), value: isHopping)
                .animation(.easeInOut(duration: 0.5), value: isWiggling)
                .animation(.easeInOut(duration: 0.4), value: isBouncing)
                .animation(
                    .easeInOut(duration: 2.5)
                        .repeatForever(autoreverses: true),
                    value: isFloating
                )
                .transition(.asymmetric(insertion: .opacity.combined(with: .scale), removal: .opacity))
                .id(characterId)
                .zIndex(3)
                .onAppear {
                    fadeIn = false
                    withAnimation(.easeInOut(duration: 0.5)) {
                        fadeIn = true
                    }
                }
        }
        .task(id: "\(characterId)-\(stage)-\(isHopping)") {
            if stage == 1 {
                if isHopping {
                    rippleTrigger = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        rippleTrigger = true
                    }
                }
            }

            if stage == 2 {
                orbitAngle = 0
                timer?.invalidate()
                timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
                    orbitAngle += 0.02
                }
            }
        }
    }

    // MARK: - Orbiting Bolts (Stage 2 Only)
    private var orbitingBolts: some View {
        ZStack {
            ForEach(0..<6) { i in
                let angle = (Double(i) / 6.0) * 2 * .pi + orbitAngle
                let radius: CGFloat = characterSize * 0.9
                let x = CGFloat(sin(angle)) * radius
                let y = CGFloat(cos(angle)) * radius * 0.5
                let z = cos(angle)

                let scale = 0.6 + 0.4 * CGFloat(z)
                let opacity = 0.4 + 0.6 * CGFloat(z)

                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 24, height: 24)
                    .blur(radius: 8)
                    .offset(x: x, y: y)
                    .zIndex(z - 0.1)

                Image(systemName: "bolt")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 24)
                    .foregroundColor(.yellow)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .offset(x: x, y: y)
                    .zIndex(z + 0.01)
            }
        }
        .frame(width: characterSize * 2, height: characterSize * 2)
        .zIndex(2)
    }

    // MARK: - Computed View Properties
    private var characterSize: CGFloat {
        switch stage {
        case 0: return 36
        case 1: return 65
        case 2: return 70
        case 3: return 80
        default: return 36
        }
    }

    private var rotationAngle: Angle {
        if stage == 0 && wobble {
            return .degrees(4)
        } else if stage == 2 && isWiggling {
            return .degrees(3)
        } else {
            return .degrees(0)
        }
    }

    private var scaleAmount: CGFloat {
        if stage == 1 && isHopping {
            return 1.05
        } else if stage == 2 && isBouncing {
            return 1.03
        } else {
            return 1.0
        }
    }

    private var verticalOffset: CGFloat {
        switch stage {
        case 0: return isHopping ? -4 : 0
        case 2: return isBouncing ? -6 : 0
        case 3: return isFloating ? -4 : 4
        default: return 0
        }
    }
}
