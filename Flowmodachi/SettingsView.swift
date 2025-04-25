import SwiftUI

struct SettingsView: View {
    
    // MARK: - AppStorage Bindings
    @AppStorage("showStreaks") private var showStreaks: Bool = true
    @AppStorage("playSounds") private var playSounds: Bool = true
    @AppStorage("sessionGoal") private var sessionGoal: Int = 25 // in minutes
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial: Bool = true
    
    @State private var showEmailFallback = false
    @State private var copied = false
    let fallbackEmail = "your.email@example.com"


    // MARK: - Constants
    private let sessionGoalOptions = [15, 25, 45, 60]

    // MARK: - View
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // MARK: - Toggles
            Toggle("Show Streaks", isOn: $showStreaks)
            Toggle("Enable Sounds", isOn: $playSounds)
            
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

            
//            // MARK: - Session Goal Picker
//            VStack(alignment: .leading, spacing: 4) {
//                Text("Session Goal")
//                    .font(.caption2)
//                    .foregroundColor(.secondary)
//
//                Picker("Session Goal", selection: $sessionGoal) {
//                    ForEach(sessionGoalOptions, id: \.self) { value in
//                        Text("\(value) min").tag(value)
//                    }
//                }
//                .pickerStyle(.segmented)
//            }

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
        UserDefaults.standard.removeObject(forKey: "FlowmodachiSessions")
        UserDefaults.standard.set(false, forKey: "showStreaks")
        UserDefaults.standard.set(true, forKey: "playSounds")
        UserDefaults.standard.set(25, forKey: "sessionGoal")
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

