import Foundation

enum BreakPersistenceHelper {
    private static let key = "FlowBreakState"
    private static let maxResumeDelay: TimeInterval = 600 // 10 minutes

    struct BreakState {
        let remaining: Int
        let total: Int
    }

    static func saveBreak(remaining: Int, total: Int) {
        let state: [String: Any] = [
            "timestamp": Date().timeIntervalSince1970,
            "remaining": remaining,
            "total": total
        ]
        UserDefaults.standard.set(state, forKey: key)
    }

    static func restoreBreak() -> BreakState? {
        guard let saved = UserDefaults.standard.dictionary(forKey: key),
              let timestamp = saved["timestamp"] as? TimeInterval,
              let remaining = saved["remaining"] as? Int,
              let total = saved["total"] as? Int else {
            return nil
        }

        let now = Date().timeIntervalSince1970
        if now - timestamp <= maxResumeDelay && remaining > 0 {
            print("✅ Restored break with \(remaining)s remaining")
            return BreakState(remaining: remaining, total: total)
        } else {
            print("⚠️ Saved break expired or invalid")
            clearBreak()
            return nil
        }
    }

    static func clearBreak() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
