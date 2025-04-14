import SwiftUI

struct EvolveFlashView: View {
    let stage: Int
    @Binding var isVisible: Bool
    
    @State private var fadeIn = false

    var body: some View {
        ZStack {
            if isVisible {
                Circle()
                    .fill(flashColor(for: stage))
                    .frame(width: 100, height: 100)
                    .scaleEffect(fadeIn ? 1.6 : 1.0)
                    .opacity(fadeIn ? 0.6 : 0.0)
                    .blur(radius: 8)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.5)) {
                            fadeIn = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                fadeIn = false
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .frame(width: 100, height: 100)
    }

    private func flashColor(for stage: Int) -> Color {
        switch stage {
        case 1: return .yellow
        case 2: return .blue
        case 3: return .pink
        default: return .white
        }
    }
}

// Preview for development
//struct EvolveFlashView_Previews: PreviewProvider {
//    @State static var previewVisible = true
//    static var previews: some View {
//        EvolveFlashView(stage: 2, isVisible: $previewVisible)
//            .background(Color.black)
//            .previewLayout(.sizeThatFits)
//            .padding()
//    }
//}

