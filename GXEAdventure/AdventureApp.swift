//
//  AdventureApp.swift
//  GXEAdventure
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import SwiftUI

// This is the entry point for your SwiftUI application.
// The @main attribute indicates that this struct is the app's entry point.
@main
struct AdventureApp: App {
    // @StateObject creates a single, persistent instance of each manager for the app's entire lifecycle.
    // This is the correct way to initialize shared state and services.
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
/// This separates the view-switching logic from the app's setup and state creation.
struct RootView: View {
    // @AppStorage reads and writes the onboarding status to UserDefaults.
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    // State to control the visibility of the splash screen.
    @State private var showSplash: Bool = true

    var body: some View {
        ZStack {
            // Conditionally display views based on the app's state.
            // This logic was moved from AdventureApp.swift.
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
        // It's best practice to define this color in your `AppStyles.swift`
        // e.g., Color.appBackground, to avoid hardcoding values.
        .background(Color("AppBackground").ignoresSafeArea())
    }
}

