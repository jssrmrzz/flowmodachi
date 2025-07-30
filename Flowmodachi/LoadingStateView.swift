import SwiftUI

// MARK: - Loading State View
struct LoadingStateView: View {
    let message: String
    let showSpinner: Bool
    
    init(message: String = "Loading...", showSpinner: Bool = true) {
        self.message = message
        self.showSpinner = showSpinner
    }
    
    var body: some View {
        HStack(spacing: 8) {
            if showSpinner {
                ProgressView()
                    .scaleEffect(0.8)
                    .accessibilityHidden(true)
            }
            
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibilityLabel(message)
        }
        .padding(.vertical, 8)
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
}

// MARK: - Enhanced Transition Animations
struct EnhancedTransitions {
    static let slideAndFade = AnyTransition.asymmetric(
        insertion: .move(edge: .trailing).combined(with: .opacity),
        removal: .move(edge: .leading).combined(with: .opacity)
    )
    
    static let scaleAndFade = AnyTransition.scale(scale: 0.8)
        .combined(with: .opacity)
        .animation(.spring(response: 0.6, dampingFraction: 0.8))
    
    static let slideUp = AnyTransition.move(edge: .bottom)
        .combined(with: .opacity)
        .animation(.easeOut(duration: 0.4))
    
    static let bounceIn = AnyTransition.scale(scale: 0.3)
        .combined(with: .opacity)
        .animation(.spring(response: 0.5, dampingFraction: 0.6))
}

// MARK: - Button Press Animation
struct ButtonPressAnimation: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .opacity(isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
    }
}

extension View {
    func buttonPressAnimation() -> some View {
        self.modifier(ButtonPressAnimation())
    }
}

// MARK: - Transition State Manager
// Note: TransitionStateManager removed as artificial loading delays were causing UI sluggishness.
// Keeping this comment for reference - instant operations should not have artificial loading states.

// MARK: - Success Feedback View
struct SuccessFeedbackView: View {
    let message: String
    let duration: Double
    @State private var isVisible = false
    
    init(message: String, duration: Double = 2.0) {
        self.message = message
        self.duration = duration
    }
    
    var body: some View {
        if isVisible {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                
                Text(message)
                    .font(.caption)
                    .foregroundColor(.green)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.green.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.green.opacity(0.3), lineWidth: 1)
                    )
            )
            .transition(EnhancedTransitions.bounceIn)
            .accessibilityLabel("Success: \(message)")
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    withAnimation {
                        isVisible = false
                    }
                }
            }
        }
    }
    
    func show() {
        withAnimation {
            isVisible = true
        }
    }
}

// MARK: - Pulse Animation View
struct PulseAnimationView: View {
    let color: Color
    let scale: CGFloat
    @State private var isPulsing = false
    
    init(color: Color = .accentColor, scale: CGFloat = 1.2) {
        self.color = color
        self.scale = scale
    }
    
    var body: some View {
        Circle()
            .fill(color.opacity(0.3))
            .scaleEffect(isPulsing ? scale : 1.0)
            .opacity(isPulsing ? 0.0 : 1.0)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: isPulsing)
            .onAppear {
                isPulsing = true
            }
    }
}

// MARK: - Shimmer Effect
struct ShimmerView: View {
    @State private var phase: CGFloat = 0
    let gradient = LinearGradient(
        colors: [.clear, .white.opacity(0.4), .clear],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    var body: some View {
        Rectangle()
            .fill(gradient)
            .rotationEffect(.degrees(30))
            .offset(x: phase)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 300
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        self
            .overlay(ShimmerView().mask(self))
    }
}