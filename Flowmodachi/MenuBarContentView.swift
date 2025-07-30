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
    @State private var showSettings = false
    @AppStorage("showStreaks") private var showStreaks: Bool = true
    @AppStorage("debugMoodOverride") private var debugMoodOverride: String = "none"
    @AppStorage("debugMissedYesterday") private var debugMissedYesterday: Bool = false
    @AppStorage("resumeOnLaunch") private var resumeOnLaunch: Bool = true
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial: Bool = false
    @State private var showConfetti = false
    @State private var hasStartedSession = false
    @StateObject private var tutorialManager = TutorialManager()

    // MARK: - View Body
    var body: some View {
        ZStack {
            if showSettings {
                // Settings Panel
                VStack(spacing: 12) {
                    header
                    
                    ScrollView {
                        SettingsView()
                    }
                    .frame(maxHeight: 320) // Optimized for 420px popover
                }
                .padding()
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                // Main Content
                VStack(spacing: 16) {
                    header
                        .tutorialHighlight(
                            when: tutorialManager.shouldShowTutorial(for: .settings),
                            tutorialManager: tutorialManager,
                            targetArea: .settings
                        )

                    // Tutorial banner (replaces overlay approach)
                    if tutorialManager.isShowingTutorial {
                        TutorialBannerView(tutorialManager: tutorialManager)
                            .animation(.easeInOut(duration: 0.3), value: tutorialManager.currentStep)
                    }

                    // Error handling for inline errors
                    if flowEngine.errorHandler.isShowingError,
                       let error = flowEngine.errorHandler.currentError {
                        InlineErrorView(
                            error: error,
                            onDismiss: {
                                flowEngine.errorHandler.dismissError()
                            },
                            onRetry: error.canRetry ? {
                                switch error {
                                case .timerStartFailed:
                                    flowEngine.startFlowTimer()
                                case .breakTimerFailed:
                                    flowEngine.suggestBreak()
                                default:
                                    break
                                }
                            } : nil
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    if didMissYesterday && !tutorialManager.isShowingTutorial {
                        missedYesterdayBanner
                    }

                    if showStats && !tutorialManager.isShowingTutorial {
                        SessionSummaryView()
                    }

                    DebugToolsView()
                        .environmentObject(sessionManager)
                        .padding(.top, 4)

                    if showStreaks && !tutorialManager.isShowingTutorial {
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
                    .tutorialHighlight(
                        when: tutorialManager.shouldShowTutorial(for: .petArea),
                        tutorialManager: tutorialManager,
                        targetArea: .petArea
                    )

                    SessionControlsView()
                        .environmentObject(flowEngine)
                        .tutorialHighlight(
                            when: tutorialManager.shouldShowTutorial(for: .startButton, isOnBreak: flowEngine.isOnBreak) ||
                                  tutorialManager.shouldShowTutorial(for: .timer, isOnBreak: flowEngine.isOnBreak) ||
                                  tutorialManager.shouldShowTutorial(for: .breakControls, isOnBreak: flowEngine.isOnBreak),
                            tutorialManager: tutorialManager,
                            targetArea: .startButton
                        )

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
                .transition(.move(edge: .leading).combined(with: .opacity))
                .trackSessionLifecycleChanges(using: flowEngine)
                .onChange(of: flowEngine.elapsedSeconds) {
                    if flowEngine.elapsedSeconds == 1 {
                        hasStartedSession = true
                    }
                }
            }
        }
        .frame(width: 280)
        .animation(.easeInOut(duration: 0.4), value: showSettings)
        .onAppear {
            if !hasSeenTutorial && !tutorialManager.isCompleted {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    tutorialManager.startTutorial()
                }
            }
        }
        .onChange(of: tutorialManager.isShowingTutorial) { isShowing in
            if isShowing && showSettings {
                withAnimation {
                    showSettings = false
                }
            }
        }


            if showConfetti {
                ConfettiView()
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(10)
            }
        }

    // MARK: - Subviews

    private var header: some View {
        HStack {
            if showSettings {
                Button(action: { withAnimation { showSettings = false } }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.caption)
                    .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back to main view")
                .accessibilityHint("Returns to the pet and session view")
                
                Spacer()
                
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Invisible spacer for balance
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .font(.caption)
                .opacity(0)
            } else {
                Text("Flowmodachi")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                
                Button(action: { withAnimation { showStats.toggle() } }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(showStats ? "Hide session statistics" : "Show session statistics")
                .accessibilityHint("Toggles display of detailed session information")
                
                Button(action: { withAnimation { showSettings = true } }) {
                    Image(systemName: "gearshape")
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open settings")
                .accessibilityHint("Opens the app settings panel")
                .disabled(tutorialManager.isShowingTutorial)
            }
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
        if debugMissedYesterday { return true }
        #endif
        return !hasStartedSession && sessionManager.missedYesterday()
    }
}
