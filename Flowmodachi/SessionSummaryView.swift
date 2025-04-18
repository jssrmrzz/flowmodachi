// SessionSummaryView.swift
import SwiftUI

struct SessionSummaryView: View {
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            summaryRow(label: "Current Streak", icon: "flame.fill", value: "\(sessionManager.currentStreak) days")
            summaryRow(label: "Total Sessions", icon: "brain.head.profile", value: "\(sessionManager.sessions.count)")
            summaryRow(label: "Longest Streak", icon: "calendar.badge.plus", value: "\(sessionManager.longestStreak) days")
        }
        .font(.subheadline)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.windowBackgroundColor))
                .shadow(radius: 3)
        )
    }

    // MARK: - Row View

    private func summaryRow(label: String, icon: String, value: String) -> some View {
        HStack {
            Label(label, systemImage: icon)
            Spacer()
            Text(value)
        }
    }
}
