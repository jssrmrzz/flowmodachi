import SwiftUI

// MARK: - Mood Enum
enum CreatureMood {
    case happy
    case neutral
    case sleepy
}

// MARK: - Main Visual View
struct FlowmodachiVisualView: View {
    // External state passed into the view
    let elapsedSeconds: Int
    let isSleeping: Bool
    let breakSecondsRemaining: Int
    let breakTotalSeconds: Int
    let mood: CreatureMood

    // MARK: - Evolution Stages
    private let stages: [(symbol: String, label: String)] = [
        ("sun.min", "Stage 1"),
        ("sun.min.fill", "Stage 2"),
        ("sun.max", "Stage 3"),
        ("sun.max.fill", "Final Form")
    ]

    // MARK: - State
    @State private var currentStageIndex: Int = 0
    @State private var isPulsing = false

    // MARK: - Computed Properties

    /// Icon that represents current state based on mood or sleep
    private var currentSymbolName: String {
        if isSleeping {
            return "moon.stars"
        }

        switch mood {
        case .happy: return "sun.max.fill"
        case .neutral: return stages[currentStageIndex].symbol
        case .sleepy: return "cloud.moon"
        }
    }

    /// Label that appears below the creature
    private var moodLabel: String {
        switch mood {
        case .happy: return "Feeling great!"
        case .neutral: return stages[currentStageIndex].label
        case .sleepy: return "A bit sleepy 💤"
        }
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background Ring or Aura
                if isSleeping {
                    // Sleep aura with pulsing animation
                    Circle()
                        .stroke(Color.blue.opacity(0.3), lineWidth: 8)
                        .scaleEffect(isPulsing ? 1.1 : 0.9)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isPulsing)
                } else {
                    // Progress ring showing evolution during flow
                    Circle()
                        .trim(from: 0, to: flowProgress)
                        .stroke(Color.purple, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.4), value: flowProgress)
                }

                // Creature or mood icon
                Image(systemName: currentSymbolName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .foregroundColor(.purple)
                    .transition(.scale.combined(with: .opacity))
                    .id(currentSymbolName)

                // Break timer countdown below icon
                if isSleeping {
                    Text(formattedBreakTime)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.blue)
                        .offset(y: 36)
                }
            }
            .frame(width: 70, height: 70)

            // Label shown only during flow sessions
            if !isSleeping {
                Text(moodLabel)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .animation(.easeInOut(duration: 0.4), value: currentStageIndex)
            }
        }
        .onAppear {
            updateStage()
            if isSleeping {
                isPulsing = true
            }
        }
        .onChange(of: elapsedSeconds) {
            updateStage()
        }
        .onChange(of: isSleeping) {
            isPulsing = isSleeping
        }
    }

    // MARK: - Logic Helpers

    /// Returns the formatted countdown string for break time
    private var formattedBreakTime: String {
        let minutes = breakSecondsRemaining / 60
        let seconds = breakSecondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// Controls how filled the ring is based on focus duration
    private var flowProgress: Double {
        let totalTime: Double = 9.0 // Change to 60 * 60 for full evolution
        return min(Double(elapsedSeconds) / totalTime, 1.0)
    }

    /// Updates which stage of evolution we're currently in
    private func updateStage() {
        let index: Int
        switch elapsedSeconds {
        case 0..<3: index = 0
        case 3..<6: index = 1
        case 6..<9: index = 2
        default: index = 3
        }

        if index != currentStageIndex {
            withAnimation {
                currentStageIndex = index
            }
        }
    }
}

