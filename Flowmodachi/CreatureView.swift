//import SwiftUI
//
//
//struct CreatureView: View {
//    // Input from parent: how many seconds have passed in the focus session
//    let elapsedSeconds: Int
//    let isSleeping: Bool
//
//    // Track which stage we're in (0 = egg, 3 = final form)
//    @State private var currentStageIndex: Int = 0
//    @State private var isSparkling = false
//    @State private var isPulsing = false
//
//    // Evolution stages: each has a symbol + label
//    let stages: [(symbol: String, label: String)] = [
//        ("sun.min", "Stage 1"),         // 0–2 sec
//        ("sun.min.fill", "Stage 2"),    // 3–5 sec
//        ("sun.max", "Stage 3"),         // 6–8 sec
//        ("sun.max.fill", "Final Form")  // 9+ sec
//    ]
//
//    var body: some View {
//        VStack(spacing: 8) {
//            ZStack {
//                
//                if currentStageIndex == stages.count - 1 {
//                        Image(systemName: "sparkles")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 70, height: 70)
//                            .foregroundColor(.yellow.opacity(0.3))
//                            .rotationEffect(.degrees(isSparkling ? 360 : 0))
//                            .scaleEffect(isSparkling ? 1.2 : 0.9)
//                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isSparkling)
//                    }
//                // Base ring
//                Circle()
//                    .stroke(Color.gray.opacity(0.2), lineWidth: 5)
//
//                // Progress ring
//                Circle()
//                    .trim(from: 0, to: stageProgress)
//                    .stroke(Color.purple, style: StrokeStyle(lineWidth: 5, lineCap: .round))
//                    .rotationEffect(.degrees(-90)) // start at top
//                    .animation(.easeInOut(duration: 0.4), value: stageProgress)
//                
//                if isSleeping {
//                        Circle()
//                            .stroke(Color.blue.opacity(0.3), lineWidth: 8)
//                            .scaleEffect(isPulsing ? 1.1 : 0.9)
//                            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isPulsing)
//                    }
//                
//                // Creature icon in the center
//                Image(systemName: isSleeping ? "moon.haze" : stages[currentStageIndex].symbol)
//
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 36, height: 36)
//                    .foregroundColor(.purple)
//                    .transition(.scale.combined(with: .opacity))
//                    .id(stages[currentStageIndex].symbol)
//            }
//            .frame(width: 56, height: 56)
//
//            // Stage label
//            Text(stages[currentStageIndex].label)
//                .font(.caption)
//                .foregroundColor(.gray)
//                .id(stages[currentStageIndex].label)
//                .animation(.easeInOut(duration: 0.4), value: currentStageIndex)
//        }
//        .onChange(of: isSleeping) {
//            if isSleeping {
//                isPulsing = true
//            } else {
//                isPulsing = false
//            }
//        }
//
//        .onAppear {
//            updateStage()
//            if isSleeping {
//                isPulsing = true
//            }
//        }
//    }
//    
//    // Calculates progress toward the next evolution stage
//    private var stageProgress: Double {
//        let totalEvolutionTime: Double = 9.0 // full evolution duration in seconds
//        return min(Double(elapsedSeconds) / totalEvolutionTime, 1.0)
//    }
//
//   
//
//
//    // Logic for determining which evolution stage we’re in
//    private func updateStage() {
//        let newStageIndex: Int
//
//        switch elapsedSeconds {
//        case 0..<3: newStageIndex = 0
//        case 3..<6: newStageIndex = 1
//        case 6..<9: newStageIndex = 2
//        default:    newStageIndex = 3
//        }
//
//        // Only update (with animation) if we’ve entered a new stage
//        if newStageIndex != currentStageIndex {
//            withAnimation {
//                currentStageIndex = newStageIndex
//            }
//        }
//
//        isSparkling = (newStageIndex == stages.count - 1)
//    }
//}
//
