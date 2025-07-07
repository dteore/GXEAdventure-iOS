//
//  LoadingView.swift
//  GXEAdventure
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import SwiftUI

struct LoadingView: View {
    // Binding to control the visibility of the loading screen.
    @Binding var isLoading: Bool
    // Closure to be called when the user taps the cancel button.
    let cancelAction: () -> Void

    var body: some View {
        ZStack {
            // Use the standard app background color defined in AppStyles.
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // MARK: - Close Button
                HStack {
                    Spacer() // Pushes the button to the far right.
                    Button(action: {
                        withAnimation {
                            // Call the cancel action and dismiss the view.
                            cancelAction()
                            isLoading = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    // Padding to match the original design.
                    .padding(.trailing, 30)
                    .padding(.top, 15)
                }

                Spacer() // Pushes the main content to the vertical center.

                // MARK: - Main Content
                
                // Animated spinner.
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .primaryAppColor))
                    .scaleEffect(2.0) // Makes the spinner larger.

                // "Creating adventure..." text.
                Text("Creating adventure...")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)

                // Subtitle text.
                Text("We're crafting your personalized adventure now.")
                    .font(.body)
                    .foregroundColor(Color.bodyTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer() // Pushes content away from the bottom edge.
            }
            .padding(.vertical, 50)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Previews
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(isLoading: .constant(true), cancelAction: {})
            .environmentObject(LocationManager())
            .environmentObject(NotificationManager())
    }
}

