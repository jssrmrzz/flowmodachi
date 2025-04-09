import SwiftUI

struct FlowmodachiVisualView: View {
    let elapsedSeconds: Int
    let isSleeping: Bool
    let breakSecondsRemaining: Int
    let breakTotalSeconds: Int

    // Evolving stages
    private let stages: [(symbol: String, label: String)] = [
        ("sun.min", "Stage 1"),
        ("sun.min.fill", "Stage 2"),
        ("sun.max", "Stage 3"),
        ("sun.max.fill", "Final Form")
    ]

    @State private var currentStageIndex: Int = 0
    @State private var isPulsing = false

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                if isSleeping {
                    // Pulsing aura during break
                    Circle()
                        .stroke(Color.blue.opacity(0.3), lineWidth: 8)
                        .scaleEffect(isPulsing ? 1.1 : 0.9)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isPulsing)
                } else {
                    // Flow progress ring
                    Circle()
                        .trim(from: 0, to: flowProgress)
                        .stroke(Color.purple, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.4), value: flowProgress)
                }

                // Inner icon (creature or sleep icon)
                Image(systemName: isSleeping ? "moon.stars" : stages[currentStageIndex].symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .foregroundColor(.purple)
                    .transition(.scale.combined(with: .opacity))
                    .id(isSleeping ? "sleep" : stages[currentStageIndex].symbol)

                // If on break, show countdown inside ring
                if isSleeping {
                    Text(formattedBreakTime)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.blue)
                        .offset(y: 36)
                }
            }
            .frame(width: 70, height: 70)

            // Stage label (only during flow)
            if !isSleeping {
                Text(stages[currentStageIndex].label)
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
        .onChange(of: elapsedSeconds) { _ in
            updateStage()
        }
        .onChange(of: isSleeping) { newValue in
            isPulsing = newValue
        }
    }

    // MARK: - Logic

    private var formattedBreakTime: String {
        let minutes = breakSecondsRemaining / 60
        let seconds = breakSecondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var flowProgress: Double {
        let totalTime: Double = 9.0 // Change to 60 * 60 for full evolution
        return min(Double(elapsedSeconds) / totalTime, 1.0)
    }

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

