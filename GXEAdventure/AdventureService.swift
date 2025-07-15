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
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid API URL."])
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
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown server error."
            throw NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Server returned status \(statusCode):\n\(errorBody)"])
        }
        let adventure = try JSONDecoder().decode(Adventure.self, from: data)
        let details = String(data: data, encoding: .utf8) ?? "Could not decode adventure details."
        return (adventure, details)
    }
}
