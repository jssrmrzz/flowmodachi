import Foundation

/// Tracks evolution progress based on accumulated break time (in seconds).
class EvolutionTracker: ObservableObject {
    
    // MARK: - Published State (Stored in UserDefaults)
    
    /// Total earned break seconds used to determine evolution.
    @Published var earnedBreakSeconds: Int = UserDefaults.standard.integer(forKey: "earnedBreakSeconds")
    
    /// Current evolution stage index (0 to 3).
    @Published var currentStage: Int = UserDefaults.standard.integer(forKey: "evolutionStage")

    // MARK: - Configuration

    /// Stage thresholds in seconds. Example: 0s, 5m, 30m, 60m
    private let stageThresholds = [0, 300, 1800, 3600]

    // MARK: - Public API

    /// Grants break credit (in seconds) and updates evolution state.
    func addBreakCredit(_ seconds: Int) {
        earnedBreakSeconds += seconds
        UserDefaults.standard.set(earnedBreakSeconds, forKey: "earnedBreakSeconds")
        updateStage()
    }

    /// Resets all evolution progress (for testing/debug).
    func resetProgress() {
        earnedBreakSeconds = 0
        currentStage = 0
        UserDefaults.standard.set(0, forKey: "earnedBreakSeconds")
        UserDefaults.standard.set(0, forKey: "evolutionStage")
    }

    // MARK: - Stage Logic

    /// Determines the current stage based on earned break seconds.
    private func updateStage() {
        let newStage = stageThresholds.lastIndex(where: { earnedBreakSeconds >= $0 }) ?? 0
        if newStage != currentStage {
            currentStage = newStage
            UserDefaults.standard.set(currentStage, forKey: "evolutionStage")
            print("🌱 Evolved to stage \(currentStage)")
        }
    }
}

