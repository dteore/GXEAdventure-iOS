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
    @StateObject private var notificationManager: NotificationManager
    @StateObject private var locationManager: LocationManager
    @StateObject private var savedAdventuresManager: SavedAdventuresManager
    @StateObject private var adventureViewModel: AdventureViewModel

    init() {
        let newLocationManager = LocationManager()
        _notificationManager = StateObject(wrappedValue: NotificationManager())
        _locationManager = StateObject(wrappedValue: newLocationManager)
        _savedAdventuresManager = StateObject(wrappedValue: SavedAdventuresManager())
        _adventureViewModel = StateObject(wrappedValue: AdventureViewModel(locationManager: newLocationManager))
        UITabBar.appearance().unselectedItemTintColor = UIColor(Color.gray.opacity(0.6))
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().backgroundColor = UIColor.white
        UINavigationBar.appearance().isTranslucent = false
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(notificationManager)
                .environmentObject(locationManager)
                .environmentObject(savedAdventuresManager)
                .environmentObject(adventureViewModel)
        }
    }
}

/// This view now contains its own private color definition to prevent crashes on launch.
private struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showSplash: Bool = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView(showSplash: $showSplash)
            } else if !hasCompletedOnboarding {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            } else {
                ContentView()
            }
        }
        // FIX: Use the explicitly defined color from the private extension below.
        // This prevents the app from crashing by trying to find a color in the asset catalog.
        .background(Color.rootViewBackgroundColor.ignoresSafeArea())
    }
}

// This private extension makes this file self-contained and guarantees the color is available at launch.
private extension Color {
    static let rootViewBackgroundColor = Color(red: 242/255, green: 242/255, blue: 242/255)
}
