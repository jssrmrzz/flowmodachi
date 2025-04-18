import SwiftUI

// MARK: - Session Controls View

struct SessionControlsView: View {
    @EnvironmentObject var flowEngine: FlowEngine

    // MARK: - View Body

    var body: some View {
        VStack(spacing: 8) {
            if flowEngine.isOnBreak {
                // Show break-related controls (timer + end button)
                BreakControlsView()
                    .environmentObject(flowEngine)
            } else {
                // Main flow session controls
                Text(formattedTime)
                    .font(.system(.largeTitle, design: .monospaced))
                    .padding(.bottom, 4)

                flowActionButton()

                // Show reset option only when paused with progress
                if flowEngine.elapsedSeconds > 0 && !flowEngine.isFlowing {
                    Button("Reset Flow") {
                        flowEngine.resetFlowTimer()
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
            }
        }
    }

    // MARK: - Flow Action Button

    @ViewBuilder
    private func flowActionButton() -> some View {
        if flowEngine.isFlowing {
            Button("Pause") {
                flowEngine.pauseFlowTimer()
            }
            .buttonStyle(.bordered)
        } else if flowEngine.elapsedSeconds > 0 && flowEngine.breakSecondsRemaining == 0 {
            Button("End Flow & Take Break") {
                flowEngine.suggestBreak()
            }
            .buttonStyle(.borderedProminent)
        } else {
            Button(flowEngine.elapsedSeconds > 0 ? "Resume Flow" : "Start Flow") {
                flowEngine.startFlowTimer()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    // MARK: - Helpers

    private var formattedTime: String {
        let minutes = flowEngine.elapsedSeconds / 60
        let seconds = flowEngine.elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
