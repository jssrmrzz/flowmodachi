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
    @AppStorage("debugEvolutionStage") private var debugOverrideStage: Int = -1

    private var displayedStage: Int {
        debugOverrideStage >= 0 ? debugOverrideStage : evolutionTracker.currentStage
    }

    // MARK: - Inputs
    let elapsedSeconds: Int
    let isSleeping: Bool
    let breakSecondsRemaining: Int
    let breakTotalSeconds: Int
    let mood: CreatureMood

    // MARK: - Evolution Stages (fallback SF Symbols)
    private let stages: [(symbol: String, label: String)] = [
        ("sun.min", "Stage 1"),
        ("sun.min.fill", "Stage 2"),
        ("sun.max", "Stage 3"),
        ("sun.max.fill", "Final Form")
    ]

    // MARK: - Local State
    @State private var isPulsing = false
    @State private var wobble = false
    @AppStorage("debugEvolutionStage") private var debugEvolutionStage: Int = -1

    // MARK: - Body
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                backgroundRing

                Image("flow_stage\(displayedStage + 1)")
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .rotationEffect(.degrees(displayedStage == 0 && wobble ? 4 : 0), anchor: .center)
                    .animation(.easeInOut(duration: 0.4), value: wobble)
                    .transition(.scale.combined(with: .opacity))
                    .id(displayedStage)

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
            if debugEvolutionStage >= 0 {
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
        .onChange(of: displayedStage) { _, _ in
            startStageAnimationLoop()
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
        let totalTime: Double = 9.0 // For testing/demo
        return min(Double(elapsedSeconds) / totalTime, 1.0)
    }

    private var moodLabel: String {
        switch mood {
        case .happy:
            return "Feeling great!"
        case .neutral:
            return stages[safe: evolutionTracker.currentStage]?.label ?? "Stage 1"
        case .sleepy:
            return "A bit sleepy 💤"
        }
    }

    private func startStageAnimationLoop() {
        guard displayedStage == 0 else { return }

        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation {
                wobble.toggle()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation {
                    wobble.toggle()
                }
            }
        }
    }
}

// MARK: - Safe Array Indexing Extension

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

