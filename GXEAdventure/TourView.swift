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
    @EnvironmentObject private var adventureViewModel: AdventureViewModel
    @State private var currentNodeIndex: Int = 0 // Track current node displayed
    @State private var showSuccessView = false // New state to control SuccessView presentation
    @State private var showAbandonAlert: Bool = false
    private var tourProgress: Double {
        guard !adventure.nodes.isEmpty else { return 0.0 }
        return Double(currentNodeIndex + 1) / Double(adventure.nodes.count)
    }

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
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
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Text(adventure.nodes[currentNodeIndex].content)
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.8))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(40)
                    .background(Color.headingColor)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)
                    .padding(.top, 25)

                    VStack(spacing: 10) {
                        if currentNodeIndex < adventure.nodes.count - 1 {
                            Button("NEXT") {
                                currentNodeIndex += 1
                            }
                            .buttonStyle(PressableButtonStyle(normalColor: .primaryAppColor, pressedColor: .pressedButtonColor))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        } else if adventure.nodes[currentNodeIndex].type.lowercased() == "ending" {
                            Button("COMPLETE TOUR") {
                                showSuccessView = true
                            }
                            .buttonStyle(PressableButtonStyle(normalColor: .primaryAppColor, pressedColor: .primaryAppColor))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }

                        if currentNodeIndex > 0 {
                            Button(action: {
                                currentNodeIndex -= 1
                            }) {
                                Text("BACK").font(.footnote.weight(.semibold)).frame(maxWidth: .infinity).padding(.vertical, 12)
                            }
                            .foregroundStyle(.gray)
                            .background(.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, 25) // Match padding of the black box content
                    .padding(.top, 20) // Add padding to the top of the button stack
                } // Closing brace for VStack(alignment: .center, spacing: 20)
            } // Closing brace for ScrollView
            .background(Color(red: 0xF1 / 255.0, green: 0xF1 / 255.0, blue: 0xF1 / 255.0).ignoresSafeArea())
            .navigationBarHidden(true)
        } // Closing brace for NavigationView
        .fullScreenCover(isPresented: $showSuccessView) {
            SuccessView(
                rewardAmount: Int(adventure.reward?.filter { "0123456789.".contains($0) }.doubleValue ?? 0),
                adventure: adventure,
                onNewAdventure: {
                    showSuccessView = false
                    dismiss()
                },
                onKeepGoing: { isRandom, type, theme in
                    showSuccessView = false
                    adventureViewModel.presentedAdventure = nil
                    adventureViewModel.generateAdventure(isRandom: isRandom, type: type, theme: theme)
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
    } // Closing brace for public var body: some View
} // Closing brace for public struct TourView: View