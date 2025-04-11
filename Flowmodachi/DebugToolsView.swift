import SwiftUI

struct DebugToolsView: View {
    @AppStorage("debugMoodOverride") private var debugMoodOverride: String = "none"
    @AppStorage("debugMissedYesterday") private var debugMissedYesterday: Bool = false
    
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        #if DEBUG
        DisclosureGroup("🧪 Dev Tools") {
            VStack(alignment: .leading, spacing: 10) {
                // Picker to override mood
                Picker("Mood", selection: $debugMoodOverride) {
                    Text("None").tag("none")
                    Text("Sleepy").tag("sleepy")
                    Text("Neutral").tag("neutral")
                    Text("Happy").tag("happy")
                }
                .pickerStyle(.segmented)

                // Toggle missed yesterday debug flag
                Toggle("Missed Yesterday", isOn: $debugMissedYesterday)

                // 🔄 Clear all session data
                Button("Clear All Sessions") {
                    sessionManager.clearAllSessions()
                    print("🗑 Cleared all flow sessions.")
                }
                .foregroundColor(.red)
                .font(.caption)
            }
            .padding(8)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
        }
        .font(.caption)
        .padding(.bottom, 8)
        #endif
    }
}

