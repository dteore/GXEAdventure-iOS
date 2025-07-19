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
    @State private var showSuccessView = false // New state to control SuccessView presentation
    @State private var currentNodeIndex: Int = 0 // Track current node displayed
    let generateNewAdventure: (Bool) -> Void
    @State private var showAbandonAlert: Bool = false
    private var tourProgress: Double {
        guard !adventure.nodes.isEmpty else { return 0.0 }
        return Double(currentNodeIndex + 1) / Double(adventure.nodes.count)
    }

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // MARK: - Header and Progress Bar
                HStack {
                    Button(action: {
                        showAbandonAlert = true
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .padding(.leading, 10)
                    .padding(.top, 15)
                    
                    Spacer()
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 5) {
                    Text("TOUR PROGRESS")
                        .font(.footnote)
                        .foregroundStyle(Color.bodyTextColor)
                    ProgressView(value: tourProgress)
                        .tint(.primaryAppColor)
                }
                .padding(.horizontal, 25)

                    

                    

                    

                    VStack(spacing: 10) {
                        Text(adventure.title)
                        .font(.title.bold())
                        .foregroundStyle(.white)
                    Text(adventure.nodes[currentNodeIndex].content)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(30)
                    .background(Color.headingColor)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)
                    .padding(.top, 25)

                    if currentNodeIndex < adventure.nodes.count - 1 {
                        Button("Next") {
                            currentNodeIndex += 1
                        }
                        .buttonStyle(PressableButtonStyle(normalColor: .primaryAppColor, pressedColor: .pressedButtonColor))
                        .padding(.horizontal, 50)
                        .padding(.top, 20)
                    } else if adventure.nodes[currentNodeIndex].type.lowercased() == "ending" {
                        Button("Complete Tour") {
                            showSuccessView = true
                        }
                        .buttonStyle(PressableButtonStyle(normalColor: .primaryAppColor, pressedColor: .pressedButtonColor))
                        .padding(.horizontal, 50)
                        .padding(.top, 20)
                    }
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showSuccessView) {
            SuccessView(
                rewardAmount: Int(adventure.reward?.filter { "0123456789.".contains($0) }.doubleValue ?? 0),
                onNewAdventure: {
                    showSuccessView = false
                    dismiss()
                },
                onKeepGoing: { isRandom in
                    showSuccessView = false
                    generateNewAdventure(isRandom)
                },
                dismissParent: { dismiss() }
            )
        }
        .overlay(
            Group {
                if showAbandonAlert {
                    AbandonAdventureConfirmationView(
                        onAbandon: {
                            dismiss()
                            showAbandonAlert = false
                        },
                        onKeepPlaying: {
                            showAbandonAlert = false
                        }
                    )
                }
            }
        )
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
        ), generateNewAdventure: { _ in
            print("Generate New Adventure from TourView Preview")
        })
    }
}
