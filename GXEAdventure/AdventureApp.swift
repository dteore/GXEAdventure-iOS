//
//  AdventureApp.swift
//  GXEAdventure
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import SwiftUI

@main
struct AdventureApp: App {
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var locationManager = LocationManager()

    var body: some Scene {
        WindowGroup {
            // The RootView now contains the logic for displaying Splash, Onboarding, or ContentView.
            // We create all our state objects here in the main app struct and pass them into
            // the environment for the rest of the app to use.
            RootView()
                .environmentObject(notificationManager)
                .environmentObject(locationManager)
        }
    }
}

/// A new view that acts as the main container, deciding which screen to show.
private struct RootView: View {
    // @AppStorage reads and writes the onboarding status to UserDefaults.
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    // State to control the visibility of the splash screen.
    @State private var showSplash: Bool = true

    var body: some View {
        ZStack {
            // Conditionally display views based on the app's state.
            if showSplash {
                // The SplashView is responsible for updating its binding, which will hide it.
                SplashView(showSplash: $showSplash)
            } else if !hasCompletedOnboarding {
                // OnboardingView gets the managers from the environment.
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            } else {
                // ContentView gets the managers from the environment.
                ContentView()
            }
        }
        // FIX: Use the explicitly defined color from the private extension below.
        // This prevents the app from crashing by trying to find the color in the asset catalog.
        .background(Color.rootAppBackground.ignoresSafeArea())
    }
}

// MARK: - Private Local Definitions
// This private extension makes this file self-contained to prevent runtime crashes.
private extension Color {
    static let rootAppBackground = Color(red: 242/255, green: 242/255, blue: 242/255)
}


