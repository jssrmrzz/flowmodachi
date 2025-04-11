import SwiftUI
import AVFoundation

struct MenuBarContentView: View {
    @State private var isFlowing = false
    @State private var elapsedSeconds = 0
    @State private var timer: Timer?

    @State private var isOnBreak = false
    @State private var breakSecondsRemaining = 0
    @State private var breakTotalDuration = 0
    @State private var breakTimer: Timer?

    @StateObject private var sessionManager = SessionManager()
    @AppStorage("showStreaks") private var showStreaks: Bool = true

    @State private var showStats = false
    
    @AppStorage("debugMoodOverride") private var debugMoodOverride: String = "none"
    @AppStorage("debugMissedYesterday") private var debugMissedYesterday: Bool = false


    var body: some View {
        VStack(spacing: 16) {
            // App title + info button aligned in one row
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

            if didMissYesterday {
                Text("Flowmodachi missed you yesterday 💤")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                    .transition(.opacity)
            }

            // Session stats view (optional)
            if showStats {
                SessionStatsView(
                    currentStreak: currentStreak,
                    totalSessions: totalSessions,
                    longestStreak: longestStreak
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
                .padding(.bottom, 8)
            }

            DebugToolsView()
                .padding(.top, 4)

            // Streak View toggleable by settings
            if showStreaks {
                StreakView(sessions: sessionManager.sessions)
            }

            // Quick overview (Today + Longest streak)
            VStack(spacing: 4) {
                Text("🕒 Today: \(sessionManager.totalMinutesToday()) min")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("🔥 Streak: \(sessionManager.longestStreak()) day\(sessionManager.longestStreak() == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            // Creature / moon visual
            FlowmodachiVisualView(
                elapsedSeconds: elapsedSeconds,
                isSleeping: isOnBreak,
                breakSecondsRemaining: breakSecondsRemaining,
                breakTotalSeconds: breakTotalDuration,
                mood: flowmodachiMood
            )

            if isOnBreak {
                Button("End Break Early") {
                    endBreak()
                }
                .buttonStyle(.borderedProminent)
            } else {
                // Flow timer & controls
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
        .frame(width: 280)
    }

    private var formattedTime: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Flow Timer Functions

    private func startTimer() {
        isFlowing = true
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
    }

    // MARK: - Break Functions

    private func suggestBreak() {
        #if DEBUG
        let suggestedBreak = 0.25 // 15 seconds in debug mode (0.25 min)
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
        isOnBreak = false
        breakSecondsRemaining = 0
        elapsedSeconds = 0
        playBreakEndSound()
        recordSessionIfEligible()
    }
    
    // MARK: Record Session Function
    private func recordSessionIfEligible() {
        let minimumDuration: Int = {
            #if DEBUG
            return 5
            #else
            return 60 * 5
            #endif
        }()

        // Don't double-record a session for the same day
        let today = Calendar.current.startOfDay(for: Date())
        let alreadyRecorded = sessionManager.sessions.contains {
            Calendar.current.isDate($0.startDate, inSameDayAs: today)
        }

        if elapsedSeconds >= minimumDuration && !alreadyRecorded {
            sessionManager.addSession(duration: elapsedSeconds)
            print("✅ Session recorded for today")
        }
    }


    // MARK: - Sound

    private func playBreakEndSound() {
        NSSound(named: "Glass")?.play()
    }

    var totalSessions: Int {
        sessionManager.sessions.count
    }

    var currentStreak: Int {
        sessionManager.currentStreak()
    }

    var longestStreak: Int {
        sessionManager.longestStreak()
    }

    /// Debug-aware check for whether the user missed a session yesterday
    private var didMissYesterday: Bool {
        #if DEBUG
        if UserDefaults.standard.bool(forKey: "debugMissedYesterday") {
            return true
        }
        #endif
        return sessionManager.missedYesterday()
    }

    var flowmodachiMood: CreatureMood {
        #if DEBUG
        let override = UserDefaults.standard.string(forKey: "debugMoodOverride") ?? "none"
        switch override {
        case "sleepy": return .sleepy
        case "happy": return .happy
        case "neutral": return .neutral
        default: break
        }
        #endif

        if didMissYesterday {
            return .sleepy
        } else if currentStreak >= 7 {
            return .happy
        } else {
            return .neutral
        }
    }
}

