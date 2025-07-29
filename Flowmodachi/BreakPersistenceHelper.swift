import Foundation

enum BreakPersistenceHelper {
    private static let key = "FlowBreakState"
    private static let maxResumeDelay: TimeInterval = 600 // 10 minutes

    struct BreakState {
        let remaining: Int
        let total: Int
    }

    static func saveBreak(remaining: Int, total: Int) {
        // Validate input bounds
        let validRemaining = max(0, min(remaining, 3600)) // 0 to 1 hour
        let validTotal = max(1, min(total, 3600)) // 1 second to 1 hour
        
        let state: [String: Any] = [
            "timestamp": Date().timeIntervalSince1970,
            "remaining": validRemaining,
            "total": validTotal
        ]
        UserDefaults.standard.set(state, forKey: key)
    }

    static func restoreBreak() -> BreakState? {
        guard let saved = UserDefaults.standard.dictionary(forKey: key),
              let timestamp = saved["timestamp"] as? TimeInterval,
              let remaining = saved["remaining"] as? Int,
              let total = saved["total"] as? Int else {
            clearBreak() // Clean up invalid data
            return nil
        }

        let now = Date().timeIntervalSince1970
        let timeDiff = now - timestamp
        
        // Validate timestamp and data bounds
        guard timeDiff >= 0 && timeDiff <= maxResumeDelay * 2,
              remaining >= 0, total > 0, remaining <= total else {
            print("⚠️ Invalid break data detected, clearing")
            clearBreak()
            return nil
        }
        
        if timeDiff <= maxResumeDelay && remaining > 0 {
            let validRemaining = max(0, min(remaining, 3600))
            let validTotal = max(1, min(total, 3600))
            print("✅ Restored break with \(validRemaining)s remaining")
            return BreakState(remaining: validRemaining, total: validTotal)
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
