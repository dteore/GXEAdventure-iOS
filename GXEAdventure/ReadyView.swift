//
//  ReadyView.swift
//  GXEAdventure
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import SwiftUI

struct ReadyView: View {
    @Binding var adventureTitle: String
    @Binding var adventureReward: String
    @Binding var fullAdventureDetails: String
    var dismissAction: () -> Void

    @State private var showingDetailsAlert: Bool = false

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // MARK: - Close Button
                HStack {
                    // FIX: Button moved to the leading edge (left).
                    Button(action: dismissAction) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .padding(.leading, 30) // FIX: Padding applied to the leading edge.
                    
                    Spacer() // Pushes the button to the left.
                }
                .padding(.top, 15)

                Spacer()

                Image(systemName: "face.smiling.fill")
                    .font(.system(size: 125))
                    .foregroundColor(.primaryAppColor)
                    .padding(.bottom, 20)

                Text("Ready!")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.headingColor)

                Text(adventureTitle)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.bodyTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text("Reward: \(adventureReward)")
                    .font(.title3)
                    .foregroundStyle(Color.bodyTextColor)
                    .padding(.top, 5)

                Button("START") {
                    showingDetailsAlert = true
                }
                .buttonStyle(PressableButtonStyle(
                    normalColor: .primaryAppColor,
                    pressedColor: .pressedButtonColor
                ))
                .padding(.horizontal, 50)
                .padding(.top, 40)

                Spacer()
            }
            .padding(.vertical, 50)
        }
        .alert(isPresented: $showingDetailsAlert) {
            Alert(title: Text("Your Adventure Details"), message: Text(fullAdventureDetails), dismissButton: .default(Text("OK")))
        }
    }
}

struct ReadyView_Previews: PreviewProvider {
    static var previews: some View {
        ReadyView(
            adventureTitle: .constant("A Whispering Woods Tour"),
            adventureReward: .constant("50 N"),
            fullAdventureDetails: .constant("Your full adventure details..."),
            dismissAction: {}
        )
    }
}

