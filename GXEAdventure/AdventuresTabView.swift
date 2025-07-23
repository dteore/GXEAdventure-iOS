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
    
    private var isLocationAuthorized: Bool {
        adventureViewModel.locationManager.authorizationStatus == .authorizedWhenInUse || adventureViewModel.locationManager.authorizationStatus == .authorizedAlways
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isLocationAuthorized {
                    NotificationBannerView()
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HeaderSection(showSettings: $showSettings, showScavengerHunt: $adventureViewModel.showScavengerHunt, generateAction: {
                            adventureViewModel.showScavengerHunt = true
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
        .fullScreenCover(isPresented: $adventureViewModel.isAdventureReady) {
            if let adventure = adventureViewModel.adventure {
                ReadyView(adventure: adventure, generateNewAdventure: { isRandom, type, theme in
                    adventureViewModel.generateAdventure(isRandom: isRandom, type: type, theme: theme)
                }, onStartAdventure: { startedAdventure in
                    adventureViewModel.isAdventureReady = false // Dismiss ReadyView
                    if startedAdventure.type.lowercased() == "tour" {
                        adventureViewModel.showTourView = true
                    } else {
                        adventureViewModel.showScavengerHunt = true
                    }
                })
            }
        }
        .fullScreenCover(isPresented: $adventureViewModel.showScavengerHunt) {
            if let adventure = adventureViewModel.adventure {
                ScavengerHuntView(adventure: adventure, generateNewAdventure: { isRandom, type, theme in
                    adventureViewModel.generateAdventure(isRandom: isRandom, type: type, theme: theme)
                })
            }
        }
        .fullScreenCover(isPresented: $adventureViewModel.showTourView) {
            if let adventure = adventureViewModel.adventure {
                TourView(adventure: adventure, generateNewAdventure: { isRandom, type, theme in
                    adventureViewModel.generateAdventure(isRandom: isRandom, type: type, theme: theme)
                })
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