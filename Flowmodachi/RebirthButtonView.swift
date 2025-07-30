import SwiftUI

struct RebirthButtonView: View {
    @EnvironmentObject var petManager: PetManager
    let triggerConfetti: () -> Void

    var body: some View {
        if petManager.isFinalStage {
            VStack(spacing: 8) {
                Divider().padding(.vertical, 8)

                Text("Your Flowmodachi has reached its Final Form!")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Your Flowmodachi has reached its Final Form!")

                Button("Rebirth & Start New Egg") {
                    withAnimation {
                        petManager.resetToStart()
                        triggerConfetti()
                    }
                }
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("Rebirth and start new egg")
                .accessibilityHint("Resets your evolved pet and starts over with a new random egg")
                .padding(.top, 4)
            }
            .padding(.top, 12)
        }
    }
}
