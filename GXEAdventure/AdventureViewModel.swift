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

    /// Generates a creative and varied prompt for the AI.
    private func generateCreativePrompt(theme: String?, for location: CLLocation?) async -> String {
        let adventureType = "tour"
        var locationInfo = ""

        if let location = location {
            let geocoder = CLGeocoder()
            if let placemark = try? await geocoder.reverseGeocodeLocation(location).first {
                locationInfo = " in \(placemark.locality ?? ""), \(placemark.administrativeArea ?? "")"
            }
        }

        // Select a random persona from the PersonaService
        if let randomPersona = PersonaService.personas.randomElement() {
            // Use the persona's prompt template, replacing placeholders
            return randomPersona.promptTemplate
                .replacingOccurrences(of: "{adventureType}", with: adventureType)
                .replacingOccurrences(of: "{adventureTheme}", with: theme ?? "")
                + locationInfo
        } else {
            // Fallback to a generic prompt if no personas are available
            return "Take me on a \(adventureType) about \(theme ?? "something interesting")\(locationInfo)."
        }
    }

    func generateAdventure(theme: String? = nil) {
        isLoading = true
        adventureTask?.cancel() // Cancel any ongoing task
        adventureTask = Task {
            let currentLocation = await locationManager.userLocation // Capture it here
            do {
                let playerID = "test-player-id-\(UUID().uuidString.prefix(8))"
                
                let promptText = await generateCreativePrompt(theme: theme, for: currentLocation)

                var origin: [String: Double]? = nil
                if let location = currentLocation {
                    origin = ["lat": location.coordinate.latitude, "lng": location.coordinate.longitude]
                }

                let (adventureResponse, _) = try await AdventureService.generateAdventure(
                    prompt: promptText,
                    playerProfileID: playerID,
                    type: "scavenger_hunt",
                    origin: origin,
                    distanceKm: 8,
                    theme: theme
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
