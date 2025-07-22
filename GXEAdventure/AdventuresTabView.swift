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
    @State private var adventure: Adventure?
    
    @State private var apiError: ErrorWrapper? = nil
    @State private var adventureTask: Task<Void, Error>?
    @State private var selectedAdventureType: String? = nil
    @State private var selectedTheme: String?
    
    @State private var showScavengerHunt: Bool = false
    @State private var showTourView: Bool = false
    
    @EnvironmentObject private var locationManager: LocationManager
    
    private var isLocationAuthorized: Bool {
        locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways
    }
    
    private func generateAdventure(isRandom: Bool) {
        isLoading = true
        adventureTask = Task {
            do {
                let playerID = "test-player-id-\(UUID().uuidString.prefix(8))"
                var promptText: String
                if let type = selectedAdventureType, !isRandom {
                    promptText = "Take me on a \(type.replacingOccurrences(of: " (", with: " (").replacingOccurrences(of: ")", with: "")))"
                    if let theme = selectedTheme { promptText += " through a \(theme) adventure." } else { promptText += " adventure." }
                } else if let theme = selectedTheme, !isRandom { promptText = "Take me on a \(theme) adventure." }
                else { promptText = "Take me on a random adventure." }

                if let location = locationManager.userLocation {
                    promptText += " My current location is latitude \(location.coordinate.latitude) and longitude \(location.coordinate.longitude)."
                }

                let (adventureResponse, _) = try await AdventureService.generateAdventure(
                    prompt: promptText,
                    playerProfileID: playerID,
                    type: isRandom ? nil : selectedAdventureType,
                    theme: isRandom ? nil : selectedTheme
                )
                
                self.adventure = adventureResponse
                self.isAdventureReady = true
                
            } catch {
                // Ignore cancellation errors, which are expected when the user dismisses the loading view.
                let isCancellation = error is CancellationError || (error as? URLError)?.code == .cancelled
                if !isCancellation {
                    self.apiError = ErrorWrapper(error: error)
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
                        HeaderSection(showSettings: $showSettings, showScavengerHunt: $showScavengerHunt, generateAction: {
                            showScavengerHunt = true
                        })
                        
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
                }
            }
        )
        .fullScreenCover(isPresented: $isAdventureReady) {
            if let adventure = adventure {
                ReadyView(adventure: adventure, generateNewAdventure: generateAdventure, onStartAdventure: { startedAdventure in
                    isAdventureReady = false // Dismiss ReadyView
                    if startedAdventure.type.lowercased() == "tour" {
                        showTourView = true
                    } else {
                        showScavengerHunt = true
                    }
                })
            }
        }
        .fullScreenCover(isPresented: $showScavengerHunt) {
            if let adventure = adventure {
                ScavengerHuntView(adventure: adventure, generateNewAdventure: generateAdventure)
            }
        }
        .fullScreenCover(isPresented: $showTourView) {
            if let adventure = adventure {
                TourView(adventure: adventure, generateNewAdventure: generateAdventure)
            }
        }
        .alert(item: $apiError) { errorWrapper in
            Alert(title: Text("Error"), message: Text(errorWrapper.error.localizedDescription), dismissButton: .default(Text("OK")))
        }
        .onAppear(perform: locationManager.fetchLocationStatus)
    }
}

