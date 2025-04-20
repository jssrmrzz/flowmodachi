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
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial: Bool = false
    @State private var showConfetti = false

    // MARK: - View Body
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                header
                
                // MARK: Tutorial Banner
                if !hasSeenTutorial {
                    VStack(spacing: 6) {
                        Text("👋 Welcome to Flowmodachi!")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)

                        Text("Start a focus session to help your egg evolve. Take breaks to grow your Flowmodachi!")
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true) 

                        Button("Got it!") {
                            withAnimation {
                                hasSeenTutorial = true
                            }
                        }
                        .font(.caption2)
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(10)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(10)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }


                if didMissYesterday {
                    missedYesterdayBanner
                }

                if showStats {
                    SessionSummaryView()
                }

                DebugToolsView()
                    .environmentObject(sessionManager)
                    .padding(.top, 4)

                if showStreaks {
                    StreakView(sessions: sessionManager.sessions)
                }

                SessionMetricsView()
                    .environmentObject(sessionManager)

                FlowmodachiVisualView(
                    elapsedSeconds: flowEngine.elapsedSeconds,
                    isOnBreak: flowEngine.isOnBreak,
                    breakSecondsRemaining: flowEngine.breakSecondsRemaining,
                    breakTotalSeconds: flowEngine.breakTotalDuration
                )
                .environmentObject(evolutionTracker)

                SessionControlsView()
                    .environmentObject(flowEngine)

                RebirthButtonView(triggerConfetti: {
                    withAnimation {
                        showConfetti = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                        withAnimation {
                            showConfetti = false
                        }
                    }
                })
                .environmentObject(petManager)
            }
            .padding()
            .trackSessionLifecycleChanges(using: flowEngine)
            .frame(width: 280)

            if showConfetti {
                ConfettiView()
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(10)
            }
        }
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

    // MARK: - State Logic

    private var didMissYesterday: Bool {
        #if DEBUG
        if debugMissedYesterday {
            return true
        }
        #endif
        return sessionManager.missedYesterday()
    }
}
