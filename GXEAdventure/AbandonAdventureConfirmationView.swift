import SwiftUI

struct AbandonAdventureConfirmationView: View {
    let onAbandon: () -> Void
    let onKeepPlaying: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.75).ignoresSafeArea()

            VStack(spacing: 20) {
                Text("WARNING!")
                    .font(.title.bold())
                    .foregroundColor(.red)

                Text("You are about to abandon your current adventure. All progress will be removed.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .foregroundStyle(Color.bodyTextColor)

                VStack(spacing: 10) { // Use VStack for vertical stacking
                    Button("Abandon Adventure") {
                        onAbandon()
                    }
                    .buttonStyle(PressableButtonStyle(normalColor: .red, pressedColor: .red.opacity(0.8))) // Use consistent style
                    .frame(maxWidth: .infinity) // Make button fill width

                    Button("Keep Playing") {
                        onKeepPlaying()
                    }
                    .buttonStyle(PressableButtonStyle(normalColor: .gray, pressedColor: .gray.opacity(0.8))) // Use consistent style
                    .frame(maxWidth: .infinity) // Make button fill width
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color.appBackground) // Use appBackground for the card background
            .cornerRadius(15)
            .shadow(radius: 10)
            .padding(.horizontal, 20) // Add 20px horizontal padding from screen edges
        }
    }
}

struct AbandonAdventureConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        AbandonAdventureConfirmationView(
            onAbandon: { print("Abandon Adventure") },
            onKeepPlaying: { print("Keep Playing") }
        )
    }
}
