//
//  OnboardingView.swift
//  GXEAdventure
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import SwiftUI
import CoreLocation

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @EnvironmentObject private var adventureViewModel: AdventureViewModel
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var onboardingStep: Int = 0

    private let onboardingPages: [OnboardingPageData] = [
        .init(imageName: "figure.walk.motion", title: "APP OVERVIEW", description: "Craft personalized tours, scavenger hunts, and drops. Each is designed to reward you with food & drinks from nearby local businesses."),
        .init(imageName: "location.magnifyingglass", title: "LOCATION", description: "Share your location so we can guide you on personalized scavenger hunts and to exclusive drops around you."),
        .init(imageName: "bell.badge", title: "NOTIFICATIONS", description: "Let us notify you when a drop is about to happen so you don't miss out!"),
        .init(imageName: "party.popper.fill", title: "YOUR ADVENTURE AWAITS!", description: "Get ready to explore rewarding adventures. Please let us know what you think by providing feedback at the end of each adventure.")
    ]

    var body: some View {
        VStack {
            Spacer(minLength: 20)
            
            TabView(selection: $onboardingStep) {
                ForEach(onboardingPages.indices, id: \.self) { index in
                    OnboardingPageView(page: onboardingPages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            Spacer(minLength: 20)

            VStack(spacing: 20) {
                HStack(spacing: 10) {
                    ForEach(0..<onboardingPages.count, id: \.self) { index in
                        Circle()
                            .fill(index == onboardingStep ? Color.primaryAppColor : Color.gray.opacity(0.4))
                            .frame(width: 8, height: 8)
                            .animation(.smooth, value: onboardingStep)
                    }
                }
                
                VStack(spacing: 15) {
                    switch onboardingStep {
                    case 1:
                        Button("ENABLE LOCATION") { adventureViewModel.locationManager.requestLocationPermission() }
                            .buttonStyle(PressableButtonStyle(normalColor: .primaryAppColor, pressedColor: .pressedButtonColor))
                        
                        Button(action: nextStep) {
                             Text("SKIP").fontWeight(.semibold).frame(maxWidth: .infinity).padding(.vertical, 12)
                        }
                        .foregroundStyle(.gray)
                        .background(.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))

                    case 2:
                        Button("ENABLE NOTIFICATION") { notificationManager.requestNotificationPermission() }
                            .buttonStyle(PressableButtonStyle(normalColor: .primaryAppColor, pressedColor: .pressedButtonColor))

                        Button(action: nextStep) {
                             Text("SKIP").fontWeight(.semibold).frame(maxWidth: .infinity).padding(.vertical, 12)
                        }
                        .foregroundStyle(.gray)
                        .background(.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                            
                    case onboardingPages.indices.last:
                        Button("START ADVENTURING!") { completeOnboarding() }
                            .buttonStyle(PressableButtonStyle(normalColor: .primaryAppColor, pressedColor: .pressedButtonColor))

                    default:
                        Button("NEXT") { nextStep() }
                            .buttonStyle(PressableButtonStyle(normalColor: .primaryAppColor, pressedColor: .pressedButtonColor))
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .onChange(of: adventureViewModel.locationManager.authorizationStatus) { _, newStatus in
            if onboardingStep == 1 && newStatus != .notDetermined { nextStep() }
        }
        .onChange(of: notificationManager.authorizationStatus) { _, newStatus in
            if onboardingStep == 2 && newStatus != .notDetermined { nextStep() }
        }
    }

    private func nextStep() {
        withAnimation {
            if onboardingStep < onboardingPages.count - 1 { onboardingStep += 1 }
        }
    }
    
    private func completeOnboarding() {
        hasCompletedOnboarding = true
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingPageData

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: page.imageName)
                .resizable().scaledToFit().frame(height: 120)
                .foregroundStyle(Color.primaryAppColor).padding()

            Text(page.title)
                .font(.title.bold())
                .foregroundStyle(Color.headingColor) // FIX: Explicit color
                .padding(.horizontal)

            Text(page.description)
                .font(.body)
                .foregroundStyle(Color.bodyTextColor) // FIX: Explicit color
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            Spacer()
        }
    }
}

private struct OnboardingPageData: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(hasCompletedOnboarding: .constant(false))
            .environmentObject(AdventureViewModel(locationManager: LocationManager()))
            .environmentObject(NotificationManager())
    }
}

