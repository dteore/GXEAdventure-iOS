//
//  AdventureService.swift
//  GXEAdventure
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import Foundation

// MARK: - Networking Models and Service

public struct AdventureNodeMetadata: Codable {
    let orderIndex: Int
    let isAnswerNode: Bool
    let type: String?
    let metadata: String?
}

public struct AdventureNode: Codable, Identifiable {
    public let id: String
    let type: String
    let content: String
    let metadata: AdventureNodeMetadata
}

public struct Adventure: Codable {
    public let id: String
    let questId: String?
    let title: String
    let location: String
    let type: String
    let theme: String?
    let playerId: String
    let summary: String
    let status: String
    let nodes: [AdventureNode]
    let createdAt: String
    let updatedAt: String
    let waypointCount: Int
    let reward: String?
}

struct AdventureResponse: Decodable {
    let adventure: Adventure
}

struct AdventureService {
    static func generateAdventure(prompt: String, playerProfileID: String, type: String? = nil, origin: [String: Double]? = nil, distanceKm: Double? = nil, segments: Int? = nil, theme: String? = nil) async throws -> (adventure: Adventure, details: String) {
        guard let url = URL(string: "https://nvrse-ai.fly.dev/api/adventures") else {
            throw AppError(message: "Invalid API URL.", errorCode: 1001)
        }
        
        var requestBody: [String: Any] = [
            "prompt": prompt,
            "playerProfile": ["id": playerProfileID]
        ]
        
        if let type = type {
            requestBody["type"] = type
        }
        if let origin = origin {
            requestBody["origin"] = origin
        }
        // Apply default values as per schema if not provided
        requestBody["distancekm"] = distanceKm ?? 3.0
        requestBody["segments"] = segments ?? 6
        
        if let theme = theme {
            requestBody["theme"] = theme
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Log the request body for debugging
        print("API Request Body: \(String(data: jsonData, encoding: .utf8) ?? "Unable to convert request body to string")")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Attempt to decode a common error structure from the API.
        struct DecodableError: Decodable, LocalizedError {
            let message: String
            var errorDescription: String? { return message }
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError(message: "Invalid HTTP response.", errorCode: 1002)
        }

        if !(200...299).contains(httpResponse.statusCode) {
            // Try to decode a specific error message from the server response.
            if let decodedError = try? JSONDecoder().decode(DecodableError.self, from: data) {
                throw AppError(message: decodedError.message, errorCode: httpResponse.statusCode)
            } else {
                // Fallback for unexpected error formats or non-JSON errors.
                let errorBody = String(data: data, encoding: .utf8) ?? "Unknown server error."
                throw AppError(message: "Server returned status \(httpResponse.statusCode):\n\(errorBody)", errorCode: httpResponse.statusCode)
            }
        }
        
        // Log the raw data for debugging purposes to ensure it matches the 'Adventure' struct.
        print("Raw API Response: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")

        do {
            let responseData = try JSONDecoder().decode(AdventureResponse.self, from: data)
            let adventure = responseData.adventure
            print("Decoded Adventure Object: \(adventure)") // Diagnostic print
            let details = adventure.nodes.map { $0.content }.joined(separator: "\n\n")
            return (adventure, details)
        } catch {
            print("AdventureService: Decoding Error: \(error)") // New diagnostic print
            throw AppError(message: "Failed to decode adventure data: \(error.localizedDescription)", errorCode: 1003)
        }
    }
}