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
    @State private var auraColor: Color = .purple.opacity(0.3)
    @State private var particles: [SparkleParticle] = []
    @State private var showEggPopFlash = false
    @StateObject private var animationManager = FlowmodachiAnimationManager()
    @State private var previousCharacterId: String? = nil
    @State private var isBursting = false
    @State private var showGlowFlash = false

    private let auraColors: [Color] = [
        .purple.opacity(0.3), .blue.opacity(0.3), .teal.opacity(0.3),
        .mint.opacity(0.3), .yellow.opacity(0.3), .pink.opacity(0.3)
    ]

    // MARK: - Body
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                backgroundRing

                if characterImageExists {
                    ZStack {
                        if let previousId = previousCharacterId, previousId != petManager.currentCharacter.id {
                            CharacterImageView(
                                imageName: previousId,
                                characterId: previousId,
                                stage: petManager.currentCharacter.stage,
                                wobble: false,
                                isHopping: false,
                                isWiggling: false,
                                isBouncing: false,
                                isFloating: false,
                                isBursting: false,
                                showGlowFlash: false
                            )
                            .opacity(0.0)
                            .transition(.opacity)
                        }

                        CharacterImageView(
                            imageName: petManager.currentCharacter.imageName,
                            characterId: petManager.currentCharacter.id,
                            stage: petManager.currentCharacter.stage,
                            wobble: animationManager.wobble,
                            isHopping: animationManager.isHopping,
                            isWiggling: animationManager.isWiggling,
                            isBouncing: animationManager.isBouncing,
                            isFloating: animationManager.isFloating,
                            isBursting: isBursting,
                            showGlowFlash: showGlowFlash
                        )
                        .transition(.opacity)
                        .overlay(auraOverlay)
                    }
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

                EggPopFlashView(isVisible: showEggPopFlash)

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
            animationManager.startAnimations(forStage: petManager.currentCharacter.stage)
            generateParticlesIfNeeded()
        }
        .onChange(of: isSleeping) { _, newValue in
            isPulsing = newValue
        }
        .onChange(of: petManager.currentCharacter.id) { oldId, newId in
            previousCharacterId = oldId

            withAnimation(.easeOut(duration: 0.3)) {
                showEggPopFlash = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                showEggPopFlash = false
            }

            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isBursting = true
                showGlowFlash = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation {
                    isBursting = false
                    showGlowFlash = false
                }
            }

            animationManager.startAnimations(forStage: petManager.currentCharacter.stage)
        }
        .onChange(of: debugOverrideStage) { _, newValue in
            guard newValue >= 0, newValue <= 3 else { return }

            let baseIdPrefix = petManager.currentCharacter.id.components(separatedBy: "_").dropLast().joined(separator: "_")

            let match = petManager.characterMap.values.first {
                $0.stage == newValue && $0.id.contains(baseIdPrefix)
            }

            if let overrideCharacter = match {
                withAnimation(.spring()) {
                    petManager.currentCharacter = overrideCharacter
                    UserDefaults.standard.set(overrideCharacter.id, forKey: "currentCharacterID")
                }

                if newValue == 1 {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showEggPopFlash = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        showEggPopFlash = false
                    }
                }
            }
        }
    }

    // MARK: - Aura Overlay
    private var auraOverlay: some View {
        Group {
            if petManager.currentCharacter.stage == 3 {
                AuraRingView(
                    rotationAngle: animationManager.auraRotation,
                    isPulsing: animationManager.isAuraPulsing,
                    particles: particles,
                    auraColor: auraColor,
                    isFloating: animationManager.isFloating
                )
            }
        }
    }

    // MARK: - Visual Helpers
    private var characterImageExists: Bool {
        NSImage(named: petManager.currentCharacter.imageName) != nil
    }

    private var backgroundRing: some View {
        BackgroundRingView(
            isSleeping: isSleeping,
            isPulsing: isPulsing,
            flowProgress: flowProgress
        )
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

    private func generateParticlesIfNeeded() {
        guard particles.isEmpty else { return }
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
