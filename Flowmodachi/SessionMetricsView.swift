import SwiftUI

struct SessionMetricsView: View {
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        VStack(spacing: 4) {
            Text("🕒 Today: \(sessionManager.totalMinutesToday()) min")
                .font(.caption)
                .foregroundColor(.gray)

            Text("🔥 Streak: \(sessionManager.longestStreak) day\(sessionManager.longestStreak == 1 ? "" : "s")")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}
