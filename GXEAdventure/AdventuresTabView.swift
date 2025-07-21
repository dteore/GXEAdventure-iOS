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
    
    // State for the UI
    @State private var isLoading: Bool = false
    @State private var adventureTitle: String = ""
    @State private var adventureReward: String = ""
    @State private var adventureDetails: String = ""
    
    @State private var apiError: AppError? = nil
    @State private var generatedAdventure: Adventure?
    @State private var showScavengerHunt: Bool = false
    @State private var showTourView: Bool = false
    @State private var showReadyView: Bool = false // New state to control ReadyView presentation
    
    // State for user selections
    @State private var selectedAdventureType: String? = "Tour"
    @State private var selectedTheme: String?
    
    @State private var adventureTask: Task<Void, Error>?
    
    @EnvironmentObject private var locationManager: LocationManager
    
    private var isLocationAuthorized: Bool {
        locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways
    }
    
    private func generateAdventure(isRandom: Bool) {
        print("generateAdventure called. isRandom: \(isRandom)")
        isLoading = true
        adventureTask = Task {
            do {
                let playerID = "test-player-id-\(UUID().uuidString.prefix(8))"
                var promptText: String
                if isRandom {
                    promptText = "Take me on a random adventure."
                } else if let type = selectedAdventureType, let theme = selectedTheme {
                    promptText = "Take me on a \(type) through a \(theme) adventure."
                } else if let type = selectedAdventureType {
                    promptText = "Take me on a \(type) adventure."
                } else if let theme = selectedTheme {
                    promptText = "Take me on a \(theme) adventure."
                } else {
                    promptText = "Take me on an adventure." // Fallback if no specific type or theme is selected and not random
                }

                if let userLocation = locationManager.userLocation {
                    promptText += " using my current location: latitude \(userLocation.coordinate.latitude), longitude \(userLocation.coordinate.longitude)."
                }
                let (adventure, _) = try await AdventureService.generateAdventure(
                    prompt: promptText,
                    playerProfileID: playerID,
                    type: isRandom ? nil : selectedAdventureType,
                    theme: isRandom ? nil : selectedTheme
                )
                
                self.generatedAdventure = adventure // Assign the generated adventure
                
                print("AdventuresTabView: Decoded Adventure Object: \(adventure)") // Diagnostic print
                
                print("AdventuresTabView: Assigning adventureTitle...")
                self.adventureTitle = adventure.title
                print("AdventuresTabView: adventureTitle assigned: \(self.adventureTitle)")
                print("AdventuresTabView: Assigning adventureReward. Raw reward: \(adventure.reward)")
                let numericRewardString = adventure.reward?.filter { "0123456789.".contains($0) } ?? "0"
                self.adventureReward = numericRewardString.isEmpty ? "0" : numericRewardString // Ensure it's not empty
                print("AdventuresTabView: adventureReward assigned: \(self.adventureReward)")
                print("AdventuresTabView: Assigning adventureDetails...")
                self.adventureDetails = adventure.nodes.isEmpty ? "No details available." : adventure.nodes.map { $0.content }.joined(separator: "\n\n")
                print("AdventuresTabView: adventureDetails assigned: \(self.adventureDetails)")
                
                print("Generated Adventure Type: \(adventure.type)")
                
                // Always show ReadyView first
                self.showReadyView = true
                print("AdventuresTabView: ReadyView should be shown.")
                
            } catch {
                print("AdventuresTabView: Error in generateAdventure: \(error)") // New diagnostic print
                if let nsError = error as? NSError, nsError.domain == NSURLErrorDomain, nsError.code == NSURLErrorCancelled {
                    self.apiError = nil // Suppress error for cancelled tasks
                } else if let appError = error as? AppError {
                    self.apiError = appError
                } else {
                    self.apiError = AppError(message: error.localizedDescription)
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
                        HeaderSection(showSettings: $showSettings, showScavengerHunt: $showScavengerHunt, generateAction: { generateAdventure(isRandom: true) })
                        
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
        // Present the ReadyView
        .fullScreenCover(isPresented: $showReadyView, onDismiss: {
            if let generated = generatedAdventure {
                if generated.type.lowercased() == "scavenger-hunt" {
                    self.showScavengerHunt = true
                    print("AdventuresTabView: Launching ScavengerHuntView from ReadyView onDismiss.")
                } else if generated.type.lowercased() == "tour" {
                    self.showTourView = true
                    print("AdventuresTabView: Launching TourView from ReadyView onDismiss.")
                }
            }
        }) {
            if let adventure = generatedAdventure {
                ReadyView(
                    adventureTitle: adventureTitle,
                    adventureReward: adventureReward,
                    fullAdventureDetails: adventureDetails,
                    dismissAction: { self.showReadyView = false }
                )
            } else {
                // Fallback or error handling if generatedAdventure is unexpectedly nil
                Text("Error: Adventure data not available.")
            }
        }
        // Present the ScavengerHuntView
        .fullScreenCover(isPresented: $showScavengerHunt) {
            if let adventure = generatedAdventure {
                ScavengerHuntView(adventure: adventure, generateNewAdventure: generateAdventure)
            }
        }
        // Present the TourView
        .fullScreenCover(isPresented: $showTourView) {
            if let adventure = generatedAdventure {
                TourView(adventure: adventure, generateNewAdventure: generateAdventure)
            }
        }
        .alert(item: $apiError) { error in
            Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
        }
        .onAppear(perform: locationManager.fetchLocationStatus)
    }
}