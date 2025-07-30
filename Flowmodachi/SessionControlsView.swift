import SwiftUI

// MARK: - Session Controls View

struct SessionControlsView: View {
    @EnvironmentObject var flowEngine: FlowEngine
    @EnvironmentObject var petManager: PetManager // ✅ Inject PetManager

    @State private var showResetConfirmation = false // ✅ New state for alert
    @State private var showSuccessFeedback = false

    // MARK: - View Body

    var body: some View {
        VStack(spacing: 8) {
            if flowEngine.isOnBreak {
                // Show break-related controls (timer + end button)
                BreakControlsView()
                    .environmentObject(flowEngine)
                    .transition(EnhancedTransitions.slideAndFade)
            } else {
                // Main flow session controls
                VStack(spacing: 8) {
                    Text(formattedTime)
                        .font(.system(.largeTitle, design: .monospaced))
                        .padding(.bottom, 4)
                        .accessibilityLabel("Flow session timer")
                        .accessibilityValue("Time elapsed: \(accessibleTimeDescription)")
                        .animation(.easeInOut(duration: 0.3), value: flowEngine.elapsedSeconds)

                    flowActionButton()
                        .buttonPressAnimation()

                    // Show reset option only when paused with progress
                    if flowEngine.elapsedSeconds > 0 && !flowEngine.isFlowing {
                        Button("Reset Flow") {
                            showResetConfirmation = true // ✅ Trigger confirmation alert
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                        .accessibilityLabel("Reset flow session")
                        .accessibilityHint("Resets your current progress and starts with a new egg")
                        .buttonPressAnimation()
                        .transition(EnhancedTransitions.slideUp)
                        .alert("Reset Flow?", isPresented: $showResetConfirmation) {
                            Button("Reset", role: .destructive) {
                                withAnimation {
                                    flowEngine.resetFlowTimer()
                                    petManager.resetToStart()
                                    showSuccessFeedback = true
                                    
                                    // Hide success feedback after a reasonable time
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        showSuccessFeedback = false
                                    }
                                }
                            }
                            Button("Cancel", role: .cancel) { }
                        } message: {
                            Text("Are you sure you want to reset your current flow session and your Flowmodachi? You'll start with a new random egg.")
                        }
                    }
                }
                .transition(EnhancedTransitions.slideAndFade)
            }
            
            // Success feedback
            if showSuccessFeedback {
                SuccessFeedbackView(message: "Session reset successfully!")
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showSuccessFeedback = false
                        }
                    }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: flowEngine.isOnBreak)
    }

    // MARK: - Flow Action Button

    @ViewBuilder
    private func flowActionButton() -> some View {
        if flowEngine.isFlowing {
            Button("Pause") {
                flowEngine.pauseFlowTimer()
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Pause flow session")
            .accessibilityHint("Pauses your current focus session")
            .buttonPressAnimation()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                    .scaleEffect(1.05)
                    .opacity(0.6)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: flowEngine.isFlowing)
            )
        } else if flowEngine.elapsedSeconds > 0 && flowEngine.breakSecondsRemaining == 0 {
            Button("End Flow & Take Break") {
                flowEngine.suggestBreak()
            }
            .buttonStyle(.borderedProminent)
            .accessibilityLabel("End flow session and take break")
            .accessibilityHint("Completes your focus session and starts a break to help your pet evolve")
            .buttonPressAnimation()
        } else {
            Button(flowEngine.elapsedSeconds > 0 ? "Resume Flow" : "Start Flow") {
                flowEngine.startFlowTimer()
            }
            .buttonStyle(.borderedProminent)
            .accessibilityLabel(flowEngine.elapsedSeconds > 0 ? "Resume flow session" : "Start new flow session")
            .accessibilityHint(flowEngine.elapsedSeconds > 0 ? "Continues your paused focus session" : "Begins a new focus session to help your pet grow")
            .buttonPressAnimation()
            .shimmer()
        }
    }

    // MARK: - Helpers

    private var formattedTime: String {
        let minutes = flowEngine.elapsedSeconds / 60
        let seconds = flowEngine.elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var accessibleTimeDescription: String {
        let minutes = flowEngine.elapsedSeconds / 60
        let seconds = flowEngine.elapsedSeconds % 60
        
        if minutes == 0 {
            return "\(seconds) seconds"
        } else if seconds == 0 {
            return "\(minutes) \(minutes == 1 ? "minute" : "minutes")"
        } else {
            return "\(minutes) \(minutes == 1 ? "minute" : "minutes") and \(seconds) seconds"
        }
    }
}
