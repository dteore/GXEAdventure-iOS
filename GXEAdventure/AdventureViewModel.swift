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
    private func generateCreativePrompt(isRandom: Bool, type: String?, theme: String?) -> String {
        if isRandom {
            let randomPrompts = [
                "Take me on a surprising and delightful random adventure. Show me something I'd never find on my own.",
                "I'm feeling spontaneous! You are a guide to hidden gems. Create a unique and unexpected adventure for me.",
                "Generate a random adventure that feels like a story unfolding. What secrets does this place hold?"
            ]
            return randomPrompts.randomElement() ?? "Take me on a random adventure."
        }

        guard let adventureType = type, let adventureTheme = theme else {
            return generateCreativePrompt(isRandom: true, type: nil, theme: nil)
        }

        // Select a random persona from the PersonaService
        if let randomPersona = PersonaService.personas.randomElement() {
            // Use the persona's prompt template, replacing placeholders
            return randomPersona.promptTemplate
                .replacingOccurrences(of: "{adventureType}", with: adventureType)
                .replacingOccurrences(of: "{adventureTheme}", with: adventureTheme)
        } else {
            // Fallback to a generic prompt if no personas are available
            return "Take me on a \(adventureType) about \(adventureTheme)."
        }
    }

    func generateAdventure(isRandom: Bool, type: String? = nil, theme: String? = nil) {
        isLoading = true
        adventureTask?.cancel() // Cancel any ongoing task
        adventureTask = Task {
            let currentLocation = await locationManager.userLocation // Capture it here
            do {
                let playerID = "test-player-id-\(UUID().uuidString.prefix(8))"
                
                // --- PROMPT GENERATION LOGIC UPDATED ---
                // The old if/else block is replaced with a single call to our new creative function.
                let promptText = generateCreativePrompt(isRandom: isRandom, type: type, theme: theme)
                // --- END OF UPDATE ---

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
