import SwiftUI

struct EggPopFlashView: View {
    let isVisible: Bool

    var body: some View {
        if isVisible {
            Circle()
                .fill(Color.white)
                .frame(width: 80, height: 80)
                .scaleEffect(isVisible ? 1.4 : 0.1)
                .opacity(isVisible ? 0 : 0.4)
                .blur(radius: 10)
                .animation(.easeOut(duration: 0.6), value: isVisible)
        }
    }
}

