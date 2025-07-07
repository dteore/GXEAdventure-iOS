//
//  SplashView.swift
//  GXEAdventure
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2025 YourCompany. All rights reserved.
//
import SwiftUI

struct SplashView: View {
    // A binding to dismiss the splash screen and transition to the next view.
    @Binding var showSplash: Bool

    // State to control the visibility and animation of the splash content.
    @State private var isActive = false

    // State for Progress Bar
    @State private var progressValue: Double = 0.0 // Represents the progress from 0.0 to 1.0

    var body: some View {
        ZStack {
            // Background color for the splash screen (matches the original design)
            Color(red: 216 / 255.0, green: 247 / 255.0, blue: 236 / 255.0)
                .ignoresSafeArea()

            // MARK: - NVRSE Text (Vertically and Horizontally Centered)
            Text("NVRSE")
                // Get the point size of LargeTitle and multiply by 1.25 for 25% larger
                .font(.system(size: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize * 1.25))
                .fontWeight(.bold)  // Make it bold
                // Text color set to the original RGB value.
                .foregroundColor(Color(red: 18 / 255.0, green: 165 / 255.0, blue: 144 / 255.0))
                .scaleEffect(isActive ? 1.0 : 0.8) // Subtle scale animation
                .opacity(isActive ? 1.0 : 0.5) // Fade in animation (starts at 0.5 opacity)

            // MARK: - Progress View (Aligned to Bottom)
            // Encapsulated in a VStack with a Spacer to push it to the bottom
            VStack {
                Spacer() // Pushes the ProgressView down
                ProgressView(value: progressValue)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color.primaryAppColor)) // Style with your app's color
                    .frame(width: 200) // Control the width
                    .padding(.bottom, 50) // Padding from the bottom of the screen
                    .opacity(isActive ? 1.0 : 0.0) // Fade in with the other elements
            }
        }
        .onAppear {
            // Animate the content (NVRSE text)
            withAnimation(.easeOut(duration: 1.0)) {
                self.isActive = true // This triggers the NVRSE text animation and progress bar fade-in
            }

            // Animate Progress Bar using the original Timer logic
            Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
                if self.progressValue < 1.0 {
                    self.progressValue += 0.025 // Increment by 2.5% every 0.05 seconds
                } else {
                    timer.invalidate() // Stop the timer when progress reaches 100%
                }
            }

            // Dismiss the splash screen after a 2-second delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    self.showSplash = false // This will trigger the transition in the root view.
                }
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView(showSplash: .constant(true))
    }
}

