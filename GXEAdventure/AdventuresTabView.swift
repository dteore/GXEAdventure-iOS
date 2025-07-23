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
    
    private func generateAdventure(isRandom: Bool, type: String? = nil, theme: String? = nil) {
        isLoading = true
        adventureTask = Task {
            do {
                let playerID = "test-player-id-\(UUID().uuidString.prefix(8))"
                var promptText: String
                if isRandom {
                    promptText = "Take me on a random adventure."
                } else if let adventureType = type {
                    promptText = "Take me on a \(adventureType.replacingOccurrences(of: " (", with: " (").replacingOccurrences(of: ")", with: "")))"
                    if let adventureTheme = theme { promptText += " through a \(adventureTheme) adventure." } else { promptText += " adventure." }
                } else if let adventureTheme = theme {
                    promptText = "Take me on a \(adventureTheme) adventure."
                } else {
                    promptText = "Take me on a random adventure."
                }

                if let location = locationManager.userLocation {
                    promptText += " My current location is latitude \(location.coordinate.latitude) and longitude \(location.coordinate.longitude)."
                }

                let (adventureResponse, _) = try await AdventureService.generateAdventure(
                    prompt: promptText,
                    playerProfileID: playerID,
                    type: isRandom ? nil : type,
                    theme: isRandom ? nil : theme
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
                            StartAdventureSection(isLoading: $isLoading, generateAction: { generateAdventure(isRandom: true, type: nil, theme: nil) })
                        } else {
                            LocationRequiredSection()
                        }
                        
                        CustomizationSection(
                            selectedAdventureType: $selectedAdventureType,
                            selectedTheme: $selectedTheme,
                            isLoading: $isLoading,
                            isLocationAuthorized: isLocationAuthorized,
                            generateAction: { generateAdventure(isRandom: false, type: selectedAdventureType, theme: selectedTheme) }
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
                ReadyView(adventure: adventure, generateNewAdventure: { isRandom, type, theme in
                    generateAdventure(isRandom: isRandom, type: type, theme: theme)
                }, onStartAdventure: { startedAdventure in
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
                ScavengerHuntView(adventure: adventure, generateNewAdventure: { isRandom, type, theme in
                    generateAdventure(isRandom: isRandom, type: type, theme: theme)
                })
            }
        }
        .fullScreenCover(isPresented: $showTourView) {
            if let adventure = adventure {
                TourView(adventure: adventure, generateNewAdventure: { isRandom, type, theme in
                    generateAdventure(isRandom: isRandom, type: type, theme: theme)
                })
            }
        }
        .alert(item: $apiError) { errorWrapper in
            Alert(title: Text("Error"), message: Text(errorWrapper.error.localizedDescription), primaryButton: .default(Text("OK")) { apiError = nil }, secondaryButton: .default(Text("Retry")) { 
                if let lastType = selectedAdventureType, let lastTheme = selectedTheme {
                    generateAdventure(isRandom: false, type: lastType, theme: lastTheme)
                } else {
                    generateAdventure(isRandom: true, type: nil, theme: nil)
                }
                apiError = nil
            })
        }
        .onAppear(perform: locationManager.fetchLocationStatus)
    }
}

