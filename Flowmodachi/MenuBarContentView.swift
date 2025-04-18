import SwiftUI
import AVFoundation

// MARK: - Main View

struct MenuBarContentView: View {
    // MARK: - Flow Engine
    @EnvironmentObject var flowEngine: FlowEngine

    // MARK: - External Environment
    @EnvironmentObject var petManager: PetManager
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var evolutionTracker: EvolutionTracker

    // MARK: - UI Toggles
    @State private var showStats = false
    @AppStorage("showStreaks") private var showStreaks: Bool = true
    @AppStorage("debugMoodOverride") private var debugMoodOverride: String = "none"
    @AppStorage("debugMissedYesterday") private var debugMissedYesterday: Bool = false
    @AppStorage("resumeOnLaunch") private var resumeOnLaunch: Bool = true

    // MARK: - View Body
    var body: some View {
        VStack(spacing: 16) {
            header

            if didMissYesterday {
                missedYesterdayBanner
            }

            if showStats {
                SessionStatsView(
                    currentStreak: sessionManager.currentStreak,
                    totalSessions: sessionManager.sessions.count,
                    longestStreak: sessionManager.longestStreak
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
                .padding(.bottom, 8)
            }

            DebugToolsView()
                .environmentObject(sessionManager)
                .padding(.top, 4)

            if showStreaks {
                StreakView(sessions: sessionManager.sessions)
            }

            sessionMetrics

            FlowmodachiVisualView(
                elapsedSeconds: flowEngine.elapsedSeconds,
                isSleeping: flowEngine.isOnBreak,
                breakSecondsRemaining: flowEngine.breakSecondsRemaining,
                breakTotalSeconds: flowEngine.breakTotalDuration,
                mood: flowmodachiMood
            )
            .environmentObject(evolutionTracker)

            // Plug in session control logic
            SessionControlsView()
                .environmentObject(flowEngine)
        }
        .padding()
        .onChange(of: flowEngine.elapsedSeconds) {
            flowEngine.recordSessionIfEligible()
        }
        .onChange(of: flowEngine.isFlowing) { _, newValue in
            flowEngine.handleFlowPersistence(isFlowing: newValue)
        }
        .onChange(of: flowEngine.isOnBreak) { _, newValue in
            flowEngine.handleBreakPersistence(isOnBreak: newValue)
        }
        .frame(width: 280)
    }

    // MARK: - Subviews

    private var header: some View {
        HStack {
            Text("Flowmodachi")
                .font(.title2)
                .fontWeight(.semibold)
            Spacer()
            Button(action: { withAnimation { showStats.toggle() } }) {
                Image(systemName: "info.circle")
                    .foregroundColor(.gray)
            }
            .buttonStyle(.plain)
        }
    }

    private var missedYesterdayBanner: some View {
        Text("Flowmodachi missed you yesterday 💤")
            .font(.caption)
            .foregroundColor(.orange)
            .padding(8)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
            .transition(.opacity)
    }

    private var sessionMetrics: some View {
        VStack(spacing: 4) {
            Text("🕒 Today: \(sessionManager.totalMinutesToday()) min")
                .font(.caption)
                .foregroundColor(.gray)
            Text("🔥 Streak: \(sessionManager.longestStreak) day\(sessionManager.longestStreak == 1 ? "" : "s")")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    // MARK: - State Logic

    private var didMissYesterday: Bool {
        #if DEBUG
        if debugMissedYesterday {
            return true
        }
        #endif
        return sessionManager.missedYesterday()
    }

    var flowmodachiMood: CreatureMood {
        #if DEBUG
        switch debugMoodOverride {
        case "sleepy": return .sleepy
        case "happy": return .happy
        case "neutral": return .neutral
        default: break
        }
        #endif
        return sessionManager.calculateMood(debugMissedYesterday: didMissYesterday)
    }
}
