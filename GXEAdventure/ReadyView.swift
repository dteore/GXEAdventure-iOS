//
//  ReadyView.swift
//  AdventureApp
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2023 YourCompany. All rights reserved.
//

import SwiftUI

// IMPORTANT: Assuming AppStyles.swift with color and style definitions is available in the project.

struct ReadyView: View {
    @Binding var adventureTitle: String
    @Binding var adventureReward: String
    @Binding var fullAdventureDetails: String // To be displayed when "START" is pressed
    var dismissAction: () -> Void // Action for the 'X' button

    @State private var showingDetailsAlert: Bool = false // State for the alert when START is pressed

    var body: some View {
        ZStack {
            // Background overlay using a color from the app's style guide.
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Close button at the top right.
                HStack {
                    Spacer() // Pushes the button to the right
                    CloseButton(action: dismissAction)
                        .padding(.trailing, 30)
                }
                .padding(.top, 15)


                Spacer() // Pushes content to the center

                Image(systemName: "face.smiling.fill") // Smiley face icon
                    .font(.system(size: 125))
                    .foregroundColor(Color.primaryAppColor)
                    .padding(.bottom, 20)

                Text("Ready!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.headingColor)

                Text(adventureTitle) // Display the adventure title
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.bodyTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text("Reward: \(adventureReward)") // Display the reward
                    .font(.title3)
                    .foregroundColor(.bodyTextColor)
                    .padding(.top, 5)

                // The "START" button now correctly uses the full-width style.
                Button(action: {
                    showingDetailsAlert = true // Show the alert with full details
                }) {
                    // The label only needs the text; the style provides the rest.
                    Text("START")
                }
                .primaryActionButton()
                .padding(.horizontal, 50) // Add horizontal padding to match other full-width buttons
                .padding(.top, 40) // Space above the button

                Spacer() // Pushes content to the center
            }
            .padding(.vertical, 50)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .alert(isPresented: $showingDetailsAlert) { // Alert to show full adventure details
            Alert(title: Text("Your Adventure Details"), message: Text(fullAdventureDetails), dismissButton: .default(Text("OK")))
        }
    }
}

struct ReadyView_Previews: PreviewProvider {
    static var previews: some View {
        ReadyView(
            adventureTitle: .constant("A Whispering Woods Tour"),
            adventureReward: .constant("50 N"),
            fullAdventureDetails: .constant("Your full adventure details would go here, providing all the steps and information from the API response."),
            dismissAction: {} // Empty action for preview
        )
    }
}

