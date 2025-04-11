import SwiftUI

struct DebugToolsView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @AppStorage("debugMoodOverride") private var debugMoodOverride: String = "none"
    @AppStorage("debugMissedYesterday") private var debugMissedYesterday: Bool = false
    @AppStorage("debugDemoMode") private var debugDemoMode: Bool = false

    var body: some View {
        #if DEBUG
        DisclosureGroup("🧪 Dev Tools") {
            VStack(alignment: .leading, spacing: 10) {
                Picker("Mood", selection: $debugMoodOverride) {
                    Text("None").tag("none")
                    Text("Sleepy").tag("sleepy")
                    Text("Neutral").tag("neutral")
                    Text("Happy").tag("happy")
                }
                .pickerStyle(.segmented)

                Toggle("Missed Yesterday", isOn: $debugMissedYesterday)

                Toggle("Demo Mode", isOn: Binding(
                    get: { debugDemoMode },
                    set: { newValue in
                        debugDemoMode = newValue
                        if newValue {
                            seedDemoData()
                        } else {
                            sessionManager.clearAllSessions()
                        }
                    }
                ))

                Button("Reset Sessions") {
                    sessionManager.clearAllSessions()
                }
                .foregroundColor(.red)
            }
            .padding(8)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
        }
        .font(.caption)
        .padding(.bottom, 8)
        #endif
    }

    /// Seeds one session per day for the past 7 days
    private func seedDemoData() {
        let calendar = Calendar.current
        let now = Date()
        let seeded: [FlowSession] = (0..<7).map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: now)!
            return FlowSession(id: UUID(), startDate: day, duration: 60 * 25)
        }

        sessionManager.replaceSessions(with: seeded)
    }
}

