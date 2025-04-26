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

    // MARK: - Dependencies
    let sessionManager: SessionManager
    let evolutionTracker: EvolutionTracker
    let petManager: PetManager

    // MARK: - Private State
    private var timer: Timer?
    private var breakTimer: Timer?
    private var sessionCountedToday = false

    // MARK: - Testing Mode
    private let isTestingMode = true // Set to true for MVP tester build

    // MARK: - Init
    init(sessionManager: SessionManager, evolutionTracker: EvolutionTracker, petManager: PetManager) {
        self.sessionManager = sessionManager
        self.evolutionTracker = evolutionTracker
        self.petManager = petManager

        restoreSessionIfAvailable()
    }

    // MARK: - Flow Timer Logic
    func startFlowTimer() {
        isFlowing = true
        sessionCountedToday = false
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedSeconds += 1
            SessionPersistenceHelper.saveSession(elapsedSeconds: self.elapsedSeconds)
        }
    }

    func pauseFlowTimer() {
        isFlowing = false
        timer?.invalidate()
        timer = nil
    }

    func resetFlowTimer() {
        recordSessionIfEligible()
        pauseFlowTimer()
        elapsedSeconds = 0
        sessionCountedToday = false
        SessionPersistenceHelper.clearSession()
    }

    // MARK: - Break Logic
    func suggestBreak() {
        let suggestedBreakMinutes: Double

        if isTestingMode {
            suggestedBreakMinutes = 1.0 // 1-minute break during testing
        } else {
            let minutes = Double(elapsedSeconds) / 60.0
            suggestedBreakMinutes = minutes >= 120.0 ? 30.0 : min(max(minutes * 0.2, 5.0), 20.0)
        }

        breakTotalDuration = Int(suggestedBreakMinutes * 60)
        breakSecondsRemaining = breakTotalDuration
        startBreak()
    }

    private func startBreak() {
        isFlowing = false
        isOnBreak = true

        if breakSecondsRemaining <= 0 {
            endBreak()
            return
        }

        breakTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.breakSecondsRemaining -= 1
            BreakPersistenceHelper.saveBreak(remaining: self.breakSecondsRemaining, total: self.breakTotalDuration)

            if self.breakSecondsRemaining <= 0 {
                self.endBreak()
            }
        }

        print("Break started for \(breakTotalDuration) seconds")
    }

    func endBreak() {
        print("✅ Break ended cleanly.")
        guard isOnBreak else { return }

        isOnBreak = false
        breakTimer?.invalidate()
        breakTimer = nil

        let breakTaken = breakTotalDuration - breakSecondsRemaining
        evolutionTracker.addBreakCredit(breakTaken)
        petManager.evolveIfEligible()

        breakSecondsRemaining = 0
        elapsedSeconds = 0
        BreakPersistenceHelper.clearBreak()
        playBreakEndSound()
        recordSessionIfEligible()
    }

    func handleBreakPersistence(isOnBreak: Bool) {
        if isOnBreak {
            BreakPersistenceHelper.saveBreak(remaining: breakSecondsRemaining, total: breakTotalDuration)
        } else {
            BreakPersistenceHelper.clearBreak()
        }
    }

    // MARK: - Session Logic
    func recordSessionIfEligible() {
        let today = Calendar.current.startOfDay(for: Date())
        let alreadyRecorded = sessionManager.sessions.contains {
            Calendar.current.isDate($0.startDate, inSameDayAs: today)
        }

        if elapsedSeconds >= minimumEligibleSeconds && !alreadyRecorded {
            sessionManager.addSession(duration: elapsedSeconds)
            sessionCountedToday = true
            print("✅ Session recorded at \(elapsedSeconds) seconds")
        }
    }

    func restoreSessionIfAvailable() {
        print("🪵 Attempting to restore session...") // DEBUG LOG

        guard UserDefaults.standard.bool(forKey: "resumeOnLaunch") else {
            print("🛑 resumeOnLaunch disabled")
            return
        }

        if let restoredBreak = BreakPersistenceHelper.restoreBreak() {
            print("✅ Break session found, restoring break.")
            breakTotalDuration = restoredBreak.total
            breakSecondsRemaining = restoredBreak.remaining
            startBreak()
        } else if let restored = SessionPersistenceHelper.restoreSession() {
            print("✅ Flow session found, restoring \(restored) seconds.")
            elapsedSeconds = restored
            startFlowTimer()
        } else {
            print("⚠️ No session found.")
        }
    }

    func handleFlowPersistence(isFlowing: Bool) {
        if isFlowing {
            SessionPersistenceHelper.saveSession(elapsedSeconds: elapsedSeconds)
        } else {
            SessionPersistenceHelper.clearSession()
        }
    }

    // MARK: - Utility
    private var minimumEligibleSeconds: Int {
        if isTestingMode {
            return 5 // 5 seconds needed to count session during testing
        } else {
            return 60 * 5 // 5 minutes minimum normally
        }
    }

    private func playBreakEndSound() {
        NSSound(named: "Glass")?.play()
    }
}
