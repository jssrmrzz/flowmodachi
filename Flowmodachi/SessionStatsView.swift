import SwiftUI

struct SessionStatsView: View {
    let currentStreak: Int
    let totalSessions: Int
    let longestStreak: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Current Streak", systemImage: "flame.fill")
                Spacer()
                Text("\(currentStreak) days")
            }

            HStack {
                Label("Total Sessions", systemImage: "brain.head.profile")
                Spacer()
                Text("\(totalSessions)")
            }

            HStack {
                Label("Longest Streak", systemImage: "calendar.badge.plus")
                Spacer()
                Text("\(longestStreak) days")
            }
        }
        .font(.subheadline)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.windowBackgroundColor))
                .shadow(radius: 4)
        )
    }
}

