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
    @State private var isLoading: Bool = false
    @State private var isAdventureReady: Bool = false
    @State private var adventureTitle: String = ""
    @State private var adventureReward: String = ""
    @State private var adventureDetails: String = ""
    
    @State private var apiError: AppError? = nil
    @State private var adventureTask: Task<Void, Error>?
    @State private var selectedAdventureType: String? = "Tour"
    @State private var selectedTheme: String?
    
    // New state to control the presentation of the scavenger hunt view
    @State private var showScavengerHunt: Bool = false
    
    @EnvironmentObject private var locationManager: LocationManager
    
    private var isLocationAuthorized: Bool {
        locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways
    }
    
    private func generateAdventure(isRandom: Bool) {
        isLoading = true
        adventureTask = Task {
            do {
                let (adventure, details) = try await AdventureService.generateAdventure(
                    type: isRandom ? nil : selectedAdventureType,
                    theme: isRandom ? nil : selectedTheme
                )
                self.adventureTitle = adventure.title
                self.adventureReward = adventure.reward
                self.adventureDetails = details
                self.isAdventureReady = true
            } catch {
                if !(error is CancellationError) {
                    if let appError = error as? AppError {
                        self.apiError = appError
                    } else {
                        self.apiError = AppError(message: error.localizedDescription)
                    }
                }
            }
            self.isLoading = false
        }
    }
    
    private func cancelAdventure() {
        adventureTask?.cancel()
        isLoading = false
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isLocationAuthorized {
                    NotificationBannerView()
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Pass the new binding to the HeaderSection
                        HeaderSection(showSettings: $showSettings, showScavengerHunt: $showScavengerHunt)
                        
                        if isLocationAuthorized {
                            StartAdventureSection(isLoading: $isLoading, generateAction: { generateAdventure(isRandom: true) })
                        } else {
                            LocationRequiredSection()
                        }
                        
                        CustomizationSection(
                            selectedAdventureType: $selectedAdventureType,
                            selectedTheme: $selectedTheme,
                            isLoading: $isLoading,
                            isLocationAuthorized: isLocationAuthorized,
                            generateAction: { generateAdventure(isRandom: false) }
                        )
                    }
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .overlay(
            Group {
                if isLoading {
                    LoadingView(isLoading: $isLoading, cancelAction: cancelAdventure)
                } else if isAdventureReady {
                    ReadyView(
                        adventureTitle: $adventureTitle,
                        adventureReward: $adventureReward,
                        fullAdventureDetails: $adventureDetails,
                        dismissAction: { isAdventureReady = false }
                    )
                }
            }
        )
        // Present the ScavengerHuntView as a full screen cover
        .fullScreenCover(isPresented: $showScavengerHunt) {
            ScavengerHuntView()
        }
        .alert(item: $apiError) { error in
            Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
        }
        .onAppear(perform: locationManager.fetchLocationStatus)
    }
}

