//
//  TourView.swift
//  GXEAdventure
//
//  Created by YourName on 2025-07-16.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import SwiftUI

public struct TourView: View {
    let adventure: Adventure
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 10)
                        .padding(.top, 15)
                    }
                    .padding(.horizontal)

                    Text(adventure.title)
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color.headingColor)
                        .padding(.horizontal)

                    Text("Reward: \(adventure.reward)")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Color.bodyTextColor)
                        .padding(.horizontal)

                    Text("Tour Details:")
                        .font(.title3.bold())
                        .foregroundStyle(Color.headingColor)
                        .padding(.horizontal)
                        .padding(.top, 20)

                    Text(adventure.nodes.map { $0.content }.joined(separator: "\n\n"))
                        .font(.body)
                        .foregroundStyle(Color.bodyTextColor)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

struct TourView_Previews: PreviewProvider {
    static var previews: some View {
        TourView(adventure: Adventure(
            id: UUID().uuidString,
            questId: nil,
            title: "Preview Tour: Historic Landmarks",
            location: "City Center",
            type: "tour",
            theme: "History",
            playerId: "preview-player",
            summary: "A preview of a historical walking tour.",
            status: "created",
            nodes: [
                AdventureNode(id: UUID().uuidString, type: "story", content: "Welcome to the heart of the city! Our tour begins at the iconic Town Hall.", metadata: AdventureNodeMetadata(orderIndex: 0, isAnswerNode: false, type: nil, metadata: nil)),
                AdventureNode(id: UUID().uuidString, type: "discovery", content: "Next, we'll explore the grand architecture of the old library.", metadata: AdventureNodeMetadata(orderIndex: 1, isAnswerNode: false, type: nil, metadata: nil)),
                AdventureNode(id: UUID().uuidString, type: "reflection", content: "Reflect on the city's past as we stand before the ancient city walls.", metadata: AdventureNodeMetadata(orderIndex: 2, isAnswerNode: false, type: nil, metadata: nil))
            ],
            createdAt: "",
            updatedAt: "",
            waypointCount: 0,
            reward: "75 N"
        ))
    }
}