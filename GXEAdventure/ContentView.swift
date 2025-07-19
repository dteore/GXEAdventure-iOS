//
//  ContentView.swift
//  GXEAdventure
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import SwiftUI
import CoreLocation

// MARK: - Main Content View
struct ContentView: View {
    @State private var selectedTab: Tab = .adventures
    @State private var showSettings: Bool = false
    
    enum Tab {
        case adventures, rewards
    }
    var body: some View {
        TabView(selection: $selectedTab) {
            AdventuresTabView(showSettings: $showSettings)
                .tabItem { Label("Adventures", systemImage: "map.fill") }
                .tag(Tab.adventures)

            RewardsTabView(showSettings: $showSettings)
                .tabItem { Label("Rewards", systemImage: "star.fill") }
                .tag(Tab.rewards)
        }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .accentColor(.primaryAppColor)
    }
}







// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LocationManager())
            .environmentObject(NotificationManager())
            .preferredColorScheme(.dark)
    }
}

