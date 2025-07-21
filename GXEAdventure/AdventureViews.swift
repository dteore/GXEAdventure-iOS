//
//  AdventureViews.swift
//  GXEAdventure
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import SwiftUI

// MARK: - Reusable Child Views
struct HeaderSection: View {
    @Binding var showSettings: Bool
    @Binding var showScavengerHunt: Bool
    let generateAction: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Let's go on an adventure.")
                    .font(.system(size: 36, weight: .bold))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .lineSpacing(-5)
                    .foregroundStyle(Color.headingColor)
                    .padding(.top, 30)

                Text("Uncover Trinity Bellwoods secrets! Adventures are 5-15m: scavenger hunts get you moving, while tours offer a relaxed pace.")
                    .font(.body)
                    .foregroundStyle(Color.bodyTextColor)
                    .padding(.top, 5)
                
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.primaryAppColor)
                .padding(.top, 8)

            }.padding(.horizontal, 20).padding(.bottom, 45)
            Button { showSettings = true } label: {
                Image(systemName: "gearshape").font(.title2).foregroundStyle(Color.headingColor).padding(.top, 25).padding(.trailing, 20)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 217/255, green: 217/255, blue: 217/255))
    }
}

struct LocationRequiredSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Location Required for Adventure!")
                .font(.title.bold())
                .foregroundStyle(Color.headingColor)
            Text("To guide you on tours and verify scavenger hunt progress, we need your location. Please enable it in Settings.")
                .font(.subheadline)
                .foregroundStyle(Color.bodyTextColor)
                .padding(.top, 5)
                .padding(.bottom, 25)
            Button("ENABLE LOCATION") {
                if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
            }.buttonStyle(PressableButtonStyle(normalColor: .primaryAppColor, pressedColor: .pressedButtonColor))
        }.padding(.horizontal).padding(.vertical, 25)
    }
}

struct StartAdventureSection: View {
    @Binding var isLoading: Bool
    let generateAction: () -> Void
    var body: some View {
        VStack(alignment: .leading) {
            Text("Start your Adventure")
                .font(.title.bold())
                .foregroundStyle(Color.headingColor)
            Text("Choose a random adventure, or customize yours with types and themes below.")
                .font(.subheadline)
                .foregroundStyle(Color.bodyTextColor)
                .padding(.bottom, 25)
            Button("GENERATE ADVENTURE") {
                isLoading = true
                generateAction()
            }.buttonStyle(PressableButtonStyle(normalColor: .primaryAppColor, pressedColor: .pressedButtonColor))
        }.padding(.horizontal).padding(.vertical, 25).background(Color(red: 0xF1 / 255.0, green: 0xF1 / 255.0, blue: 0xF1 / 255.0))
    }
}

struct CustomizationSection: View {
    @Binding var selectedAdventureType: String?
    @Binding var selectedTheme: String?
    @Binding var isLoading: Bool
    let isLocationAuthorized: Bool
    let generateAction: () -> Void
    private let themes = ["History", "Culture", "Landmarks", "Nature", "Hidden Gems", "Ghost Stories"]
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Customization")
                .font(.title.bold())
                .foregroundStyle(Color.headingColor)
            Text("Type")
                .font(.headline)
                .foregroundStyle(Color.headingColor)
            HStack(spacing: 15) {
                TypeSelectionButton(title: "Tour", selection: $selectedAdventureType)
                TypeSelectionButton(title: "Scavenger Hunt", selection: $selectedAdventureType)
                Spacer()
            }
            Text("Theme")
                .font(.headline)
                .foregroundStyle(Color.headingColor)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 10)], spacing: 10) {
                ForEach(themes, id: \.self) { theme in ThemeSelectionButton(title: theme, selection: $selectedTheme) }
            }
            Button("GENERATE ADVENTURE") {
                isLoading = true
                generateAction()
            }
            .buttonStyle(PressableButtonStyle(normalColor: isLocationAuthorized ? .primaryAppColor : .gray.opacity(0.5), pressedColor: isLocationAuthorized ? .pressedButtonColor : .gray.opacity(0.7)))
            .disabled(!isLocationAuthorized)
            .padding(.top, 50)
        }
        .padding()
        .background(Color(red: 0xF1 / 255.0, green: 0xF1 / 255.0, blue: 0xF1 / 255.0))
        .opacity(isLocationAuthorized ? 1.0 : 0.5)
    }
}

struct TypeSelectionButton: View {
    let title: String
    @Binding var selection: String?
    var body: some View {
        Button(action: { selection = title }) {
            HStack {
                Image(systemName: selection == title ? "circle.inset.filled" : "circle")
                Text(title)
            }
        }
        .buttonStyle(SelectableButtonStyle(isSelected: selection == title))
    }
}

struct ThemeSelectionButton: View {
    let title: String
    @Binding var selection: String?
    var body: some View {
        Button(action: { selection = title }) {
            HStack {
                Image(systemName: selection == title ? "checkmark.square.fill" : "square")
                Text(title)
                Spacer()
            }
        }
        .buttonStyle(SelectableButtonStyle(isSelected: selection == title))
    }
}

struct NotificationBannerView: View {
    @State private var showBanner = true
    var body: some View {
        if showBanner {
            HStack(alignment: .center) {
                Image(systemName: "bell.fill").font(.title).foregroundStyle(.white)
                VStack(alignment: .leading, spacing: 2) {
                    Text("DROP HAPPENING NOW!").font(.system(size: 16, weight: .bold))
                    Text("A challenging adventure with an EXCLUSIVE reward. Don't miss out!").font(.system(size: 13)).lineLimit(2)
                    Text("Start the adventure now!").font(.system(size: 12, weight: .semibold))
                }.foregroundStyle(.white)
                Spacer()
                Button(action: { withAnimation { showBanner = false } }) {
                    Image(systemName: "xmark.circle.fill").font(.title2).foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding()
            .background(LinearGradient(colors: [.primaryAppColor, .primaryAppColor], startPoint: .topLeading, endPoint: .bottomTrailing))
        }
    }
}

