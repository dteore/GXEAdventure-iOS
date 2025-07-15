//
//  ScavengerHuntSuccessView.swift
//  GXEAdventure
//
//  Created by YourName on 2025-07-10.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import SwiftUI

struct ScavengerHuntSuccessView: View {
    let rewardAmount: Int
    let onNewAdventure: () -> Void
    let onKeepGoing: () -> Void
    
    @State private var rating: Rating? = nil
    @State private var showFeedbackSheet = false
    
    enum Rating { case like, dislike }

    var body: some View {
        ZStack {
            Color(red: 217/255, green: 217/255, blue: 217/255).ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                Image(systemName: "party.popper.fill").font(.system(size: 80)).foregroundStyle(Color.primaryAppColor)
                Text("Nailed It!").font(.largeTitle.bold()).foregroundStyle(Color.headingColor) // FIX: Explicit color
                Text("Reward: \(rewardAmount) N").font(.headline).foregroundStyle(Color.bodyTextColor) // FIX: Explicit color
                
                VStack(spacing: 15) {
                    Text("Rate this Adventure").font(.headline).foregroundStyle(Color.headingColor) // FIX: Explicit color
                    HStack(spacing: 30) {
                        RatingButton(rating: .like, selection: $rating)
                        RatingButton(rating: .dislike, selection: $rating)
                    }
                    Divider().padding(.vertical, 5)
                    Button("Additional comments or ideas?") { showFeedbackSheet = true }.font(.footnote)
                }
                .padding().background(Color.white).clipShape(RoundedRectangle(cornerRadius: 12)).padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 15) {
                    Button("NEW ADVENTURE") { onNewAdventure() }.buttonStyle(SecondaryActionButtonStyle())
                    Button("KEEP GOING") { onKeepGoing() }.buttonStyle(PressableButtonStyle(normalColor: .primaryAppColor, pressedColor: .pressedButtonColor))
                }
            }
            .padding()
        }
        .sheet(isPresented: $showFeedbackSheet) {
            FeedbackView()
        }
    }
}

private struct RatingButton: View {
    let rating: ScavengerHuntSuccessView.Rating
    @Binding var selection: ScavengerHuntSuccessView.Rating?
    private var isSelected: Bool { selection == rating }
    private var systemName: String { rating == .like ? "hand.thumbsup.fill" : "hand.thumbsdown.fill" }
    private var color: Color {
        switch selection {
        case .like where rating == .like: return .green
        case .dislike where rating == .dislike: return .red
        default: return .gray.opacity(0.6)
        }
    }
    var body: some View {
        Button {
            selection = isSelected ? nil : rating
        } label: {
            Image(systemName: systemName).font(.largeTitle).foregroundStyle(color)
                .scaleEffect(isSelected ? 1.1 : 1.0).animation(.spring(), value: isSelected)
        }
    }
}

private struct SecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote.weight(.semibold)).padding(.vertical, 12).frame(maxWidth: .infinity)
            .foregroundStyle(Color.primaryAppColor).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.primaryAppColor, lineWidth: 2))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct ScavengerHuntSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        ScavengerHuntSuccessView(
            rewardAmount: 150,
            onNewAdventure: { print("New Adventure Tapped") },
            onKeepGoing: { print("Keep Going Tapped") }
        )
    }
}

