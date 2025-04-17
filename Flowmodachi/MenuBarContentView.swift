// MARK: - Imports
import SwiftUI
import AVFoundation

// MARK: - Main View
struct MenuBarContentView: View {
    // MARK: - Timer State
    @State private var isFlowing = false
    @State private var elapsedSeconds = 0
    @State private var timer: Timer?
    @AppStorage("resumeOnLaunch") private var resumeOnLaunch: Bool = true

    // MARK: - Break Timer State
    @State private var isOnBreak = false
    @State private var breakSecondsRemaining = 0
    @State private var breakTotalDuration = 0
    @State private var breakTimer: Timer?

    // MARK: - Session Tracking
    @State private var sessionCountedToday = false
    @StateObject private var sessionManager = SessionManager()
    @StateObject private var evolutionTracker = EvolutionTracker()
    @AppStorage("showStreaks") private var showStreaks: Bool = true

    // MARK: - External Environment
    @EnvironmentObject var petManager: PetManager

    // MARK: - UI Toggles
    @State private var showStats = false
    @AppStorage("debugMoodOverride") private var debugMoodOverride: String = "none"
    @AppStorage("debugMissedYesterday") private var debugMissedYesterday: Bool = false

    // MARK: - View Body
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Flowmodachi")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: { withAnimation { showStats.toggle() } }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
            }

            if didMissYesterday {
                Text("Flowmodachi missed you yesterday 💤")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                    .transition(.opacity)
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

            VStack(spacing: 4) {
                Text("🕒 Today: \(sessionManager.totalMinutesToday()) min")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("🔥 Streak: \(sessionManager.longestStreak) day\(sessionManager.longestStreak == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            FlowmodachiVisualView(
                elapsedSeconds: elapsedSeconds,
                isSleeping: isOnBreak,
                breakSecondsRemaining: breakSecondsRemaining,
                breakTotalSeconds: breakTotalDuration,
                mood: flowmodachiMood
            )
            .environmentObject(evolutionTracker)

            if isOnBreak {
                Button("End Break Early") { endBreak() }
                    .buttonStyle(.borderedProminent)
            } else {
                Text(formattedTime)
                    .font(.system(.largeTitle, design: .monospaced))
                    .padding(.bottom, 4)

                if isFlowing {
                    Button("Pause") { pauseTimer() }
                        .buttonStyle(.bordered)
                } else {
                    if elapsedSeconds > 0 && breakSecondsRemaining == 0 {
                        Button("End Flow & Take Break") { suggestBreak() }
                            .buttonStyle(.borderedProminent)
                    } else {
                        Button(elapsedSeconds > 0 ? "Resume Flow" : "Start Flow") { startTimer() }
                            .buttonStyle(.borderedProminent)
                    }
                }

                if elapsedSeconds > 0 && !isFlowing {
                    Button("Reset Flow") { resetTimer() }
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .onAppear {
            if resumeOnLaunch, let restored = SessionPersistenceHelper.restoreSession() {
                elapsedSeconds = restored
                startTimer()
            }

            if let restoredBreak = BreakPersistenceHelper.restoreBreak() {
                breakTotalDuration = restoredBreak.total
                breakSecondsRemaining = restoredBreak.remaining
                startBreak(resume: true)
            }
        }
        .onChange(of: elapsedSeconds) {
            if elapsedSeconds >= minimumEligibleSeconds && !sessionCountedToday {
                recordSessionIfEligible()
            }
        }
        .onChange(of: isFlowing) { _, newValue in
            if newValue {
                SessionPersistenceHelper.saveSession(elapsedSeconds: elapsedSeconds)
            } else {
                SessionPersistenceHelper.clearSession()
            }
        }
        .onChange(of: isOnBreak) { _, newValue in
            if newValue {
                BreakPersistenceHelper.saveBreak(remaining: breakSecondsRemaining, total: breakTotalDuration)
            } else {
                BreakPersistenceHelper.clearBreak()
            }
        }
        .frame(width: 280)
    }

    private var formattedTime: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func startTimer() {
        isFlowing = true
        sessionCountedToday = false
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedSeconds += 1
        }
    }

    private func pauseTimer() {
        isFlowing = false
        timer?.invalidate()
        timer = nil
    }

    private func resetTimer() {
        recordSessionIfEligible()
        pauseTimer()
        elapsedSeconds = 0
        sessionCountedToday = false
        SessionPersistenceHelper.clearSession()
    }

    private func suggestBreak() {
        #if DEBUG
        let suggestedBreak = 0.25
        #else
        let minutes = elapsedSeconds / 60
        let suggestedBreak = minutes >= 120 ? 30 : min(max(Int(Double(minutes) * 0.2), 5), 20)
        #endif

        breakTotalDuration = Int(suggestedBreak * 60)
        breakSecondsRemaining = breakTotalDuration
        startBreak()
    }

    private func startBreak(resume: Bool = false) {
        isFlowing = false
        isOnBreak = true

        breakTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            breakSecondsRemaining -= 1
            BreakPersistenceHelper.saveBreak(remaining: breakSecondsRemaining, total: breakTotalDuration)

            if breakSecondsRemaining <= 0 {
                endBreak()
            }
        }

        if !resume {
            print("Break started for \(breakTotalDuration) seconds")
        }
    }


    private func endBreak() {
        breakTimer?.invalidate()
        breakTimer = nil

        let breakTaken = breakTotalDuration - breakSecondsRemaining
        evolutionTracker.addBreakCredit(breakTaken)

        petManager.evolveIfEligible()

        isOnBreak = false
        breakSecondsRemaining = 0
        elapsedSeconds = 0
        playBreakEndSound()
        recordSessionIfEligible()
        BreakPersistenceHelper.clearBreak()

    }

    private func recordSessionIfEligible() {
        let today = Calendar.current.startOfDay(for: Date())
        let alreadyRecorded = sessionManager.sessions.contains {
            Calendar.current.isDate($0.startDate, inSameDayAs: today)
        }

        if elapsedSeconds >= minimumEligibleSeconds && !alreadyRecorded {
            sessionManager.addSession(duration: elapsedSeconds)
            sessionCountedToday = true
            print("✅ Session recorded at \(elapsedSeconds) seconds")
        }
    }

    private var minimumEligibleSeconds: Int {
        #if DEBUG
        return 5
        #else
        return 60 * 5
        #endif
    }

    private func playBreakEndSound() {
        NSSound(named: "Glass")?.play()
    }

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
