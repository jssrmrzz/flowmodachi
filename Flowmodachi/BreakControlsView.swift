import SwiftUI
import Foundation

struct BreakControlsView: View {
    @EnvironmentObject var flowEngine: FlowEngine

    var body: some View {
        VStack(spacing: 12) {
            if flowEngine.isOnBreak {
                // MARK: - End Break Button
                Button("End Break Early") {
                    flowEngine.endBreak()
                }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("End break early")
                .accessibilityHint("Ends your break and returns to flow session mode")
                .buttonPressAnimation()

                // MARK: - Break Timer Display
                HStack {
                    Spacer()
                    
                    ZStack {
                        // Pulse animation background
                        PulseAnimationView(color: .blue, scale: 1.1)
                            .frame(width: 120, height: 60)
                            .opacity(0.3)
                        
                        Text(formattedBreakTime)
                            .font(.title.monospacedDigit())
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .accessibilityLabel("Break timer")
                            .accessibilityValue("Time remaining: \(accessibleBreakTimeDescription)")
                            .animation(.easeInOut(duration: 0.3), value: flowEngine.breakSecondsRemaining)
                    }
                    
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
        .padding(.top, 8)
        .animation(.easeInOut(duration: 0.4), value: flowEngine.isOnBreak)
    }

    // MARK: - Timer Formatter
    private var formattedBreakTime: String {
        let minutes = flowEngine.breakSecondsRemaining / 60
        let seconds = flowEngine.breakSecondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var accessibleBreakTimeDescription: String {
        let minutes = flowEngine.breakSecondsRemaining / 60
        let seconds = flowEngine.breakSecondsRemaining % 60
        
        if minutes == 0 {
            return "\(seconds) seconds"
        } else if seconds == 0 {
            return "\(minutes) \(minutes == 1 ? "minute" : "minutes")"
        } else {
            return "\(minutes) \(minutes == 1 ? "minute" : "minutes") and \(seconds) seconds"
        }
    }
}
