import SwiftUI

struct StreakView: View {
    let sessions: [FlowSession]

    private let calendar = Calendar.current
    private let daysToShow = 7

    private var recentDays: [Date] {
        let today = calendar.startOfDay(for: Date())
        return (0..<daysToShow).reversed().compactMap {
            calendar.date(byAdding: .day, value: -$0, to: today)
        }
    }

    private func hasSession(on date: Date) -> Bool {
        sessions.contains { session in
            calendar.isDate(session.startDate, inSameDayAs: date)
        }
    }

    private var daySymbols: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "E"
        return recentDays.map { String(formatter.string(from: $0).prefix(1)) }
    }

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                ForEach(0..<daysToShow, id: \.self) { i in
                    Text(daySymbols[i])
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .frame(width: 20)
                }
            }

            HStack(spacing: 8) {
                ForEach(recentDays, id: \.self) { day in
                    Image(systemName: hasSession(on: day) ? "brain.filled.head.profile" : "moon.zzz")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .foregroundColor(hasSession(on: day) ? .yellow : .gray)

                        .font(.title3)
                        .frame(width: 20)
                        .transition(.scale)
                }
            }
        }
    }
}

