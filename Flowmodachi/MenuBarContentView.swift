import SwiftUI
import AVFoundation

struct MenuBarContentView: View {
    // MARK: - State & Environment
    @EnvironmentObject var flowEngine: FlowEngine
    @EnvironmentObject var petManager: PetManager
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var evolutionTracker: EvolutionTracker

    // MARK: - UI State
    @State private var showStats = false
    @AppStorage("showStreaks") private var showStreaks: Bool = true
    @AppStorage("debugMoodOverride") private var debugMoodOverride: String = "none"
    @AppStorage("debugMissedYesterday") private var debugMissedYesterday: Bool = false
    @AppStorage("resumeOnLaunch") private var resumeOnLaunch: Bool = true

    var body: some View {
        VStack(spacing: 16) {
            header
            if didMissYesterday { missedBanner }
            if showStats { statsPanel }
            DebugToolsView()
                .environmentObject(sessionManager)
                .padding(.top, 4)
            if showStreaks { StreakView(sessions: sessionManager.sessions) }
            todaySummary
            FlowmodachiVisualView(
                elapsedSeconds: flowEngine.elapsedSeconds,
                isSleeping: flowEngine.isOnBreak,
                breakSecondsRemaining: flowEngine.breakSecondsRemaining,
                breakTotalSeconds: flowEngine.breakTotalDuration,
                mood: flowmodachiMood
            )
            .environmentObject(evolutionTracker)
            timerControls
        }
        .padding()
        .onAppear {
            if resumeOnLaunch {
                flowEngine.restoreSessionIfAvailable()
            }
        }
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

    private var missedBanner: some View {
        Text("Flowmodachi missed you yesterday 💤")
            .font(.caption)
            .foregroundColor(.orange)
            .padding(8)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
            .transition(.opacity)
    }

    private var statsPanel: some View {
        SessionStatsView(
            currentStreak: sessionManager.currentStreak,
            totalSessions: sessionManager.sessions.count,
            longestStreak: sessionManager.longestStreak
        )
        .transition(.opacity.combined(with: .move(edge: .top)))
        .padding(.bottom, 8)
    }

    private var todaySummary: some View {
        VStack(spacing: 4) {
            Text("🕒 Today: \(sessionManager.totalMinutesToday()) min")
                .font(.caption)
                .foregroundColor(.gray)
            Text("🔥 Streak: \(sessionManager.longestStreak) day\(sessionManager.longestStreak == 1 ? "" : "s")")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    private var timerControls: some View {
        Group {
            if flowEngine.isOnBreak {
                Button("End Break Early") {
                    flowEngine.endBreak()
                }
                .buttonStyle(.borderedProminent)
            } else {
                Text(formattedTime)
                    .font(.system(.largeTitle, design: .monospaced))
                    .padding(.bottom, 4)

                if flowEngine.isFlowing {
                    Button("Pause") {
                        flowEngine.pauseFlowTimer()
                    }
                    .buttonStyle(.bordered)
                } else {
                    if flowEngine.elapsedSeconds > 0 && flowEngine.breakSecondsRemaining == 0 {
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

    // MARK: - Helpers

    private var formattedTime: String {
        let minutes = flowEngine.elapsedSeconds / 60
        let seconds = flowEngine.elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var didMissYesterday: Bool {
        #if DEBUG
        if debugMissedYesterday { return true }
        #endif
        return sessionManager.missedYesterday()
    }

    private var flowmodachiMood: CreatureMood {
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
