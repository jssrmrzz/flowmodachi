import Foundation

enum SessionPersistenceHelper {
    private static let persistenceKey = "FlowSessionState"
    private static let maxResumeDelay: TimeInterval = 600 // 10 minutes

    /// Save current flow session state to UserDefaults.
    static func saveSession(elapsedSeconds: Int) {
        let state: [String: Any] = [
            "timestamp": Date().timeIntervalSince1970,
            "elapsed": elapsedSeconds
        ]
        UserDefaults.standard.set(state, forKey: persistenceKey)
    }

    /// Attempt to restore session from saved state (if not expired).
    static func restoreSession() -> Int? {
        guard let saved = UserDefaults.standard.dictionary(forKey: persistenceKey),
              let timestamp = saved["timestamp"] as? TimeInterval,
              let savedElapsed = saved["elapsed"] as? Double,
              savedElapsed > 0 else {
            return nil
        }

        let now = Date().timeIntervalSince1970
        if now - timestamp <= maxResumeDelay {
            print("✅ Resuming session after app launch with \(Int(savedElapsed))s")
            return Int(savedElapsed)
        } else {
            print("⚠️ Saved session too old; not restoring")
            clearSession()
            return nil
        }
    }

    /// Clear any previously saved session state.
    static func clearSession() {
        UserDefaults.standard.removeObject(forKey: persistenceKey)
    }
}
