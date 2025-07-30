import SwiftUI
import Foundation

// MARK: - Tutorial Step Model
struct TutorialStep {
    let id: Int
    let title: String
    let description: String
    let targetArea: TutorialTargetArea
    let actionHint: String?
    
    init(id: Int, title: String, description: String, targetArea: TutorialTargetArea, actionHint: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.targetArea = targetArea
        self.actionHint = actionHint
    }
}

enum TutorialTargetArea {
    case welcome
    case startButton
    case timer
    case petArea
    case breakControls
    case settings
    case completion
}

// MARK: - Tutorial Manager
class TutorialManager: ObservableObject {
    @Published var isShowingTutorial: Bool = false
    @Published var currentStep: Int = 0
    @Published var isCompleted: Bool = false
    
    private let steps: [TutorialStep] = [
        TutorialStep(
            id: 0,
            title: "👋 Welcome!",
            description: "Your focus companion that grows as you work.",
            targetArea: .welcome
        ),
        TutorialStep(
            id: 1,
            title: "🥚 Your Pet",
            description: "This egg evolves through focus sessions and breaks.",
            targetArea: .petArea
        ),
        TutorialStep(
            id: 2,
            title: "▶️ Start Focusing",
            description: "Click Start Flow to begin your session.",
            targetArea: .startButton,
            actionHint: "Try it now!"
        ),
        TutorialStep(
            id: 3,
            title: "⏱️ Timer",
            description: "Track progress here. Use Space or Cmd+Shift+F shortcuts.",
            targetArea: .timer
        ),
        TutorialStep(
            id: 4,
            title: "🌱 Break Time",
            description: "Take breaks to help your pet evolve!",
            targetArea: .breakControls
        ),
        TutorialStep(
            id: 5,
            title: "⚙️ Settings",
            description: "Click the gear icon to customize your experience.",
            targetArea: .settings
        ),
        TutorialStep(
            id: 6,
            title: "🎉 Ready!",
            description: "Start your focus journey with your Flowmodachi!",
            targetArea: .completion
        )
    ]
    
    var currentTutorialStep: TutorialStep? {
        guard currentStep < steps.count else { return nil }
        return steps[currentStep]
    }
    
    // Check if tutorial should show for current app state
    func shouldShowTutorial(for targetArea: TutorialTargetArea, isOnBreak: Bool = false) -> Bool {
        guard isShowingTutorial,
              let step = currentTutorialStep else { return false }
        
        // Show tutorial for current step's target area
        if step.targetArea == targetArea {
            return true
        }
        
        // Special cases for contextual display
        switch targetArea {
        case .breakControls:
            return step.targetArea == .breakControls && isOnBreak
        case .timer, .startButton:
            return (step.targetArea == .timer || step.targetArea == .startButton) && !isOnBreak
        default:
            return step.targetArea == targetArea
        }
    }
    
    var isFirstStep: Bool {
        currentStep == 0
    }
    
    var isLastStep: Bool {
        currentStep == steps.count - 1
    }
    
    var progressPercentage: Double {
        guard steps.count > 0 else { return 0 }
        return Double(currentStep + 1) / Double(steps.count)
    }
    
    func startTutorial() {
        isShowingTutorial = true
        currentStep = 0
        isCompleted = false
    }
    
    func nextStep() {
        if currentStep < steps.count - 1 {
            currentStep += 1
        } else {
            completeTutorial()
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
    
    func skipTutorial() {
        completeTutorial()
    }
    
    private func completeTutorial() {
        isCompleted = true
        isShowingTutorial = false
        UserDefaults.standard.set(true, forKey: "hasSeenTutorial")
    }
    
    func resetTutorial() {
        isCompleted = false
        currentStep = 0
        UserDefaults.standard.set(false, forKey: "hasSeenTutorial")
    }
}