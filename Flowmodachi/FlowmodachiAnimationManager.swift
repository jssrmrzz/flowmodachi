import SwiftUI

class FlowmodachiAnimationManager: ObservableObject {
    @Published var wobble = false
    @Published var isHopping = false
    @Published var isWiggling = false
    @Published var isBouncing = false
    @Published var isFloating = false
    @Published var isAuraPulsing = false
    @Published var auraRotation: Double = 0

    private var auraRotationTimer: Timer?

    func startAnimations(forStage stage: Int) {
        reset()

        switch stage {
        case 0:
            // Egg wobble + hop loop
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                withAnimation { self.wobble = true; self.isHopping = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation { self.wobble = false; self.isHopping = false }
                }
            }

        case 1:
            Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
                withAnimation { self.isHopping = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation { self.isHopping = false }
                }
            }

        case 2:
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.isWiggling = true; self.isBouncing = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        self.isWiggling = false; self.isBouncing = false
                    }
                }
            }

        case 3:
            // Start rotation loop
            auraRotationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
                DispatchQueue.main.async {
                    self.auraRotation += 0.2
                }
            }

            // Floating loop
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 2.0)) {
                    self.isFloating.toggle()
                }
            }

            // Aura pulse loop
            withAnimation(
                Animation.easeInOut(duration: 3.0)
                    .repeatForever(autoreverses: true)
            ) {
                self.isAuraPulsing = true
            }

        default:
            break
        }
    }

    func reset() {
        wobble = false
        isHopping = false
        isWiggling = false
        isBouncing = false
        isFloating = false
        isAuraPulsing = false
        auraRotationTimer?.invalidate()
        auraRotationTimer = nil
        auraRotation = 0
    }
}

