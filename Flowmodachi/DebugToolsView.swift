import SwiftUI

struct DebugToolsView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var petManager: PetManager  // 🧬 For evolution testing

    // MARK: - Debug Flags (persisted)
    @AppStorage("debugMoodOverride") private var debugMoodOverride: String = "none"
    @AppStorage("debugMissedYesterday") private var debugMissedYesterday: Bool = false
    @AppStorage("debugDemoMode") private var debugDemoMode: Bool = false
    @AppStorage("debugEvolutionStage") private var debugEvolutionStage: Int = -1 // -1 = auto
    @AppStorage("resumeOnLaunch") private var resumeOnLaunch: Bool = true

    var body: some View {
        #if DEBUG
        DisclosureGroup("🧪 Dev Tools") {
            VStack(alignment: .leading, spacing: 14) {

                // MARK: - Mood Override
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mood Override")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Picker("Mood", selection: $debugMoodOverride) {
                        Text("None").tag("none")
                        Text("Sleepy").tag("sleepy")
                        Text("Neutral").tag("neutral")
                        Text("Happy").tag("happy")
                    }
                    .pickerStyle(.segmented)
                }

                // MARK: - Evolution Stage Override
                VStack(alignment: .leading, spacing: 4) {
                    Text("Evolution Stage Override")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Picker("Stage", selection: $debugEvolutionStage) {
                        Text("Auto").tag(-1)
                        Text("Stage 1").tag(0)
                        Text("Stage 2").tag(1)
                        Text("Stage 3").tag(2)
                        Text("Final").tag(3)
                    }
                    .pickerStyle(.segmented)
                }

                // MARK: - Evolution Actions
                VStack(alignment: .leading, spacing: 6) {
                    Button("🐣 Force Evolution") {
                        petManager.evolveIfEligible()
                        // print("Evolved to: \(petManager.currentCharacter.id)")
                    }
                    .font(.caption)
                    .foregroundColor(.blue)

                    Button("🔄 Reset Pet to Random Egg") {
                        petManager.resetToStart()
                        // print("Reset to: \(petManager.currentCharacter.id)")
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }

                Divider().padding(.vertical, 4)

                // MARK: - Session & Demo Controls
                Toggle("Simulate Missed Yesterday", isOn: $debugMissedYesterday)

                Toggle("Demo Mode (7-day streak)", isOn: Binding(
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
                
                Toggle("Resume Flow After Quit (10 min window)", isOn: $resumeOnLaunch)
                    .font(.caption2)

                
                Button("🧹 Reset Sessions") {
                    sessionManager.clearAllSessions()
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

    // MARK: - Demo Data Seeder

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

