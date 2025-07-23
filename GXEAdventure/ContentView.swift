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
    @EnvironmentObject private var adventureViewModel: AdventureViewModel
    
    @State private var showSettings: Bool = false
    
    enum Tab {
        case adventures, history
    }

    var body: some View {
        TabView {
            AdventuresTabView(showSettings: $showSettings)
                .tabItem {
                    Label("Adventures", systemImage: "map.fill")
                        .padding(.top, 25)
                }
                .tag(Tab.adventures)

            HistoryTabView(showSettings: $showSettings)
                .tabItem {
                    Label("History", systemImage: "book.closed.fill")
                        .padding(.top, 25)
                }
                .tag(Tab.history)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .tint(.primaryAppColor)
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LocationManager())
            .environmentObject(NotificationManager())
            .environmentObject(AdventureViewModel(locationManager: LocationManager()))
            .environmentObject(SavedAdventuresManager())
            .preferredColorScheme(.dark)
    }
}
