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

                // MARK: - Break Timer Display
                HStack {
                    Spacer()
                    Text(formattedBreakTime)
                        .font(.title.monospacedDigit())
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Timer Formatter
    private var formattedBreakTime: String {
        let minutes = flowEngine.breakSecondsRemaining / 60
        let seconds = flowEngine.breakSecondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
