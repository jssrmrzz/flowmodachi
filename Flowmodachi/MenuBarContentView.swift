import SwiftUI
import AVFoundation

struct MenuBarContentView: View {
    @State private var isFlowing = false
    @State private var elapsedSeconds = 0
    @State private var timer: Timer?

    @State private var isOnBreak = false
    @State private var breakSecondsRemaining = 0
    @State private var breakTotalDuration = 0
    @State private var breakTimer: Timer?

    var body: some View {
        VStack(spacing: 16) {
            Text("Flowmodachi")
                .font(.title2)
                .fontWeight(.semibold)

            // 🌕 Unified Visual: Evolving creature OR sleeping moon
            FlowmodachiVisualView(
                elapsedSeconds: elapsedSeconds,
                isSleeping: isOnBreak,
                breakSecondsRemaining: breakSecondsRemaining,
                breakTotalSeconds: breakTotalDuration
            )

            if isOnBreak {
                // 💤 Sleep mode – break in progress
                Button("End Break Early") {
                    endBreak()
                }
                .buttonStyle(.borderedProminent)
            } else {
                // 🧠 Flow timer controls
                Text(formattedTime)
                    .font(.system(.largeTitle, design: .monospaced))
                    .padding(.bottom, 4)

                if isFlowing {
                    Button("Pause") {
                        pauseTimer()
                    }
                    .buttonStyle(.bordered)
                } else {
                    if elapsedSeconds > 0 && breakSecondsRemaining == 0 {
                        Button("End Flow & Take Break") {
                            suggestBreak()
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button(elapsedSeconds > 0 ? "Resume Flow" : "Start Flow") {
                            startTimer()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }

                if elapsedSeconds > 0 && !isFlowing {
                    Button("Reset Flow") {
                        resetTimer()
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
            }
        }
        .padding()
        .frame(width: 280)
    }

    private var formattedTime: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Flow Timer Functions

    private func startTimer() {
        isFlowing = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedSeconds += 1
        }
    }

    private func pauseTimer() {
        isFlowing = false
        timer?.invalidate()
        timer = nil
    }

    private func resetTimer() {
        pauseTimer()
        elapsedSeconds = 0
    }

    // MARK: - Break Functions

    private func suggestBreak() {
        let minutes = elapsedSeconds / 60
        let suggestedBreak = minutes >= 120 ? 30 : min(max(Int(Double(minutes) * 0.2), 5), 20)

        breakTotalDuration = suggestedBreak * 60
        breakSecondsRemaining = breakTotalDuration
        startBreak()
    }

    private func startBreak() {
        isFlowing = false
        isOnBreak = true
        breakTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            breakSecondsRemaining -= 1
            if breakSecondsRemaining <= 0 {
                endBreak()
            }
        }
    }

    private func endBreak() {
        breakTimer?.invalidate()
        breakTimer = nil
        isOnBreak = false
        breakSecondsRemaining = 0
        elapsedSeconds = 0
        playBreakEndSound()
    }

    // MARK: - Sound

    private func playBreakEndSound() {
        NSSound(named: "Glass")?.play()
    }
}

