//import SwiftUI
//
//struct BreakTimerView: View {
//    let remainingSeconds: Int
//    let totalSeconds: Int
//    let onEndEarly: () -> Void
//
//    private var progress: Double {
//        return 1.0 - min(Double(remainingSeconds) / Double(totalSeconds), 1.0)
//    }
//
//    private var formattedTime: String {
//        let minutes = remainingSeconds / 60
//        let seconds = remainingSeconds % 60
//        return String(format: "%02d:%02d", minutes, seconds)
//    }
//
//    var body: some View {
//        VStack(spacing: 16) {
//            Text("Break Time")
//                .font(.headline)
//
//            ZStack {
//                // Background ring
//                Circle()
//                    .stroke(Color.gray.opacity(0.2), lineWidth: 5)
//
//                // Progress ring (filling as time passes)
//                Circle()
//                    .trim(from: 0, to: progress)
//                    .stroke(Color.green, style: StrokeStyle(lineWidth: 5, lineCap: .round))
//                    .rotationEffect(.degrees(-90))
//                    .animation(.easeInOut(duration: 0.5), value: progress)
//
//                // Countdown in the center
//                Text(formattedTime)
//                    .font(.system(.title2, design: .monospaced))
//                    .foregroundColor(.green)
//            }
//            .frame(width: 64, height: 64)
//
//            Button("End Break Early") {
//                onEndEarly()
//            }
//            .font(.caption)
//            .foregroundColor(.red)
//        }
//        .padding()
//    }
//}
//
