import Foundation

enum SessionPersistenceHelper {
    private static let persistenceKey = "FlowSessionState"
    private static let maxResumeDelay: TimeInterval = 600 // 10 minutes

    /// Save current flow session state to UserDefaults.
    static func saveSession(elapsedSeconds: Int) {
        // Validate input bounds
        let validElapsed = max(0, min(elapsedSeconds, 86400)) // 0 to 24 hours
        
        let state: [String: Any] = [
            "timestamp": Date().timeIntervalSince1970,
            "elapsed": validElapsed
        ]
        UserDefaults.standard.set(state, forKey: persistenceKey)
    }

    /// Attempt to restore session from saved state (if not expired).
    static func restoreSession() -> Int? {
        guard let saved = UserDefaults.standard.dictionary(forKey: persistenceKey),
              let timestamp = saved["timestamp"] as? TimeInterval,
              let savedElapsed = saved["elapsed"] as? Double,
              savedElapsed > 0 else {
            clearSession() // Clean up invalid data
            return nil
        }

        let now = Date().timeIntervalSince1970
        let timeDiff = now - timestamp
        
        // Validate timestamp isn't too far in the future or past
        guard timeDiff >= 0 && timeDiff <= maxResumeDelay * 2 else {
            print("⚠️ Invalid timestamp detected, clearing session")
            clearSession()
            return nil
        }
        
        if timeDiff <= maxResumeDelay {
            let validElapsed = max(0, min(Int(savedElapsed), 86400))
            print("✅ Resuming session after app launch with \(validElapsed)s")
            return validElapsed
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
