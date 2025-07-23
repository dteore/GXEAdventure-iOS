//
//  AdventureViewModel.swift
//  GXEAdventure
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import Foundation
import SwiftUI
import CoreLocation

class AdventureViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var isAdventureReady: Bool = false
    @Published var adventure: Adventure?
    @Published var apiError: ErrorWrapper? = nil
    @Published var presentedAdventure: Adventure?
    @Published var isPresentingAdventure: Bool = false

    private var adventureTask: Task<Void, Error>?
    let locationManager: LocationManager

    init(locationManager: LocationManager) {
        self.locationManager = locationManager
    }

    func generateAdventure(isRandom: Bool, type: String? = nil, theme: String? = nil) {
        isLoading = true
        adventureTask?.cancel() // Cancel any ongoing task
        adventureTask = Task {
            let currentLocation = await locationManager.userLocation // Capture it here
            do {
                let playerID = "test-player-id-\(UUID().uuidString.prefix(8))"
                var promptText: String
                if isRandom {
                    promptText = "Take me on a random adventure."
                } else if let adventureType = type {
                    promptText = "Take me on \(adventureType.replacingOccurrences(of: " (", with: " (").replacingOccurrences(of: ")", with: ""))"
                    if let adventureTheme = theme { promptText += " through a \(adventureTheme) adventure." } else { promptText += " adventure." }
                } else if let adventureTheme = theme {
                    promptText = "Take me on a \(adventureTheme) adventure."
                } else {
                    promptText = "Take me on a random adventure."
                }

                var origin: [String: Double]? = nil
                if let location = currentLocation {
                    origin = ["lat": location.coordinate.latitude, "lng": location.coordinate.longitude]
                }

                let (adventureResponse, _) = try await AdventureService.generateAdventure(
                    prompt: promptText,
                    playerProfileID: playerID,
                    type: isRandom ? nil : type,
                    origin: origin,
                    theme: isRandom ? nil : theme
                )
                
                await MainActor.run {
                    self.adventure = adventureResponse
                    self.isAdventureReady = true
                }
                
            } catch {
                let isCancellation = error is CancellationError || (error as? URLError)?.code == .cancelled
                if !isCancellation {
                    await MainActor.run {
                        self.apiError = ErrorWrapper(error: error)
                    }
                }
            }
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    func cancelAdventure() {
        adventureTask?.cancel()
        isLoading = false
    }
}
