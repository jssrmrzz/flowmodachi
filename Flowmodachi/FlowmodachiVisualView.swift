import SwiftUI

// MARK: - Mood Enum
enum CreatureMood {
    case happy
    case neutral
    case sleepy
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

    // MARK: - Body
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                backgroundRing

                Image(petManager.currentCharacter.imageName)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .rotationEffect(.degrees(isEggWobbleActive ? 4 : 0))
                    .animation(.easeInOut(duration: 0.4), value: wobble)
                    .transition(.scale.combined(with: .opacity))
                    .id(petManager.currentCharacter.id)

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
        }
        .onChange(of: isSleeping) { _, newValue in
            isPulsing = newValue
        }
        .onChange(of: petManager.currentCharacter.id) { _, _ in
            startStageAnimationLoop()
        }
    }

    // MARK: - Animation Logic

    private var isEggWobbleActive: Bool {
        petManager.currentCharacter.stage == 0 && wobble
    }

    private func startStageAnimationLoop() {
        guard petManager.currentCharacter.stage == 0 else { return }
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation { wobble = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation { wobble = false }
            }
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
