//
//  RewardsTabView.swift
//  GXEAdventure
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import SwiftUI

// MARK: - Main Rewards Tab View
struct RewardsTabView: View {
    @Binding var showSettings: Bool

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    RewardsHeaderView(showSettings: $showSettings)
                    RewardCardsSection()
                    MyRedeemablesSection()
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Child Views for Rewards Tab

private struct RewardsHeaderView: View {
    @Binding var showSettings: Bool
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 5) {
                Text("You're awesome.\nGet rewards.")
                    .font(.system(size: 36, weight: .bold))
                    .lineSpacing(-5)
                    .foregroundStyle(Color.headingColor)
                    .padding(.top, 30)

                Text("Earn N by completing adventures.\nSpend your N on exclusive treats from local Trinity Bellwoods businesses.")
                    .font(.body)
                    .foregroundStyle(Color.bodyTextColor)
                    .padding(.top, 5)

                Group {
                    Text("WARNING: LIMITED INVENTORY!")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.green)
                        .padding(.top, 10)

                    Text("210 N")
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color.headingColor)
                        .padding(.top, 15)

                    Text("YOU ARE IN THE TOP 15% OF ALL PLAYERS")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.bodyTextColor)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 45)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(red: 217/255, green: 217/255, blue: 217/255))

            SettingsButton(showSettings: $showSettings)
        }
    }
}

private struct RewardCardsSection: View {
    // Placeholder data for available rewards
    let rewards: [Reward] = [
        Reward(title: "Pre Roll", cost: "50 N", status: "DROP EXCLUSIVE", statusColor: .red),
        Reward(title: "Fish & Chips", cost: "250 N", status: "SOLD OUT!", isSoldOut: true, statusColor: .red),
        Reward(title: "Contest Entry", cost: "50 N", status: "UNLIMITED", statusColor: .green),
        Reward(title: "Ice Cream", cost: "100 N", status: "15 LEFT", statusColor: .green)
    ]
    
    // Define the grid layout
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]

    var body: some View {
        VStack(alignment: .leading) {
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(rewards) { reward in
                    RewardCardView(reward: reward)
                }
            }
        }
        .padding(.horizontal)
    }
}

private struct RewardCardView: View {
    let reward: Reward

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(reward.title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(Color.headingColor)

            Text(reward.cost)
                .font(.subheadline)
                .foregroundStyle(Color.bodyTextColor)

            if let status = reward.status {
                Text(status)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(reward.statusColor)
            }
            
            Spacer()

            Button("More Info") {
            }
            .buttonStyle(PressableButtonStyle(
                normalColor: reward.isSoldOut ? .gray.opacity(0.5) : .primaryAppColor,
                pressedColor: reward.isSoldOut ? .gray.opacity(0.7) : .pressedButtonColor
            ))
            .disabled(reward.isSoldOut)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

private struct MyRedeemablesSection: View {
    // Placeholder data for user's redeemable items
    let redeemables: [Redeemable] = [
        Redeemable(name: "FISH & CHIPS", pin: "5237"),
        Redeemable(name: "PRE ROLL", pin: "7420"),
        Redeemable(name: "FISH & CHIPS", pin: "5795"),
        Redeemable(name: "ICE CREAM", pin: "8501")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("My Redeemables")
                .font(.title.bold())
                .foregroundStyle(Color.headingColor)

            Text("To redeem your rewards please visit {add location}.")
                .font(.subheadline)
                .foregroundStyle(Color.bodyTextColor)

            ForEach(redeemables) { item in
                RedeemableItemView(item: item)
            }
        }
        .padding()
        .background(Color.white)
    }
}

private struct RedeemableItemView: View {
    let item: Redeemable

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Color.headingColor)
                Text("PIN: \(item.pin)")
                    .font(.subheadline)
                    .foregroundStyle(Color.bodyTextColor)
            }
            Spacer()
        }
        .padding()
        .background(Color.appBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}


// MARK: - Data Models
private struct Reward: Identifiable {
    let id = UUID()
    let title: String
    let cost: String
    let status: String?
    let isSoldOut: Bool
    let statusColor: Color
    
    init(title: String, cost: String, status: String? = nil, isSoldOut: Bool = false, statusColor: Color = .green) {
        self.title = title
        self.cost = cost
        self.status = status
        self.isSoldOut = isSoldOut
        self.statusColor = statusColor
    }
}

private struct Redeemable: Identifiable {
    let id = UUID()
    let name: String
    let pin: String
}


// MARK: - Preview
struct RewardsTabView_Previews: PreviewProvider {
    static var previews: some View {
        RewardsTabView(showSettings: .constant(false))
    }
}

