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
    @Published var errorHandler = ErrorHandler()

    // MARK: - Private State
    private var timer: Timer?
    private var breakTimer: Timer?
    private var sessionCountedToday = false
    private var sessionStartTime: Date?
    private var breakStartTime: Date?
    private var lastUpdateTime: Date = Date()
    private var isDestroying = false

    // MARK: - Settings
    @AppStorage("isTestingMode") private var isTestingMode: Bool = false
    @AppStorage("playSounds") private var playSounds: Bool = true
    @AppStorage("breakMultiplier") private var breakMultiplier: Double = 0.2
    @AppStorage("minBreakMinutes") private var minBreakMinutes: Int = 5
    @AppStorage("maxBreakMinutes") private var maxBreakMinutes: Int = 20

    // MARK: - Init & Deinit
    init(sessionManager: SessionManager, evolutionTracker: EvolutionTracker, petManager: PetManager) {
        self.sessionManager = sessionManager
        self.evolutionTracker = evolutionTracker
        self.petManager = petManager

        restoreSessionIfAvailable()
    }
    
    deinit {
        cleanupTimers()
    }
    
    // MARK: - Memory Management
    private func cleanupTimers() {
        isDestroying = true
        
        // Invalidate and nil out timers
        timer?.invalidate()
        timer = nil
        
        breakTimer?.invalidate()
        breakTimer = nil
        
        // Final persistence save if needed
        if isFlowing {
            SessionPersistenceHelper.saveSession(elapsedSeconds: elapsedSeconds)
        }
        
        if isOnBreak {
            BreakPersistenceHelper.saveBreak(remaining: breakSecondsRemaining, total: breakTotalDuration)
        }
    }
    
    func destroy() {
        cleanupTimers()
    }

    // MARK: - Flow Timer Logic
    func startFlowTimer() {
        guard !isFlowing else { return } // Prevent duplicate timers
        
        do {
            try validateState() // Ensure clean state before starting
            
            isFlowing = true
            sessionCountedToday = false
            sessionStartTime = Date()
            lastUpdateTime = sessionStartTime ?? Date()
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
                guard let self = self, !self.isDestroying else {
                    timer.invalidate()
                    return
                }
                self.updateFlowTimer()
            }
            
            // Ensure timer runs on main thread and common run loop modes
            if let timer = timer {
                RunLoop.main.add(timer, forMode: .common)
            } else {
                throw NSError(domain: "FlowEngine", code: 1, userInfo: [NSLocalizedDescriptionKey: "Timer creation failed"])
            }
            
            synchronizeUI()
            
        } catch {
            errorHandler.handleError(.timerStartFailed)
            isFlowing = false // Reset state on failure
        }
    }
    
    private func updateFlowTimer() {
        guard !isDestroying,
              let startTime = sessionStartTime else { return }
        
        let currentTime = Date()
        let actualElapsed = Int(currentTime.timeIntervalSince(startTime))
        
        // Validate bounds to prevent negative or extreme values
        let validElapsed = max(0, min(actualElapsed, 86400)) // Max 24 hours
        
        if validElapsed != elapsedSeconds {
            elapsedSeconds = validElapsed
            SessionPersistenceHelper.saveSession(elapsedSeconds: elapsedSeconds)
        }
        
        lastUpdateTime = currentTime
    }

    func pauseFlowTimer() {
        guard isFlowing else { return } // Prevent duplicate pauses
        
        isFlowing = false
        timer?.invalidate()
        timer = nil
        
        // Final update to ensure accuracy
        if let startTime = sessionStartTime {
            let finalElapsed = Int(Date().timeIntervalSince(startTime))
            elapsedSeconds = max(0, min(finalElapsed, 86400))
            SessionPersistenceHelper.saveSession(elapsedSeconds: elapsedSeconds)
        }
        
        try? validateState()
        synchronizeUI()
    }

    func resetFlowTimer() {
        recordSessionIfEligible()
        pauseFlowTimer()
        elapsedSeconds = 0
        sessionCountedToday = false
        sessionStartTime = nil
        lastUpdateTime = Date()
        SessionPersistenceHelper.clearSession()
    }

    // MARK: - Break Logic
    func suggestBreak() {
        // Validate elapsed time before calculating break
        guard elapsedSeconds > 0 else {
            print("⚠️ Cannot suggest break with zero elapsed time")
            return
        }
        
        let suggestedBreakMinutes: Double

        if isTestingMode {
            suggestedBreakMinutes = 1.0 // 1-minute break during testing
        } else {
            let minutes = Double(elapsedSeconds) / 60.0
            let calculatedBreak = minutes * max(0.1, min(breakMultiplier, 1.0)) // Bound multiplier
            let minBreak = Double(max(1, minBreakMinutes)) // Ensure minimum of 1 minute
            let maxBreak = Double(max(minBreakMinutes, maxBreakMinutes)) // Ensure max >= min
            
            // For sessions over 2 hours, use a longer break (30 min max)
            if minutes >= 120.0 {
                suggestedBreakMinutes = min(30.0, maxBreak)
            } else {
                suggestedBreakMinutes = min(max(calculatedBreak, minBreak), maxBreak)
            }
        }

        // Validate break duration bounds
        let breakSeconds = Int(max(60, min(suggestedBreakMinutes * 60, 3600))) // 1 min to 1 hour
        breakTotalDuration = breakSeconds
        breakSecondsRemaining = breakSeconds
        startBreak()
    }

    private func startBreak() {
        guard !isOnBreak else { return } // Prevent duplicate breaks
        
        isFlowing = false
        isOnBreak = true
        breakStartTime = Date()

        if breakSecondsRemaining <= 0 {
            endBreak()
            return
        }

        breakTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self, !self.isDestroying else {
                timer.invalidate()
                return
            }
            self.updateBreakTimer()
        }
        
        // Ensure timer runs on main thread and common run loop modes
        if let timer = breakTimer {
            RunLoop.main.add(timer, forMode: .common)
        }

        print("Break started for \(breakTotalDuration) seconds")
    }
    
    private func updateBreakTimer() {
        guard !isDestroying,
              let startTime = breakStartTime else { return }
        
        let currentTime = Date()
        let elapsed = Int(currentTime.timeIntervalSince(startTime))
        let remaining = max(0, breakTotalDuration - elapsed)
        
        if remaining != breakSecondsRemaining {
            breakSecondsRemaining = remaining
            BreakPersistenceHelper.saveBreak(remaining: remaining, total: breakTotalDuration)
            
            if remaining <= 0 {
                endBreak()
            }
        }
    }

    func endBreak() {
        print("✅ Break ended cleanly.")
        guard isOnBreak else { return }

        isOnBreak = false
        breakTimer?.invalidate()
        breakTimer = nil

        // Calculate accurate break time taken
        let breakTaken: Int
        if let startTime = breakStartTime {
            breakTaken = min(Int(Date().timeIntervalSince(startTime)), breakTotalDuration)
        } else {
            breakTaken = breakTotalDuration - breakSecondsRemaining
        }
        
        // Validate break credit is positive
        if breakTaken > 0 {
            evolutionTracker.addBreakCredit(breakTaken)
            petManager.evolveIfEligible()
        }

        // Reset break state
        breakSecondsRemaining = 0
        breakStartTime = nil
        elapsedSeconds = 0
        sessionStartTime = nil
        
        BreakPersistenceHelper.clearBreak()
        playBreakEndSound()
        recordSessionIfEligible()
        
        try? validateState()
        synchronizeUI()
    }

    func handleBreakPersistence(isOnBreak: Bool) {
        if isOnBreak {
            BreakPersistenceHelper.saveBreak(remaining: breakSecondsRemaining, total: breakTotalDuration)
        } else {
            BreakPersistenceHelper.clearBreak()
        }
    }
    
    // MARK: - State Synchronization
    
    /// Validates and synchronizes internal state consistency
    func validateState() throws {
        // Defensive state checking to prevent inconsistencies
        
        // Can't be both flowing and on break
        if isFlowing && isOnBreak {
            print("⚠️ State inconsistency: both flowing and on break. Fixing...")
            isOnBreak = false
            breakTimer?.invalidate()
            breakTimer = nil
            BreakPersistenceHelper.clearBreak()
            throw NSError(domain: "FlowEngine", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid session state detected"])
        }
        
        // Timer existence should match state
        if isFlowing && timer == nil {
            print("⚠️ State inconsistency: flowing but no timer. Restarting timer...")
            if sessionStartTime != nil {
                startFlowTimer()
            } else {
                isFlowing = false
                elapsedSeconds = 0
            }
        }
        
        if isOnBreak && breakTimer == nil && breakSecondsRemaining > 0 {
            print("⚠️ State inconsistency: on break but no timer. Restarting break...")
            if breakStartTime != nil {
                startBreak()
            } else {
                isOnBreak = false
                breakSecondsRemaining = 0
            }
        }
        
        // Validate time bounds
        elapsedSeconds = max(0, min(elapsedSeconds, 86400))
        breakSecondsRemaining = max(0, min(breakSecondsRemaining, 3600))
        breakTotalDuration = max(0, min(breakTotalDuration, 3600))
    }
    
    /// Forces UI synchronization by triggering @Published updates
    func synchronizeUI() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Force @Published property updates to sync UI
            self.objectWillChange.send()
            
            // Ensure persistence matches current state
            if self.isFlowing {
                SessionPersistenceHelper.saveSession(elapsedSeconds: self.elapsedSeconds)
            }
            
            if self.isOnBreak {
                BreakPersistenceHelper.saveBreak(
                    remaining: self.breakSecondsRemaining,
                    total: self.breakTotalDuration
                )
            }
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
        print("🪵 Attempting to restore session...")

        guard UserDefaults.standard.bool(forKey: "resumeOnLaunch") else {
            print("🛑 resumeOnLaunch disabled")
            return
        }

        if let restoredBreak = BreakPersistenceHelper.restoreBreak() {
            print("✅ Break session found, restoring break.")
            // Validate break data
            let validTotal = max(1, min(restoredBreak.total, 3600))
            let validRemaining = max(0, min(restoredBreak.remaining, validTotal))
            
            if validRemaining > 0 {
                breakTotalDuration = validTotal
                breakSecondsRemaining = validRemaining
                startBreak()
            } else {
                print("⚠️ Break had no time remaining, clearing.")
                BreakPersistenceHelper.clearBreak()
            }
        } else if let restored = SessionPersistenceHelper.restoreSession() {
            print("✅ Flow session found, restoring \(restored) seconds.")
            // Validate session data
            let validElapsed = max(0, min(restored, 86400))
            
            if validElapsed > 0 {
                elapsedSeconds = validElapsed
                sessionStartTime = Date().addingTimeInterval(-Double(validElapsed))
                startFlowTimer()
            } else {
                print("⚠️ Invalid session data, starting fresh.")
                SessionPersistenceHelper.clearSession()
            }
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
        guard playSounds else { return }
        NSSound(named: "Glass")?.play()
    }
}
