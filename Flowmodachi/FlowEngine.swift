import Foundation
import Combine
import SwiftUI
import AVFoundation

class FlowEngine: ObservableObject {
    // MARK: - Published State
    @Published var isFlowing = false
    @Published var elapsedSeconds = 0
    @Published var isOnBreak = false
    @Published var breakSecondsRemaining = 0
    @Published var breakTotalDuration = 0

    // MARK: - Private
    private var timer: Timer?
    private var breakTimer: Timer?
    private var sessionCountedToday = false

    // MARK: - Init
    init() {
        print("🌀 FlowEngine created")

        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        print("🧪 UserDefaults keys at launch: \(allKeys)")

        if UserDefaults.standard.bool(forKey: "resumeOnLaunch") {
            if let restored = SessionPersistenceHelper.restoreSession() {
                elapsedSeconds = restored
                print("✅ Flow restored at \(restored)s")
                startFlowTimer()
            } else {
                print("❌ No valid flow session to restore")
            }
        }

        print("🧠 FlowEngine INIT done")
    }

    // MARK: - Flow Control
    func startFlowTimer() {
        isFlowing = true
        sessionCountedToday = false

        print("▶️ Starting flow timer at \(elapsedSeconds)s")
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.elapsedSeconds += 1
            SessionPersistenceHelper.saveSession(elapsedSeconds: self.elapsedSeconds)
        }
    }

    func pauseFlowTimer() {
        print("⏸ Pausing flow at \(elapsedSeconds)s")
        isFlowing = false
        timer?.invalidate()
        timer = nil
    }

    func resetFlowTimer() {
        print("🔄 Resetting flow")
        recordSessionIfEligible()
        pauseFlowTimer()
        elapsedSeconds = 0
        sessionCountedToday = false
        SessionPersistenceHelper.clearSession()
    }

    func handleFlowPersistence(isFlowing: Bool) {
        if isFlowing {
            print("💾 Persisting flow: \(elapsedSeconds)s")
            SessionPersistenceHelper.saveSession(elapsedSeconds: elapsedSeconds)
        } else {
            print("🧹 Clearing persisted flow")
            SessionPersistenceHelper.clearSession()
        }
    }

    func recordSessionIfEligible() {
        let today = Calendar.current.startOfDay(for: Date())
        let alreadyRecorded = sessionManager.sessions.contains {
            Calendar.current.isDate($0.startDate, inSameDayAs: today)
        }

        if elapsedSeconds >= minimumEligibleSeconds && !alreadyRecorded {
            sessionManager.addSession(duration: elapsedSeconds)
            sessionCountedToday = true
            print("✅ Session recorded at \(elapsedSeconds)s")
        } else {
            print("⚠️ Session not recorded – already exists or not enough time")
        }
    }

    private var minimumEligibleSeconds: Int {
        #if DEBUG
        return 5
        #else
        return 60 * 5
        #endif
    }

    // MARK: - Dummy Dependencies
    let sessionManager = SessionManager()
    let evolutionTracker = EvolutionTracker()
    let petManager = PetManager()

    // MARK: - Optional: Sound
    private func playBreakEndSound() {
        NSSound(named: "Glass")?.play()
    }
}
