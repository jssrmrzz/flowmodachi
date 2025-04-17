import Foundation

enum SessionPersistenceHelper {
    private static let persistenceKey = "FlowSessionState"
    private static let maxResumeDelay: TimeInterval = 600 // 10 minutes

    static func save(elapsedSeconds: Int) {
        let state: [String: Double] = [
            "timestamp": Date().timeIntervalSince1970,
            "elapsed": Double(elapsedSeconds)
        ]
        UserDefaults.standard.set(state, forKey: persistenceKey)
    }

    static func restoreSession() -> Int? {
        guard let saved = UserDefaults.standard.dictionary(forKey: persistenceKey) as? [String: Double],
              let timestamp = saved["timestamp"],
              let savedElapsed = saved["elapsed"],
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

    static func clearSession() {
        UserDefaults.standard.removeObject(forKey: persistenceKey)
    }
}
