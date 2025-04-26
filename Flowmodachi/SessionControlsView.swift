import SwiftUI

// MARK: - Session Controls View

struct SessionControlsView: View {
    @EnvironmentObject var flowEngine: FlowEngine
    @EnvironmentObject var petManager: PetManager // ✅ Inject PetManager

    @State private var showResetConfirmation = false // ✅ New state for alert

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
                        showResetConfirmation = true // ✅ Trigger confirmation alert
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                    .alert("Reset Flow?", isPresented: $showResetConfirmation) {
                        Button("Reset", role: .destructive) {
                            flowEngine.resetFlowTimer()
                            petManager.resetToStart()
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("Are you sure you want to reset your current flow session and your Flowmodachi? You'll start with a new random egg.")
                    }

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
