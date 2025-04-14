import SwiftUI

struct LightRayBurstView: View {
    var isVisible: Bool
    var color: Color = .yellow.opacity(0.4)

    var body: some View {
        ZStack {
            ForEach(0..<12) { i in
                Rectangle()
                    .fill(Color.yellow.opacity(0.9))
                    .frame(width: 2, height: 20)
                    .rotationEffect(.degrees(Double(i) * 30))
                    .shadow(color: .yellow.opacity(0.8), radius: 10)
                    .blendMode(.screen)
            }
        }
        .frame(width: 100, height: 100)
        .blur(radius: 1.5)
    }
}

