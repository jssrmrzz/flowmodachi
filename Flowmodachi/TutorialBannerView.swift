import SwiftUI

// MARK: - Compact Tutorial Banner
struct TutorialBannerView: View {
    @ObservedObject var tutorialManager: TutorialManager
    
    var body: some View {
        if let step = tutorialManager.currentTutorialStep {
            VStack(spacing: 8) {
                // Header with progress and dismiss
                HStack {
                    // Progress dots
                    HStack(spacing: 4) {
                        ForEach(0..<7, id: \.self) { index in
                            Circle()
                                .fill(index <= tutorialManager.currentStep ? Color.accentColor : Color.gray.opacity(0.3))
                                .frame(width: 4, height: 4)
                        }
                    }
                    
                    Spacer()
                    
                    Button("Skip") {
                        tutorialManager.skipTutorial()
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Skip tutorial")
                }
                
                // Content
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(step.title)
                            .font(.caption)
                            .fontWeight(.medium)
                            .accessibilityLabel(step.title)
                        
                        Text(step.description)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityLabel(step.description)
                        
                        if let actionHint = step.actionHint {
                            Text(actionHint)
                                .font(.caption2)
                                .foregroundColor(.accentColor)
                                .accessibilityHint(actionHint)
                        }
                    }
                    
                    Spacer()
                    
                    // Navigation
                    HStack(spacing: 6) {
                        if !tutorialManager.isFirstStep {
                            Button("◀") {
                                tutorialManager.previousStep()
                            }
                            .font(.caption2)
                            .buttonStyle(.bordered)
                            .controlSize(.mini)
                            .accessibilityLabel("Previous tutorial step")
                        }
                        
                        if tutorialManager.isLastStep {
                            Button("Done") {
                                tutorialManager.nextStep()
                            }
                            .font(.caption2)
                            .buttonStyle(.borderedProminent)
                            .controlSize(.mini)
                            .accessibilityLabel("Finish tutorial")
                        } else {
                            Button("▶") {
                                tutorialManager.nextStep()
                            }
                            .font(.caption2)
                            .buttonStyle(.borderedProminent)
                            .controlSize(.mini)
                            .accessibilityLabel("Next tutorial step")
                        }
                    }
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.accentColor.opacity(0.2), lineWidth: 1)
                    )
            )
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// MARK: - Subtle Tutorial Highlight
extension View {
    func tutorialHighlight(
        when condition: Bool,
        tutorialManager: TutorialManager,
        targetArea: TutorialTargetArea
    ) -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.accentColor.opacity(0.4), lineWidth: condition ? 1.5 : 0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: condition)
            )
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.accentColor.opacity(condition ? 0.05 : 0))
                    .animation(.easeInOut(duration: 0.3), value: condition)
            )
    }
}