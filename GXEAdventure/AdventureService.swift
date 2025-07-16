//
//  AdventureService.swift
//  GXEAdventure
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import Foundation

// MARK: - Networking Models and Service
struct Adventure: Codable {
    let title: String
    let reward: String
}

struct AdventureService {
    static func generateAdventure(type: String?, theme: String?) async throws -> (adventure: Adventure, details: String) {
        guard let url = URL(string: "https://nvrse-ai.fly.dev/api/adventures") else {
            throw AppError(message: "Invalid API URL.")
        }
        let playerID = "test-player-id-\(UUID().uuidString.prefix(8))"
        var promptText = "Take me on a random adventure."
        if let type = type {
            promptText = "Take me on a \(type.replacingOccurrences(of: " (+", with: " (").replacingOccurrences(of: ")", with: "")))"
            if let theme = theme { promptText += " through a \(theme) adventure." } else { promptText += " adventure." }
        } else if let theme = theme { promptText = "Take me on a \(theme) adventure." }
        let requestBody: [String: Any] = ["prompt": promptText, "playerProfile": ["id": playerID]]
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Attempt to decode a common error structure from the API.
        struct DecodableError: Decodable, LocalizedError {
            let message: String
            var errorDescription: String? { return message }
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError(message: "Invalid HTTP response.")
        }

        if !(200...299).contains(httpResponse.statusCode) {
            // Try to decode a specific error message from the server response.
            if let decodedError = try? JSONDecoder().decode(DecodableError.self, from: data) {
                throw AppError(message: decodedError.message)
            } else {
                // Fallback for unexpected error formats or non-JSON errors.
                let errorBody = String(data: data, encoding: .utf8) ?? "Unknown server error."
                throw AppError(message: "Server returned status \(httpResponse.statusCode):\n\(errorBody)")
            }
        }
        
        // Log the raw data for debugging purposes to ensure it matches the 'Adventure' struct.
        print("Raw API Response: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")

        let adventure = try JSONDecoder().decode(Adventure.self, from: data)
        let details = String(data: data, encoding: .utf8) ?? "Could not decode adventure details."
        return (adventure, details)
    }
}
