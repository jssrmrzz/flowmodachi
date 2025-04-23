import SwiftUI

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
    let isOnBreak: Bool
    let breakSecondsRemaining: Int
    let breakTotalSeconds: Int

    // MARK: - Local State
    @State private var isPulsing = false
    @State private var auraColor: Color = .purple.opacity(0.3)
    @State private var particles: [SparkleParticle] = []
    @State private var previousCharacterId: String? = nil
    @State private var previousStage: Int = 0
    @State private var fromStage: Int = 0
    @State private var toStage: Int = 0
    @State private var isBursting = false
    @State private var showGlowFlash = false
    @State private var showStage2Shockwave = false
    @State private var showStage2Flash = false
    @State private var showEggPopFlash = false
    @StateObject private var animationManager = FlowmodachiAnimationManager()
    @State private var showLightningBolts = false

    private let auraColors: [Color] = [
        .purple.opacity(0.3), .blue.opacity(0.3), .teal.opacity(0.3),
        .mint.opacity(0.3), .yellow.opacity(0.3), .pink.opacity(0.3)
    ]

    // MARK: - Body
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                backgroundRing
                    .frame(width: 140, height: 140) // ✅ Ensure ring is same across stages

                if characterImageExists {
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

                StageTransitionOverlayView(
                    fromStage: fromStage,
                    toStage: toStage,
                    showEggPopFlash: $showEggPopFlash,
                    showStage2Shockwave: $showStage2Shockwave,
                    showStage2Flash: $showStage2Flash,
                    showGlowFlash: $showGlowFlash,
                    isBursting: $isBursting,
                    showLightningBolts: $showLightningBolts
                )

//                if isOnBreak {
//                    Text(formattedBreakTime)
//                        .font(.system(.caption, design: .monospaced))
//                        .foregroundColor(.blue)
//                        .offset(y: 36)
//                }
            }
            .frame(width: 140, height: 140)

            #if DEBUG
            if debugOverrideStage >= 0 {
                Text("Debug Stage Override Active")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            #endif
        }
        .onAppear {
            isPulsing = isOnBreak
            animationManager.startAnimations(forStage: petManager.currentCharacter.stage)
            generateParticlesIfNeeded()
        }
        .onChange(of: isOnBreak) { _, newValue in
            isPulsing = newValue
        }
        .onChange(of: petManager.currentCharacter.id) { oldId, newId in
            previousCharacterId = oldId
            fromStage = previousStage
            toStage = petManager.currentCharacter.stage
            previousStage = toStage

            triggerTransitionAnimations(from: fromStage, to: toStage)
            animationManager.startAnimations(forStage: toStage)
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
            isOnBreak: isOnBreak,
            isPulsing: isPulsing,
            flowProgress: isOnBreak ? breakProgress : 0
        )
    }

    private var breakProgress: Double {
        guard breakTotalSeconds > 0 else { return 0 }
        let completed = Double(breakTotalSeconds - breakSecondsRemaining)
        return min(max(completed / Double(breakTotalSeconds), 0.0), 1.0)
    }

//    private var formattedBreakTime: String {
//        let minutes = breakSecondsRemaining / 60
//        let seconds = breakSecondsRemaining % 60
//        return String(format: "%02d:%02d", minutes, seconds)
//    }

    private var flowProgress: Double {
        let totalTime: Double = 9.0
        return min(Double(elapsedSeconds) / totalTime, 1.0)
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

    private func triggerTransitionAnimations(from: Int, to: Int) {
        if fromStage == 1 && toStage == 2 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.4)) {
                isBursting = true
            }

            showStage2Flash = true
            showStage2Shockwave = true
            showLightningBolts = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showStage2Flash = false
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation {
                    isBursting = false
                    showStage2Shockwave = false
                    showLightningBolts = false
                }
            }
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
    }
}
