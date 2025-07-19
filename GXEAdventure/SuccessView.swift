//
//  SuccessView.swift
//  GXEAdventure
//
//  Created by YourName on 2025-07-10.
//  Copyright © 2025 YourCompany. All rights reserved.
//
import SwiftUI
struct SuccessView: View {
    // The reward amount to display.
    let rewardAmount: Int
    
    // Actions passed from the parent view.
    let onNewAdventure: () -> Void
    let onKeepGoing: (Bool) -> Void
    let dismissParent: () -> Void
    
    // State for the view's interactions.
    @State private var rating: Rating? = nil
    @State private var showFeedbackSheet = false
    
    enum Rating {
        case like, dislike
    }
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // MARK: - Success Message
            Image(systemName: "party.popper.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.primaryAppColor)
            
            Text("Nailed It!")
                .font(.largeTitle.bold())
                .foregroundStyle(Color.headingColor)
            
            Text("Reward: \(rewardAmount) N")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            // MARK: - Rating Section
            VStack {
                Divider()
                
                VStack(spacing: 15) {
                    Text("Rate this Adventure")
                        .font(.headline)
                        .foregroundStyle(Color.bodyTextColor)
                    
                    HStack(spacing: 30) {
                        RatingButton(rating: .like, selection: $rating)
                        RatingButton(rating: .dislike, selection: $rating)
                    }
                    
                    Button("Additional comments or ideas?") {
                        showFeedbackSheet = true
                    }
                    .font(.footnote)
                }
                .padding()
                
                Divider()
            }
            
            Spacer()
            
            // MARK: - Action Buttons
            VStack(spacing: 15) {
                Button("NEW ADVENTURE") {
                    onNewAdventure()
                    dismissParent()
                }
                .buttonStyle(SecondaryActionButtonStyle())
                
                Button("KEEP GOING") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Small delay to allow dismissal
                        onKeepGoing(true)
                        dismissParent()
                    }
                }
                .buttonStyle(PressableButtonStyle(normalColor: .primaryAppColor, pressedColor: .pressedButtonColor))
            }
        }
        .padding()
        .background(Color(red: 0xF1 / 255.0, green: 0xF1 / 255.0, blue: 0xF1 / 255.0).ignoresSafeArea())
        .sheet(isPresented: $showFeedbackSheet) {
            FeedbackView()
        }
        .overlay(
            HStack {
                Button(action: { dismissParent() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                .padding(.leading, 10)
                .padding(.top, 15)
                Spacer()
            }
            , alignment: .topLeading
        )
    }
}
// MARK: - Reusable Child Views & Styles
private struct RatingButton: View {
    let rating: SuccessView.Rating
    @Binding var selection: SuccessView.Rating?
    
    private var isSelected: Bool {
        selection == rating
    }
    
    private var systemName: String {
        rating == .like ? "hand.thumbsup.fill" : "hand.thumbsdown.fill"
    }
    
    private var color: Color {
        switch selection {
        case .like where rating == .like:
            return .green
        case .dislike where rating == .dislike:
            return .red
        default:
            return .gray.opacity(0.6)
        }
    }
    
    var body: some View {
        Button {
            // Allow toggling the selection off.
            selection = isSelected ? nil : rating
        } label: {
            Image(systemName: systemName)
                .font(.largeTitle)
                .foregroundStyle(color)
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .animation(.spring(), value: isSelected)
        }
    }
}
private struct SecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote.weight(.semibold))
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .foregroundStyle(Color.primaryAppColor)
            .background(Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.primaryAppColor, lineWidth: 2)
            )
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

// MARK: - Preview
struct SuccessView_Previews: PreviewProvider {
    static var previews: some View {
        SuccessView(
            rewardAmount: 150,
            onNewAdventure: { print("New Adventure Tapped") },
            onKeepGoing: { _ in
                print("Keep Going Tapped in preview")
            },
            dismissParent: { print("Dismiss Parent from preview") }
        )
    }
}
