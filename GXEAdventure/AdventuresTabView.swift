//
//  AdventuresTabView.swift
//  GXEAdventure
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import SwiftUI

// MARK: - Adventures Tab
struct AdventuresTabView: View {
    @Binding var showSettings: Bool
    @State private var selectedAdventureType: String? = nil
    @State private var selectedTheme: String?
    
    @EnvironmentObject private var adventureViewModel: AdventureViewModel
    @EnvironmentObject private var notificationManager: NotificationManager

    private var isLocationAuthorized: Bool {
        adventureViewModel.locationManager.authorizationStatus == .authorizedWhenInUse || adventureViewModel.locationManager.authorizationStatus == .authorizedAlways
    }

    private var isNotificationAuthorized: Bool {
        notificationManager.authorizationStatus == .authorized
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isLocationAuthorized && isNotificationAuthorized {
                    NotificationBannerView()
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HeaderSection(showSettings: $showSettings, showScavengerHunt: .constant(false), generateAction: {
                            // This action is now handled by the StartAdventureSection or CustomizationSection
                        })
                        
                        if isLocationAuthorized {
                            StartAdventureSection(isLoading: $adventureViewModel.isLoading, generateAction: { adventureViewModel.generateAdventure(isRandom: true, type: nil, theme: nil) })
                        } else {
                            LocationRequiredSection()
                        }
                        
                        CustomizationSection(
                            selectedAdventureType: $selectedAdventureType,
                            selectedTheme: $selectedTheme,
                            isLoading: $adventureViewModel.isLoading,
                            isLocationAuthorized: isLocationAuthorized,
                            generateAction: { adventureViewModel.generateAdventure(isRandom: false, type: selectedAdventureType, theme: selectedTheme) }
                        )
                    }
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .overlay(
            Group {
                if adventureViewModel.isLoading {
                    LoadingView(isLoading: $adventureViewModel.isLoading, cancelAction: adventureViewModel.cancelAdventure)
                }
            }
        )
        .fullScreenCover(isPresented: $adventureViewModel.isAdventureReady, onDismiss: {
            // This closure is called after ReadyView is dismissed.
            // If an adventure was prepared, present it now.
            if let adventure = adventureViewModel.adventure {
                adventureViewModel.presentedAdventure = adventure
            }
            adventureViewModel.adventure = nil // Clear the adventure once it's presented or dismissed
        }) {
            if let adventure = adventureViewModel.adventure {
                ReadyView(adventure: adventure, generateNewAdventure: { isRandom, type, theme in
                    adventureViewModel.generateAdventure(isRandom: isRandom, type: type, theme: theme)
                }, onStartAdventure: { startedAdventure in
                    adventureViewModel.isAdventureReady = false // Dismiss ReadyView
                    adventureViewModel.presentedAdventure = startedAdventure
                })
            }
        }
        .fullScreenCover(item: $adventureViewModel.presentedAdventure, onDismiss: {
            // This closure is called after TourView/ScavengerHuntView is dismissed.
            adventureViewModel.presentedAdventure = nil
        }) { adventure in
            if adventure.type.lowercased() == "tour" {
                TourView(adventure: adventure)
            } else {
                ScavengerHuntView(adventure: adventure)
            }
        }
        .alert(item: $adventureViewModel.apiError) { errorWrapper in
            Alert(title: Text("Error"), message: Text(errorWrapper.error.localizedDescription), primaryButton: .default(Text("OK")) { adventureViewModel.apiError = nil }, secondaryButton: .default(Text("Retry")) { 
                if let lastType = selectedAdventureType, let lastTheme = selectedTheme {
                    adventureViewModel.generateAdventure(isRandom: false, type: lastType, theme: lastTheme)
                } else {
                    adventureViewModel.generateAdventure(isRandom: true, type: nil, theme: nil)
                }
                adventureViewModel.apiError = nil
            })
        }
        .tint(.blue)
        .onAppear(perform: adventureViewModel.locationManager.fetchLocationStatus)
    }
}

struct AdventuresTabView_Previews: PreviewProvider {
    static var previews: some View {
        AdventuresTabView(showSettings: .constant(false))
            .environmentObject(LocationManager())
            .environmentObject(NotificationManager())
            .environmentObject(SavedAdventuresManager())
            .environmentObject(AdventureViewModel(locationManager: LocationManager()))
    }
}