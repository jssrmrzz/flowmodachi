import SwiftUI

struct SettingsView: View {
    
    // MARK: - AppStorage Bindings
    @AppStorage("showStreaks") private var showStreaks: Bool = true
    @AppStorage("playSounds") private var playSounds: Bool = true
    @AppStorage("sessionGoal") private var sessionGoal: Int = 25 // in minutes
    
    // MARK: - Constants
    private let sessionGoalOptions = [15, 25, 45, 60]

    // MARK: - View
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // MARK: - Toggles
            Toggle("Show Streaks", isOn: $showStreaks)
            Toggle("Enable Sounds", isOn: $playSounds)
            
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
}

