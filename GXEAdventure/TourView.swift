//
//  TourView.swift
//  GXEAdventure
//
//  Created by Daniel Teore on 7/16/25.
//


//
//  TourView.swift
//  GXEAdventure
//
//  Created by YourName on 2025-07-16.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import SwiftUI

struct TourView: View {
    // The complete adventure data, passed from the previous view.
    let adventure: Adventure
    
    // Environment property to dismiss the view.
    @Environment(\.dismiss) private var dismiss
    
    // State to track the current step (node) of the tour.
    @State private var currentNodeIndex: Int = 0
    @State private var showSuccessView: Bool = false

    // Computed property to get the current node.
    private var currentNode: AdventureNode {
        adventure.nodes[currentNodeIndex]
    }
    
    // Computed property to calculate the progress.
    private var progress: Double {
        Double(currentNodeIndex + 1) / Double(adventure.nodes.count)
    }

    var body: some View {
        ZStack {
            // Main background for the view.
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 20) {
                // MARK: - Header
                VStack(spacing: 5) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.headline.weight(.bold))
                                .foregroundColor(.primary)
                                .padding(10)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    
                    Text("ADVENTURE PROGRESS")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    ProgressView(value: progress)
                        .tint(.primaryAppColor)
                }
                .padding(.horizontal)

                // MARK: - Content Card
                VStack(alignment: .leading, spacing: 15) {
                    Text("Forge Your Path")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                    
                    Text(nodeTypeTitle(for: currentNode.type))
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color.primaryAppColor)
                    
                    Text(currentNode.content)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(30)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.headingColor)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal)
                
                Spacer()
                
                // MARK: - Action Buttons
                // In a real app, these would be dynamic based on API data.
                // For now, we simulate the choices from the design.
                VStack(spacing: 10) {
                    ChoiceButton(title: "What special trees?", isSelected: false, action: advanceToNextNode)
                    ChoiceButton(title: "Let's talk wildlife", isSelected: true, action: advanceToNextNode)
                    ChoiceButton(title: "Let's talk plants", isSelected: false, action: advanceToNextNode)
                }
                .padding()
            }
        }
        .fullScreenCover(isPresented: $showSuccessView) {
            // This will show when the tour is complete.
            ScavengerHuntSuccessView(
                rewardAmount: Int(adventure.reward) ?? 0,
                onNewAdventure: {
                    showSuccessView = false
                    // Logic to start a new adventure would go here.
                    dismiss()
                },
                onKeepGoing: {
                    showSuccessView = false
                    dismiss()
                }
            )
        }
    }
    
    /// Moves to the next node in the adventure or shows the success screen if it's the last node.
    private func advanceToNextNode() {
        if currentNodeIndex < adventure.nodes.count - 1 {
            currentNodeIndex += 1
        } else {
            showSuccessView = true
        }
    }
    
    /// Returns a display-friendly title based on the node type.
    private func nodeTypeTitle(for type: String) -> String {
        switch type.lowercased() {
        case "discovery", "story":
            return "DID YOU KNOW?"
        case "objective":
            return "YOUR MISSION"
        case "encounter":
            return "BE PREPARED"
        default:
            return "INFORMATION"
        }
    }
}

// MARK: - Reusable Choice Button
private struct ChoiceButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundStyle(isSelected ? .white : Color.bodyTextColor)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(isSelected ? .white : .secondary)
            }
            .padding()
            .background(isSelected ? Color.primaryAppColor : Color(.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}


// MARK: - Preview
struct TourView_Previews: PreviewProvider {
    // Create mock data that matches the API response structure for the preview.
    static let mockAdventure = Adventure(
        id: "preview-id",
        questId: nil,
        title: "Preview Adventure",
        location: "Preview Park",
        type: "tour",
        theme: "general",
        playerId: "preview-player",
        summary: "A test adventure.",
        status: "created",
        nodes: [
            AdventureNode(id: "node-1", type: "discovery", content: "The park boasts a rich collection of trees, a legacy from the time it was officially designated as an arboretum until the 1950s.", metadata: .init(orderIndex: 0, isAnswerNode: false, type: nil, metadata: nil)),
            AdventureNode(id: "node-2", type: "story", content: "Many of these mature, original arboretum trees still stand today, contributing to the park's lush canopy.", metadata: .init(orderIndex: 1, isAnswerNode: false, type: nil, metadata: nil))
        ],
        createdAt: "",
        updatedAt: "",
        waypointCount: 0,
        reward: "100"
    )

    static var previews: some View {
        TourView(adventure: mockAdventure)
    }
}
