import SwiftUI

struct MoodCalculator {
    static func compute(from sessionManager: SessionManager, debugOverride: String, debugMissed: Bool) -> CreatureMood {
        #if DEBUG
        switch debugOverride {
        case "sleepy": return .sleepy
        case "happy": return .happy
        case "neutral": return .neutral
        default: break
        }
        #endif

        return sessionManager.calculateMood(debugMissedYesterday: debugMissed)
    }
}

