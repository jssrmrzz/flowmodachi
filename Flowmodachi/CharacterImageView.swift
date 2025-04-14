import SwiftUI

// MARK: - Character Image View
struct CharacterImageView: View {
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

    @State private var fadeIn = false

    var body: some View {
        ZStack {
            // 🌟 Evolution Glow Flash
            if showGlowFlash {
                Circle()
                    .fill(Color.white)
                    .frame(width: characterSize + 20, height: characterSize + 20)
                    .opacity(0.6)
                    .blur(radius: 10)
                    .transition(.opacity)
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
                .onAppear {
                    fadeIn = false
                    withAnimation(.easeInOut(duration: 0.5)) {
                        fadeIn = true
                    }
                }
                .animation(.easeInOut(duration: 0.4), value: wobble)
                .animation(.easeInOut(duration: 0.3), value: isHopping)
                .animation(.easeInOut(duration: 0.5), value: isWiggling)
                .animation(.easeInOut(duration: 0.4), value: isBouncing)
                .animation(
                    .easeInOut(duration: 2.5).repeatForever(autoreverses: true),
                    value: isFloating
                )
                .transition(.asymmetric(insertion: .opacity.combined(with: .scale), removal: .opacity))
                .id(characterId)
        }
    }

    // MARK: - Computed Visual Properties

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
