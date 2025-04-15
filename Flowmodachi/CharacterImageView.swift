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
    @State private var orbitStartTime = Date()
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
                OrbitingBoltEffect(characterSize: characterSize)
                    .id("orbit-\(characterId)") // force reanimation
                    .zIndex(5) // above character
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
                .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: isFloating)
                .transition(.asymmetric(insertion: .opacity.combined(with: .scale), removal: .opacity))
                .id(characterId)
                .zIndex(3)
                .onAppear {
                    fadeIn = false
                    withAnimation(.easeInOut(duration: 0.5)) {
                        fadeIn = true
                    }

                    if stage == 2 {
                        orbitStartTime = Date() // reset bolt timing
                    }
                }
                .onChange(of: isHopping) {
                    if stage == 1 && isHopping {
                        rippleTrigger = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            rippleTrigger = true
                        }
                    }
                }

        }
    }

    // MARK: - Computed View Properties
    private var characterSize: CGFloat {
        switch stage {
        case 0: return 40
        case 1: return 60
        case 2: return 75
        case 3: return 85
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

// MARK: - Orbiting Bolt Effect View
struct OrbitingBoltEffect: View {
    let characterSize: CGFloat

    var body: some View {
        TimelineView(.animation) { timeline in
            let now = timeline.date.timeIntervalSinceReferenceDate
            let angleOffset = now * 1.5  // 🌀 Slightly faster

            ZStack {
                ForEach(0..<6) { i in
                    let angle = (Double(i) / 6.0) * 2 * .pi + angleOffset
                    let radius: CGFloat = characterSize * 0.75

                    // Add subtle Y tilt for perspective illusion
                    let x = CGFloat(sin(angle)) * radius
                    let y = CGFloat(cos(angle)) * radius * 0.6
                    let z = cos(angle)

                    let scale = 0.6 + 0.4 * CGFloat(z)
                    let opacity = 0.3 + 0.7 * CGFloat(z)

                    Group {
                        // 🔵 Motion Glow Trail
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 24, height: 24)
                            .blur(radius: 8)
                            .offset(x: x, y: y)
                            .zIndex(z - 1.9)

                        // ⚡️ Bolt
                        Image(systemName: "bolt")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 24)
                            .foregroundColor(.yellow)
                            .scaleEffect(scale)
                            .opacity(opacity)
                            .offset(x: x, y: y)
                            .zIndex(z + 2.0) // ⬅️ boost foreground visibility
                    }
                }
            }
            .frame(width: characterSize * 2, height: characterSize * 2)
            .zIndex(5) // 🧠 Ensure this is ABOVE the character!
        }
    }
}

