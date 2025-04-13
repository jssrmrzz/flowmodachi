import SwiftUI

// MARK: - Mood Enum
enum CreatureMood {
    case happy
    case neutral
    case sleepy
}

// MARK: - Sparkle Particle
struct SparkleParticle: Identifiable {
    let id = UUID()
    let baseX: CGFloat
    let baseY: CGFloat
    let size: CGFloat
    let delay: Double
    let driftAmount: CGFloat
}

// MARK: - Flowmodachi Visual View
struct FlowmodachiVisualView: View {
    @EnvironmentObject var evolutionTracker: EvolutionTracker
    @EnvironmentObject var petManager: PetManager
    @AppStorage("debugEvolutionStage") private var debugOverrideStage: Int = -1

    // MARK: - Inputs
    let elapsedSeconds: Int
    let isSleeping: Bool
    let breakSecondsRemaining: Int
    let breakTotalSeconds: Int
    let mood: CreatureMood

    // MARK: - Local State
    @State private var isPulsing = false
    @State private var wobble = false
    @State private var isHopping = false
    @State private var isWiggling = false
    @State private var isBouncing = false
    @State private var isFloating = false
    @State private var auraColor: Color = .purple.opacity(0.3)
    @State private var particles: [SparkleParticle] = []
    @State private var auraRotationAngle: Double = 0

    private let auraColors: [Color] = [
        .purple.opacity(0.3),
        .blue.opacity(0.3),
        .teal.opacity(0.3),
        .mint.opacity(0.3),
        .yellow.opacity(0.3),
        .pink.opacity(0.3)
    ]

    // MARK: - Body
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                backgroundRing

                if characterImageExists {
                    Image(petManager.currentCharacter.imageName)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: characterSize, height: characterSize)
                        .rotationEffect(rotationAngle)
                        .scaleEffect(scaleAmount)
                        .offset(y: verticalOffset)
                        .animation(.easeInOut(duration: 0.4), value: wobble)
                        .animation(.easeInOut(duration: 0.3), value: isHopping)
                        .animation(.easeInOut(duration: 0.5), value: isWiggling)
                        .animation(.easeInOut(duration: 0.4), value: isBouncing)
                        .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: isFloating)
                        .transition(.scale.combined(with: .opacity))
                        .id(petManager.currentCharacter.id)
                        .overlay(auraOverlay)
                } else {
                    Image(systemName: "questionmark.circle")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Text("Missing\nArt")
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.red)
                                .padding(.top, 30)
                        )
                }

                if isSleeping {
                    Text(formattedBreakTime)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.blue)
                        .offset(y: 36)
                }
            }
            .frame(width: 70, height: 70)

            if !isSleeping {
                Text(moodLabel)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .transition(.opacity)
            }

            #if DEBUG
            if debugOverrideStage >= 0 {
                Text("Debug Stage Override Active")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            #endif
        }
        .onAppear {
            isPulsing = isSleeping
            startStageAnimationLoop()

            if particles.isEmpty {
                particles = (0..<10).map { i in
                    SparkleParticle(
                        baseX: CGFloat.random(in: -50...50),
                        baseY: CGFloat.random(in: -50...50),
                        size: CGFloat.random(in: 4...7),
                        delay: Double(i) * 0.25,
                        driftAmount: CGFloat.random(in: 3...6)
                    )
                }
            }
        }
        .onChange(of: isSleeping) { _, newValue in
            isPulsing = newValue
        }
        .onChange(of: petManager.currentCharacter.id) { _, _ in
            startStageAnimationLoop()
        }
    }

    // MARK: - Aura Overlay
    private var auraOverlay: some View {
        Group {
            if petManager.currentCharacter.stage == 3 {
                ZStack {
                    // 🌈 Rainbow Aura Glow (Blurred Background Ring)
                    Circle()
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [.purple, .blue, .mint, .green, .yellow, .orange, .pink, .purple]),
                                center: .center
                            ),
                            lineWidth: 10
                        )
                        .scaleEffect(1.25)
                        .blur(radius: 12)
                        .opacity(0.4)
                        .rotationEffect(.degrees(auraRotationAngle))

                    // 🌈 Crisp Rotating Ring on Top
                    Circle()
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [.purple, .blue, .mint, .green, .yellow, .orange, .pink, .purple]),
                                center: .center
                            ),
                            lineWidth: 5
                        )
                        .scaleEffect(1.2)
                        .opacity(0.8)
                        .rotationEffect(.degrees(auraRotationAngle))

                    // ✨ Floating Zen Particles
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
    }




    // MARK: - Computed Properties

    private var characterImageExists: Bool {
        NSImage(named: petManager.currentCharacter.imageName) != nil
    }

    private var characterSize: CGFloat {
        switch petManager.currentCharacter.stage {
        case 0: return 36
        case 1: return 65
        case 2: return 70
        case 3: return 80
        default: return 36
        }
    }

    private var rotationAngle: Angle {
        if petManager.currentCharacter.stage == 0 && wobble {
            return .degrees(4)
        } else if petManager.currentCharacter.stage == 2 && isWiggling {
            return .degrees(3)
        } else {
            return .degrees(0)
        }
    }

    private var scaleAmount: CGFloat {
        if petManager.currentCharacter.stage == 1 && isHopping {
            return 1.05
        } else if petManager.currentCharacter.stage == 2 && isBouncing {
            return 1.03
        } else {
            return 1.0
        }
    }

    private var verticalOffset: CGFloat {
        switch petManager.currentCharacter.stage {
        case 0: return isHopping ? -4 : 0
        case 2: return isBouncing ? -6 : 0
        case 3: return isFloating ? -4 : 4
        default: return 0
        }
    }

    // MARK: - Animation Dispatcher

    private func startStageAnimationLoop() {
        let stage = petManager.currentCharacter.stage

        wobble = false
        isHopping = false
        isWiggling = false
        isBouncing = false
        isFloating = false

        switch stage {
        case 0:
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                withAnimation { wobble = true; isHopping = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation {
                        wobble = false
                        isHopping = false
                    }
                }
            }

        case 1:
            Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
                withAnimation { isHopping = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation { isHopping = false }
                }
            }

        case 2:
            Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.5)) {
                    isWiggling = true
                    isBouncing = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        isWiggling = false
                        isBouncing = false
                    }
                }
            }

        case 3:
            auraColor = auraColors.randomElement() ?? .purple.opacity(0.3)
            auraRotationAngle = 0
            Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
                auraRotationAngle += 0.2
            }
            Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 4.0)) {
                    isFloating.toggle()
                }
            }

        default:
            break
        }
    }

    // MARK: - Visual Helpers

    private var backgroundRing: some View {
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

    private var formattedBreakTime: String {
        let minutes = breakSecondsRemaining / 60
        let seconds = breakSecondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var flowProgress: Double {
        let totalTime: Double = 9.0
        return min(Double(elapsedSeconds) / totalTime, 1.0)
    }

    private var moodLabel: String {
        switch mood {
        case .happy: return "Feeling great!"
        case .neutral: return "Steady focus"
        case .sleepy: return "A bit sleepy 💤"
        }
    }
}

