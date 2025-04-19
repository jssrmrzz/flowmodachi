import Foundation

// MARK: - SessionManager

class SessionManager: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var sessions: [FlowSession] = []

    // MARK: - Storage Key
    private let storageKey = "FlowmodachiSessions"

    // MARK: - Init
    init() {
        loadSessions()

        #if DEBUG
        // Auto-load demo data in debug mode if flag is set
        if UserDefaults.standard.bool(forKey: "debugDemoMode") {
            seedDemoSessions()
        }
        #endif
    }

    // MARK: - Public API

    /// Adds a new session with current time and duration
    func addSession(duration: Int) {
        let newSession = FlowSession(id: UUID(), startDate: Date(), duration: duration)
        sessions.append(newSession)
        saveSessions()
    }

    /// Overwrites all sessions (used for debugging/demo purposes)
    func replaceSessions(with newSessions: [FlowSession]) {
        sessions = newSessions
        saveSessions()
    }

    /// Clears all session history and storage
    func clearAllSessions() {
        sessions = []
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    /// Returns total minutes studied today
    func totalMinutesToday() -> Int {
        let calendar = Calendar.current
        let todaySessions = sessions.filter {
            calendar.isDateInToday($0.startDate)
        }
        let totalSeconds = todaySessions.map { $0.duration }.reduce(0, +)
        return totalSeconds / 60
    }

    /// Computed property for current streak of consecutive active days
    var currentStreak: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
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

    /// Computed property for longest streak of consecutive active days
    var longestStreak: Int {
        let sortedDates = Set(sessions.map { Calendar.current.startOfDay(for: $0.startDate) }).sorted(by: <)

        guard !sortedDates.isEmpty else { return 0 }

        var maxStreak = 1
        var currentStreak = 1
        var lastDate = sortedDates[0]

        for date in sortedDates.dropFirst() {
            if Calendar.current.date(byAdding: .day, value: 1, to: lastDate) == date {
                currentStreak += 1
            } else {
                maxStreak = max(maxStreak, currentStreak)
                currentStreak = 1
            }
            lastDate = date
        }

        return max(maxStreak, currentStreak)
    }

    /// Returns true if user missed logging a session yesterday
    func missedYesterday() -> Bool {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        let yesterdayStart = calendar.startOfDay(for: yesterday)

        return !sessions.contains { session in
            calendar.isDate(session.startDate, inSameDayAs: yesterdayStart)
        }
    }

    // MARK: - Private Helpers

    /// Saves current sessions to UserDefaults
    private func saveSessions() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    /// Loads sessions from UserDefaults
    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode([FlowSession].self, from: data) {
            sessions = saved
        }
    }

    /// Injects a handful of test sessions for demo/debug purposes
    private func seedDemoSessions() {
        let calendar = Calendar.current
        let now = Date()

        var seeded: [FlowSession] = []
        for offset in 1...5 {
            if let date = calendar.date(byAdding: .day, value: -offset, to: now) {
                let session = FlowSession(id: UUID(), startDate: date, duration: 1800)
                seeded.append(session)
            }
        }
        let today = FlowSession(id: UUID(), startDate: now, duration: 1200)
        seeded.append(today)

        replaceSessions(with: seeded)
    }
}

