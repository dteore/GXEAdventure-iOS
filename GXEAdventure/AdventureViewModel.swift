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
        // Handle the case where the user requests a random adventure.
        if isRandom {
            let randomPrompts = [
                "Take me on a surprising and delightful random adventure. Show me something I'd never find on my own.",
                "I'm feeling spontaneous! You are a guide to hidden gems. Create a unique and unexpected adventure for me.",
                "Generate a random adventure that feels like a story unfolding. What secrets does this place hold?"
            ]
            return randomPrompts.randomElement() ?? "Take me on a random adventure."
        }
        
        // Ensure we have a type and theme for custom adventures.
        guard let adventureType = type, let adventureTheme = theme else {
            // Fallback to a random prompt if type or theme are missing for a custom request.
            return generateCreativePrompt(isRandom: true, type: nil, theme: nil)
        }

        // Define a list of creative prompt templates for custom adventures.
        let promptTemplates = [
            // --- Personas ---
            // Persona: The Passionate Historian
            "You are a passionate local historian with a flair for storytelling. Craft a captivating \(adventureType) about this area's \(adventureTheme). Unveil the hidden stories and secrets that most people miss.",
            // Angle: The Treasure Hunt
            "Generate a unique \(adventureType) that feels like a treasure hunt focused on \(adventureTheme). Guide me to surprising locations, each revealing a different secret or a forgotten piece of history. Make it memorable.",
            // Persona: The Enthusiastic Explorer
            "I'm a curious explorer. Design a fascinating \(adventureType) highlighting this area's \(adventureTheme). Show me the icons, but also the hidden gems. Explain what makes each stop special from an expert's point of view.",
            // Persona: The Witty Critic
            "You are a witty and opinionated expert on \(adventureTheme). Give me an unconventional \(adventureType) of this area, sharing your brutally honest thoughts, surprising hot-takes, and clever observations.",
            // Angle: The Visual Storyteller
            "Create a visually-focused \(adventureType) about the local \(adventureTheme). Describe the scenes in a way that would inspire a photographer. What are the most stunning views and details?",
            // Persona: The Film Director
            "You are a film director scouting locations. Describe a \(adventureType) focused on \(adventureTheme) as if you were setting up scenes for a movie. What's the mood? What are the key shots?",
            // Angle: The Time Traveler
            "I'm a time traveler who has just arrived in this era. Guide me on a \(adventureType) to understand the local \(adventureTheme). Explain things as if I have no context for this time period.",
            // Persona: The Poet
            "As a poet, create a lyrical and evocative \(adventureType) about the \(adventureTheme) of this area. Use descriptive language to capture the feeling and essence of each location.",
            // Angle: The 'Five Senses' Tour
            "Design a \(adventureType) focused on \(adventureTheme) that engages all five senses. What would I see, hear, smell, touch, and even taste (if applicable) at each stop?",
            // Persona: The Secret Agent
            "You are a secret agent on a mission. Your cover is to be on a \(adventureType) learning about \(adventureTheme). Weave in subtle spy-craft observations and coded language into the descriptions.",
            // Angle: The 'Then and Now' Comparison
            "Create a \(adventureType) about \(adventureTheme) that contrasts the past with the present. At each stop, describe what it was like 100 years ago versus what it's like today.",
            // Persona: The Comedian
            "You're a stand-up comedian. Give me a hilarious and sarcastic \(adventureType) about the local \(adventureTheme). Roast the landmarks, tell funny anecdotes, and find the humor in it all.",
            // Angle: The MythBuster
            "Create a \(adventureType) that debunks common myths about the local \(adventureTheme). At each stop, present a popular belief and then reveal the surprising truth.",
            // Persona: The Futurist
            "You are a guide from the year 2200. Take me on a \(adventureType) and explain the local \(adventureTheme) from a future perspective. How will these places be remembered or what will they become?",
            // Persona: The Zen Master
            "As a zen master, guide me on a mindful and meditative \(adventureType) focused on \(adventureTheme). Encourage quiet observation and finding beauty in the small details.",
            // Angle: The 'Controversy' Tour
            "Don't shy away from the drama. Create a \(adventureType) that explores the controversies and heated debates surrounding the local \(adventureTheme). What were the big arguments and scandals?",
            // Persona: The Child's Perspective
            "Explain the local \(adventureTheme) as if you were talking to a curious 10-year-old. Create a fun, imaginative, and easy-to-understand \(adventureType) with lots of 'wow' moments.",
            // Angle: The 'By the Numbers' Tour
            "Create a fascinating \(adventureType) about \(adventureTheme) using surprising statistics and numbers. How old is it? How tall? How many people were involved? Make the data tell a story.",
            // Persona: The Ghost Hunter
            "You are a paranormal investigator. Lead me on a spooky \(adventureType) focused on the \(adventureTheme), but highlight any ghostly legends, eerie feelings, or unexplained phenomena associated with the locations.",
            // Angle: The Food Critic
            "You are a world-renowned food critic. Guide me on a \(adventureType) where the focus is \(adventureTheme), but find a way to connect each stop to a culinary story or a nearby place to eat.",
            // Angle: The Luxury Connoisseur
            "You are a connoisseur of the finer things, a guide to the city's most exclusive secrets. Create a high-end \(adventureType) focused on \(adventureTheme), revealing hidden gems, luxurious details, and stories that aren't in the guidebooks."
        ]
        
        return promptTemplates.randomElement() ?? "Take me on a \(adventureType) about \(adventureTheme)."
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
