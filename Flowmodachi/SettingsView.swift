import SwiftUI

struct SettingsView: View {
    
    // MARK: - AppStorage Bindings
    @AppStorage("showStreaks") private var showStreaks: Bool = true
    @AppStorage("playSounds") private var playSounds: Bool = true
    @AppStorage("sessionGoal") private var sessionGoal: Int = 25 // in minutes
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial: Bool = true
    @AppStorage("isTestingMode") private var isTestingMode: Bool = false
    @AppStorage("resumeOnLaunch") private var resumeOnLaunch: Bool = true
    @AppStorage("breakMultiplier") private var breakMultiplier: Double = 0.2
    @AppStorage("minBreakMinutes") private var minBreakMinutes: Int = 5
    @AppStorage("maxBreakMinutes") private var maxBreakMinutes: Int = 20
    
    // MARK: - Validation Helpers
    private func validatedSessionGoal(_ value: Int) -> Int {
        max(15, min(value, 120)) // 15-120 minutes
    }
    
    private func validatedBreakMultiplier(_ value: Double) -> Double {
        max(0.1, min(value, 0.5)) // 10%-50%
    }
    
    private func validatedMinBreak(_ value: Int) -> Int {
        max(1, min(value, 30)) // 1-30 minutes
    }
    
    private func validatedMaxBreak(_ value: Int, minValue: Int) -> Int {
        max(minValue, min(value, 60)) // At least minBreak, max 60
    }
    
    @State private var showEmailFallback = false
    @State private var copied = false
    let fallbackEmail = "your.email@example.com"


    // MARK: - Constants
    private let sessionGoalOptions = [15, 25, 45, 60]
    private let breakMultiplierOptions = [0.1, 0.15, 0.2, 0.25, 0.3]
    private let minBreakOptions = [2, 5, 10, 15]
    private let maxBreakOptions = [15, 20, 25, 30]

    // MARK: - View
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // MARK: - Toggles
            Toggle("Show Streaks", isOn: $showStreaks)
            Toggle("Enable Sounds", isOn: $playSounds)
            Toggle("Resume Session on Launch", isOn: $resumeOnLaunch)
            Toggle("Testing Mode (Short Timers)", isOn: $isTestingMode)
            
            // MARK: - Reset Tutorial Button
                        Button("Show Tutorial Again") {
                            hasSeenTutorial = false
                        }
                        .font(.caption)
            
            // MARK: - Feedback Button
            Button("Send Feedback") {
                sendFeedbackEmail {
                    showEmailFallback = true
                }
            }
            .font(.caption)

            // Optional fallback alert or inline message
            if showEmailFallback {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Couldn't open your email client.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack {
                        Text("📧 \(fallbackEmail)")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .onTapGesture {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(fallbackEmail, forType: .string)
                                copied = true
                            }

                        if copied {
                            Text("✓ Copied")
                                .font(.caption2)
                                .foregroundColor(.green)
                                .transition(.opacity)
                        }
                    }
                }
                .padding(.top, 4)
            }

            
            // MARK: - Session Goal Picker
            VStack(alignment: .leading, spacing: 4) {
                Text("Session Goal")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Picker("Session Goal", selection: $sessionGoal) {
                    ForEach(sessionGoalOptions, id: \.self) { value in
                        Text("\(value) min").tag(value)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // MARK: - Break Duration Settings
            VStack(alignment: .leading, spacing: 8) {
                Text("Break Duration Settings")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Break Multiplier")
                        .font(.caption2)
                    Picker("Break Multiplier", selection: $breakMultiplier) {
                        ForEach(breakMultiplierOptions, id: \.self) { value in
                            Text("\(Int(value * 100))%").tag(value)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Min Break")
                            .font(.caption2)
                        Picker("Min Break", selection: $minBreakMinutes) {
                            ForEach(minBreakOptions, id: \.self) { value in
                                Text("\(value)m").tag(value)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Max Break")
                            .font(.caption2)
                        Picker("Max Break", selection: $maxBreakMinutes) {
                            ForEach(maxBreakOptions, id: \.self) { value in
                                Text("\(value)m").tag(value)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }

            // MARK: - Reset Button
            Divider()

            Button(role: .destructive) {
                resetToDefaults()
            } label: {
                Label("Reset App to Defaults", systemImage: "arrow.counterclockwise")
            }
            .font(.caption)
        }
        .padding(12)
    }

    // MARK: - Reset Logic
    private func resetToDefaults() {
        // Clear all app data
        UserDefaults.standard.removeObject(forKey: "FlowmodachiSessions")
        UserDefaults.standard.removeObject(forKey: "FlowSessionState")
        UserDefaults.standard.removeObject(forKey: "FlowBreakState")
        UserDefaults.standard.removeObject(forKey: "currentCharacterID")
        UserDefaults.standard.removeObject(forKey: "evolutionBreakCredits")
        
        // Reset settings to defaults using UserDefaults directly
        UserDefaults.standard.set(true, forKey: "showStreaks")
        UserDefaults.standard.set(true, forKey: "playSounds") 
        UserDefaults.standard.set(25, forKey: "sessionGoal")
        UserDefaults.standard.set(false, forKey: "hasSeenTutorial")
        UserDefaults.standard.set(false, forKey: "isTestingMode")
        UserDefaults.standard.set(true, forKey: "resumeOnLaunch")
        UserDefaults.standard.set(0.2, forKey: "breakMultiplier")
        UserDefaults.standard.set(5, forKey: "minBreakMinutes")
        UserDefaults.standard.set(20, forKey: "maxBreakMinutes")
        
        // Force synchronization
        UserDefaults.standard.synchronize()
        
        print("✅ Settings reset to defaults")
    }
    
    // MARK: - Feedback Logic
    private func sendFeedbackEmail(fallbackHandler: @escaping () -> Void) {
        let email = "888.wav.888@gmail.com"
        let subject = "Flowmodachi Feedback"
        let body = """
        Hi there,

        Thanks so much for giving Flowmodachi a try! I’d love to hear your thoughts to help shape where this app goes next.

        If you're up for it, here are a few questions to guide your feedback (feel free to answer as many or as few as you'd like):

        
        • Was it easy to figure out how to start a focus session?

        • What worked or felt confusing?

        • What would make this app more useful or fun for you?
        
        • Bug reports or anything broken?
        
        • Any other thoughts, feedback, or random ideas?

        Thanks again for trying out Flowmodachi! 🌱

        – Jess
        """


        let formattedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let formattedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let mailtoURL = URL(string: "mailto:\(email)?subject=\(formattedSubject)&body=\(formattedBody)")

        if let url = mailtoURL, NSWorkspace.shared.open(url) {
            print("✅ Opened email client")
        } else {
            print("⚠️ Could not open email client — fallback needed")
            fallbackHandler()
        }
    }


}

