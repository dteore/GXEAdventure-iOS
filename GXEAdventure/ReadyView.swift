//
//  ReadyView.swift
//  GXEAdventure
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import SwiftUI

struct ReadyView: View {
    let adventure: Adventure
    let generateNewAdventure: (Bool, String?, String?) -> Void
    let onStartAdventure: (Adventure) -> Void
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var adventureViewModel: AdventureViewModel

    @State private var showingDetailsAlert: Bool = false

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 20) {
                HStack {
                    // FIX: Button moved to the leading edge (left) with consistent padding.
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .padding(.leading, 10)
                    .padding(.top, 15)

                    Spacer()
                }
                .padding(.horizontal)

                Spacer()

                Image(systemName: "face.smiling.fill")
                    .font(.system(size: 125))
                    .foregroundColor(.primaryAppColor)
                    .padding(.bottom, 20)

                Text("Ready!")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.headingColor) // FIX: Explicit color

                Text(adventure.title)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.bodyTextColor)
                    .multilineTextAlignment(.leading) // Left-align title
                    .frame(maxWidth: .infinity, alignment: .leading) // Force full width and leading alignment
                    .padding(.horizontal, 30) // 30px horizontal padding

                // Display content from the "start" node
                if let startNode = adventure.nodes.first(where: { $0.type == "start" }) {
                    Text(startNode.content)
                        .font(.body)
                        .foregroundStyle(Color.bodyTextColor)
                        .multilineTextAlignment(.leading) // Left-align content
                        .frame(maxWidth: .infinity, alignment: .leading) // Force full width and leading alignment
                        .padding(.horizontal, 30) // 30px horizontal padding
                        .padding(.top, 10)
                } else {
                    Text("No starting information available.")
                        .font(.body)
                        .foregroundStyle(Color.bodyTextColor)
                        .multilineTextAlignment(.leading) // Left-align fallback content
                        .frame(maxWidth: .infinity, alignment: .leading) // Force full width and leading alignment
                        .padding(.horizontal, 30) // 30px horizontal padding
                        .padding(.top, 10)
                }

                

                Button("START") {
                    onStartAdventure(adventure)
                    dismiss()
                }
                .buttonStyle(PressableButtonStyle(
                    normalColor: .primaryAppColor,
                    pressedColor: .pressedButtonColor
                ))
                .padding(.horizontal, 50)
                .padding(.top, 40)

                Spacer()
            }
            .padding(.vertical, 50)
        }
    }
}

struct ReadyView_Previews: PreviewProvider {
    static var previews: some View {
        ReadyView(
            adventure: Adventure(
                id: UUID().uuidString,
                questId: nil,
                title: "A Whispering Woods Tour",
                location: "Forest",
                type: "tour",
                theme: "Nature",
                playerId: "preview-player",
                summary: "A tour through the whispering woods.",
                status: "created",
                nodes: [],
                createdAt: "",
                updatedAt: "",
                waypointCount: 0,
                reward: "100 N"
            ),
            generateNewAdventure: { (isRandom: Bool, type: String?, theme: String?) in
                print("Generate New Adventure from ReadyView Preview. isRandom: \(isRandom), type: \(type ?? "nil"), theme: \(theme ?? "nil")")
            },
            onStartAdventure: { _ in }
        )
    }
}

