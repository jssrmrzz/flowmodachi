import SwiftUI

struct StreakView: View {
    @State private var animateToday = false
    @AppStorage("debugStreakAnimation") private var debugStreakAnimation = false


    
    
    let sessions: [FlowSession]
    
    private let calendar = Calendar.current
    private let daysToShow = 7
    
    private var recentDays: [Date] {
        let today = calendar.startOfDay(for: Date())
        return (0..<daysToShow).reversed().compactMap {
            calendar.date(byAdding: .day, value: -$0, to: today)
        }
    }
    
    private func hasSession(on date: Date) -> Bool {
        sessions.contains { session in
            calendar.isDate(session.startDate, inSameDayAs: date)
        }
    }
    
    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    private var daySymbols: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "E"
        return recentDays.map { String(formatter.string(from: $0).prefix(1)) }
    }
    
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                ForEach(0..<daysToShow, id: \.self) { i in
                    Text(daySymbols[i])
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .frame(width: 20)
                }
            }
            
            HStack(spacing: 8) {
                ForEach(recentDays, id: \.self) { day in
                    if hasSession(on: day) {
                        Image(systemName: "brain.head.profile")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .foregroundColor(.yellow)
                            .scaleEffect(isToday(day) && animateToday ? 1.25 : 1.0)
                            .opacity(isToday(day) && animateToday ? 0 : 1)
                            .transition(.scale)
                            .animation(.interpolatingSpring(stiffness: 100, damping: 10).delay(0.1), value: animateToday)


                    } else {
                        Image(systemName: "moon.zzz")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .foregroundColor(.gray)
                    }
                }
            }

            
        }
        .onAppear {
            let today = calendar.startOfDay(for: Date())

            if let lastSession = sessions.last {
                let sessionDate = calendar.startOfDay(for: lastSession.startDate)
                if sessionDate == today || debugStreakAnimation {
                    animateToday = true

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        animateToday = false
                    }
                }
            }
        }
        
    }
    
}
