// MARK: - Imports
import SwiftUI
import AVFoundation

// MARK: - Main View
struct MenuBarContentView: View {
    // MARK: - Timer State
    @State private var isFlowing = false
    @State private var elapsedSeconds = 0
    @State private var timer: Timer?

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
    
    // MARK: - Persistence Keys
        private let persistenceKey = "FlowSessionState"
        private let maxResumeDelay: TimeInterval = 600 // 10 minutes
        @AppStorage("resumeOnLaunch") private var resumeOnLaunch: Bool = true
    
    // MARK: - View Body
    var body: some View {
        VStack(spacing: 16) {
            // Title & Toggle Info
            HStack {
                Text("Flowmodachi")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                Button(action: {
                    withAnimation {
                        showStats.toggle()
                    }
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
            }

            // Missed Yesterday Banner
            if didMissYesterday {
                Text("Flowmodachi missed you yesterday 💤")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                    .transition(.opacity)
            }

            // Stats Panel
            if showStats {
                SessionStatsView(
                    currentStreak: sessionManager.currentStreak,
                    totalSessions: sessionManager.sessions.count,
                    longestStreak: sessionManager.longestStreak
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
                .padding(.bottom, 8)
            }

            // Debug Tools
            DebugToolsView()
                .environmentObject(sessionManager)
                .padding(.top, 4)

            // Optional Streak View
            if showStreaks {
                StreakView(sessions: sessionManager.sessions)
            }

            // Today + Longest
            VStack(spacing: 4) {
                Text("🕒 Today: \(sessionManager.totalMinutesToday()) min")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("🔥 Streak: \(sessionManager.longestStreak) day\(sessionManager.longestStreak == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            // Creature UI
            FlowmodachiVisualView(
                elapsedSeconds: elapsedSeconds,
                isSleeping: isOnBreak,
                breakSecondsRemaining: breakSecondsRemaining,
                breakTotalSeconds: breakTotalDuration,
                mood: flowmodachiMood
            )
            .environmentObject(evolutionTracker)

            // Timer & Controls
            if isOnBreak {
                Button("End Break Early") {
                    endBreak()
                }
                .buttonStyle(.borderedProminent)
            } else {
                Text(formattedTime)
                    .font(.system(.largeTitle, design: .monospaced))
                    .padding(.bottom, 4)

                if isFlowing {
                    Button("Pause") {
                        pauseTimer()
                    }
                    .buttonStyle(.bordered)
                } else {
                    if elapsedSeconds > 0 && breakSecondsRemaining == 0 {
                        Button("End Flow & Take Break") {
                            suggestBreak()
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button(elapsedSeconds > 0 ? "Resume Flow" : "Start Flow") {
                            startTimer()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }

                if elapsedSeconds > 0 && !isFlowing {
                    Button("Reset Flow") {
                        resetTimer()
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
            }
        }
        .padding()
        .onAppear {
            restoreSessionIfAvailable()
        }
        .onChange(of: elapsedSeconds) {
            if elapsedSeconds >= minimumEligibleSeconds && !sessionCountedToday {
                recordSessionIfEligible()
            }
        }
        .frame(width: 280)
    }
    
    // MARK: - Persistence Helpers
        private func saveSessionState() {
            guard isFlowing else { return }
            let state: [String: Double] = [
                "timestamp": Date().timeIntervalSince1970,
                "elapsed": Double(elapsedSeconds)
            ]
            UserDefaults.standard.set(state, forKey: persistenceKey)
        }

        private func restoreSessionIfAvailable() {
            guard let saved = UserDefaults.standard.dictionary(forKey: persistenceKey) as? [String: Double],
                  let timestamp = saved["timestamp"],
                  let savedElapsed = saved["elapsed"],
                  savedElapsed > 0 else {
                return
            }

            let now = Date().timeIntervalSince1970
            if now - timestamp <= maxResumeDelay {
                elapsedSeconds = Int(savedElapsed)
                startTimer()
                print("✅ Resumed session after app launch")
            } else {
                print("⚠️ Saved session too old; not restoring")
                clearSessionState()
            }
        }

        private func clearSessionState() {
            UserDefaults.standard.removeObject(forKey: persistenceKey)
        }

    // MARK: - Time Format
    private var formattedTime: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Timer Logic
    private func startTimer() {
        isFlowing = true
        sessionCountedToday = false
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedSeconds += 1
            saveSessionState()
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
    }

    // MARK: - Break Logic
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

    private func startBreak() {
        isFlowing = false
        isOnBreak = true
        breakTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            breakSecondsRemaining -= 1
            if breakSecondsRemaining <= 0 {
                endBreak()
            }
        }
        print("Break started for \(breakTotalDuration) seconds")
    }

    private func endBreak() {
        breakTimer?.invalidate()
        breakTimer = nil

        let breakTaken = breakTotalDuration - breakSecondsRemaining
        evolutionTracker.addBreakCredit(breakTaken)

        // 🎉 Try evolving the pet!
        petManager.evolveIfEligible()

        isOnBreak = false
        breakSecondsRemaining = 0
        elapsedSeconds = 0
        playBreakEndSound()
        recordSessionIfEligible()
    }

    // MARK: - Record Session
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

    // MARK: - Sound
    private func playBreakEndSound() {
        NSSound(named: "Glass")?.play()
    }

    // MARK: - Mood Logic
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
