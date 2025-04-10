import Foundation

class SessionManager: ObservableObject {
    @Published private(set) var sessions: [FlowSession] = []

    private let storageKey = "FlowmodachiSessions"

    init() {
        loadSessions()
    }

    func addSession(duration: Int) {
        let newSession = FlowSession(id: UUID(), startDate: Date(), duration: duration)
        sessions.append(newSession)
        saveSessions()
    }

    func totalMinutesToday() -> Int {
        let calendar = Calendar.current
        let todaySessions = sessions.filter {
            calendar.isDateInToday($0.startDate)
        }
        let totalSeconds = todaySessions.map { $0.duration }.reduce(0, +)
        return totalSeconds / 60
    }
    
    func currentStreak() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Set of unique session days
        let sessionDays = Set(sessions.map { calendar.startOfDay(for: $0.startDate) })

        guard !sessionDays.isEmpty else { return 0 }

        var streak = 0
        var dateCursor = today

        while sessionDays.contains(dateCursor) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: dateCursor) else { break }
            dateCursor = previousDay
        }

        return streak
    }

    func longestStreak() -> Int {
        let sortedDates = Set(sessions.map { Calendar.current.startOfDay(for: $0.startDate) }).sorted(by: >)

        guard !sortedDates.isEmpty else { return 0 }

        var streak = 1
        var current = sortedDates[0]

        for date in sortedDates.dropFirst() {
            if Calendar.current.date(byAdding: .day, value: -1, to: current) == date {
                streak += 1
                current = date
            } else {
                break
            }
        }
        return streak
    }

    private func saveSessions() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode([FlowSession].self, from: data) {
            sessions = saved
        }
    }
}
