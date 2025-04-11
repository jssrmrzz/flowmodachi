import SwiftUI

struct DebugToolsView: View {
    @AppStorage("debugMoodOverride") private var debugMoodOverride: String = "none"
    @AppStorage("debugMissedYesterday") private var debugMissedYesterday: Bool = false

    var body: some View {
        #if DEBUG
        DisclosureGroup("🧪 Dev Tools") {
            VStack(alignment: .leading, spacing: 8) {
                Picker("Mood", selection: $debugMoodOverride) {
                    Text("None").tag("none")
                    Text("Sleepy").tag("sleepy")
                    Text("Neutral").tag("neutral")
                    Text("Happy").tag("happy")
                }
                .pickerStyle(.segmented)

                Toggle("Missed Yesterday", isOn: $debugMissedYesterday)
            }
            .padding(8)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(8)
        }
        .font(.caption)
        .padding(.bottom, 8)
        #endif
    }
}

