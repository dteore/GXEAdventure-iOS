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
    // Binding to mark onboarding as complete, passed from the root of the app.
    @Binding var hasCompletedOnboarding: Bool
    
    // EnvironmentObjects for permission managers.
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var notificationManager: NotificationManager

    // @State tracks the currently visible page in the TabView.
    @State private var onboardingStep: Int = 0

    // The data for each page of the onboarding flow.
    private let onboardingPages: [OnboardingPageData] = [
        .init(
            imageName: "figure.walk.motion",
            title: "APP OVERVIEW",
            description: "Craft personalized tours, scavenger hunts, and drops. Each is designed to reward you with food & drinks from nearby local businesses."
        ),
        .init(
            imageName: "location.magnifyingglass",
            title: "LOCATION",
            description: "Share your location so we can guide you on personalized scavenger hunts and to exclusive drops around you."
        ),
        .init(
            imageName: "bell.badge",
            title: "NOTIFICATIONS",
            description: "Let us notify you when a drop is about to happen so you don't miss out!"
        ),
        .init(
            imageName: "party.popper.fill",
            title: "YOUR ADVENTURE AWAITS!",
            description: "Get ready to explore rewarding adventures. Please let us know what you think by providing feedback at the end of each adventure."
        )
    ]

    var body: some View {
        VStack {
            // A spacer at the top to push content down slightly from the edge.
            Spacer(minLength: 20)
            
            // A TabView with the .page style creates a swipeable user interface.
            TabView(selection: $onboardingStep) {
                ForEach(onboardingPages.indices, id: \.self) { index in
                    OnboardingPageView(page: onboardingPages[index])
                        .tag(index) // Each page is tagged with its index.
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never)) // Hides the default dot indicator.
            
            // A spacer to ensure the content above has flexible space,
            // pushing the controls to the bottom.
            Spacer(minLength: 20)

            // The controls (indicator and buttons) are grouped at the bottom.
            VStack(spacing: 20) {
                // Custom Page Indicator
                HStack(spacing: 10) {
                    ForEach(0..<onboardingPages.count, id: \.self) { index in
                        Circle()
                            .fill(index == onboardingStep ? Color.primaryAppColor : Color.gray.opacity(0.4))
                            .frame(width: 8, height: 8)
                            .animation(.smooth, value: onboardingStep)
                    }
                }
                
                // Action Buttons
                VStack(spacing: 15) {
                    // The buttons dynamically change based on the current onboarding step.
                    switch onboardingStep {
                    case 1: // Location Page
                        Button("ENABLE LOCATION") {
                            locationManager.requestLocationPermission()
                        }
                        .buttonStyle(PressableButtonStyle(normalColor: .primaryAppColor, pressedColor: .pressedButtonColor))
                        
                        Button(action: nextStep) {
                             Text("SKIP")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .foregroundStyle(.gray)
                        .background(.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))

                    case 2: // Notifications Page
                        Button("ALLOW NOTIFICATIONS") {
                            notificationManager.requestNotificationPermission()
                        }
                        .buttonStyle(PressableButtonStyle(normalColor: .primaryAppColor, pressedColor: .pressedButtonColor))

                        Button(action: nextStep) {
                             Text("SKIP")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .foregroundStyle(.gray)
                        .background(.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                            
                    case onboardingPages.indices.last: // Last Page
                        Button("START ADVENTURING!") { completeOnboarding() }
                            .buttonStyle(PressableButtonStyle(normalColor: .primaryAppColor, pressedColor: .pressedButtonColor))

                    default: // All other pages (e.g., Overview)
                        Button("NEXT") { nextStep() }
                            .buttonStyle(PressableButtonStyle(normalColor: .primaryAppColor, pressedColor: .pressedButtonColor))
                    }
                }
                // Removed fixed height to allow content to size naturally.
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        // FIX: Updated background color to the specified RGB value.
        .background(Color(red: 237 / 255.0, green: 237 / 255.0, blue: 237 / 255.0).ignoresSafeArea())
        // Listen for changes in permission status to advance automatically
        .onChange(of: locationManager.authorizationStatus) { _, newStatus in
            if onboardingStep == 1 && newStatus != .notDetermined {
                nextStep()
            }
        }
        .onChange(of: notificationManager.authorizationStatus) { _, newStatus in
            if onboardingStep == 2 && newStatus != .notDetermined {
                nextStep()
            }
        }
    }

    /// Advances to the next onboarding step with a smooth animation.
    private func nextStep() {
        withAnimation {
            if onboardingStep < onboardingPages.count - 1 {
                onboardingStep += 1
            }
        }
    }
    
    /// Sets the AppStorage flag to true, dismissing the onboarding view permanently.
    private func completeOnboarding() {
        hasCompletedOnboarding = true
    }
}

// MARK: - Reusable Page View Component
private struct OnboardingPageView: View {
    let page: OnboardingPageData

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: page.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 120)
                .foregroundStyle(Color.primaryAppColor)
                .padding()

            Text(page.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .padding(.horizontal)

            Text(page.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Data Model for a Page
private struct OnboardingPageData: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
}

// MARK: - Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(hasCompletedOnboarding: .constant(false))
            .environmentObject(LocationManager())
            .environmentObject(NotificationManager())
    }
}

