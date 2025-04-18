import SwiftUI
import Foundation

struct BreakControlsView: View {
    @EnvironmentObject var flowEngine: FlowEngine


    var body: some View {
        VStack(spacing: 8) {
            if flowEngine.isOnBreak {
                Button("End Break Early") {
                    flowEngine.endBreak()
                }
                .buttonStyle(.borderedProminent)
                Text(formattedBreakTime)
                    .font(.caption)
                    .foregroundColor(.blue)

            }
        }
    }
    
    private var formattedBreakTime: String {
        let minutes = flowEngine.breakSecondsRemaining / 60
        let seconds = flowEngine.breakSecondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

}
