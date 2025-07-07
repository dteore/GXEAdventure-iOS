//
//  ScavengerHuntView.swift
//  GXEAdventure
//
//  Created by YourName on 2025-07-10.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import SwiftUI
import CoreLocation

struct ScavengerHuntView: View {
    // Injected from the environment to get live location & heading updates.
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.dismiss) private var dismiss

    // The target destination for the scavenger hunt.
    // For testing, this is hardcoded to Trinity Bellwoods Park main entrance.
    // In a real app, this would come from your adventure's metadata.
    private let targetLocation = CLLocation(latitude: 43.6498, longitude: -79.4197)

    // State to manage the UI
    @State private var hintState: HintState = .stuck
    @State private var showLocationHint = false
    @State private var showSuccessView = false
    @State private var showDistanceAlert = false
    
    // The current progress of the adventure (0.0 to 1.0)
    private var adventureProgress: Double = 0.33

    var body: some View {
        ZStack(alignment: .top) {
            // Main background color for the view
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 20) {
                // MARK: - Header and Progress Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.primary)
                            .padding(10)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 5) {
                    Text("ADVENTURE PROGRESS")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    ProgressView(value: adventureProgress)
                        .tint(.primaryAppColor)
                }
                .padding(.horizontal)

                // MARK: - Main Content Card
                VStack(spacing: 30) {
                    VStack(spacing: 10) {
                        Text("Scavenger Hunt")
                            .font(.title.bold())
                        Text("Where stone stands strong and iron twines,\nA gateway marks the changing times.\nNear Queen and Strachan, find the place—\nAn entrance grand, your next clue's base.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }

                    CompassView(
                        targetLocation: targetLocation,
                        hintState: $hintState
                    )
                    
                    Button("Check-in") {
                        handleCheckIn()
                    }
                    .buttonStyle(PressableButtonStyle(normalColor: .gray, pressedColor: .primary))
                    .padding(.horizontal, 80)
                }
                .padding(30)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal)

                Spacer()

                // MARK: - Bottom Action Buttons
                Button("Reveal Location") {
                    showLocationHint = true
                }
                .font(.headline)
                .foregroundStyle(.primary)
                .alert("Location Hint", isPresented: $showLocationHint) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("The target is near the main gates of Trinity Bellwoods Park at Queen St W & Strachan Ave.")
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            locationManager.startUpdating()
        }
        .onDisappear {
            locationManager.stopUpdating()
        }
        .fullScreenCover(isPresented: $showSuccessView) {
            ScavengerHuntSuccessView(
                rewardAmount: 150,
                onNewAdventure: {
                    showSuccessView = false
                    // This should eventually trigger a new adventure generation
                    dismiss()
                },
                onKeepGoing: {
                    showSuccessView = false
                    dismiss()
                }
            )
        }
        .alert("Sorry, you aren't quite there yet.", isPresented: $showDistanceAlert) {
            Button("OK", role: .cancel) { }
        }
    }
    
    private func handleCheckIn() {
        guard let userLocation = locationManager.userLocation else {
            print("User location not available for check-in.")
            // Optionally show an alert that location is unavailable
            return
        }
        
        let distanceInMeters = userLocation.distance(from: targetLocation)
        let checkInRadiusInMeters: Double = 60.96 // Approximately 200 feet

        if distanceInMeters <= checkInRadiusInMeters {
            print("Check-in successful! Distance: \(distanceInMeters) meters.")
            showSuccessView = true
        } else {
            print("Check-in failed. Too far away. Distance: \(distanceInMeters) meters.")
            showDistanceAlert = true
        }
    }
}

// MARK: - Compass View Component
private struct CompassView: View {
    @EnvironmentObject var locationManager: LocationManager
    let targetLocation: CLLocation
    @Binding var hintState: HintState
    
    private var bearing: Double {
        guard let userLocation = locationManager.userLocation else { return 0 }
        return userLocation.bearing(to: targetLocation)
    }
    
    private var distance: CLLocationDistance {
        guard let userLocation = locationManager.userLocation else { return .greatestFiniteMagnitude }
        return userLocation.distance(from: targetLocation)
    }

    var body: some View {
        ZStack {
            Image(systemName: "chevron.up")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(hintState.color)
                .offset(y: -110)
                .rotationEffect(Angle(degrees: (bearing - (locationManager.deviceHeading?.trueHeading ?? 0))))
                .animation(.spring(), value: locationManager.deviceHeading)
                .animation(.easeInOut, value: hintState)

            Circle()
                .fill(hintState.color)
                .frame(width: 180, height: 180)
                .shadow(color: .black.opacity(0.2), radius: 10)
                .overlay(
                    VStack {
                        if hintState == .stuck {
                            Text(hintState.rawValue)
                                .font(.title.bold())
                                .foregroundColor(.white.opacity(0.7))
                            Text("Get a hint!")
                                .font(.caption)
                                .foregroundColor(.white)
                        } else {
                            Text(hintState.rawValue)
                                .font(.title.bold())
                                .foregroundColor(.white)
                        }
                    }
                )
                .onTapGesture {
                    updateHintState()
                }
        }
        .frame(height: 220)
        .onChange(of: distance) { _, _ in
            if hintState != .stuck {
                updateHintState()
            }
        }
    }
    
    private func updateHintState() {
        withAnimation(.easeInOut) {
            switch distance {
            case ...50:
                hintState = .hot
            case 51...200:
                hintState = .warm
            default:
                hintState = .cold
            }
        }
    }
}

// MARK: - Helper Enum and Extensions
enum HintState: String {
    case stuck = "STUCK?"
    case cold = "COLD"
    case warm = "WARM"
    case hot = "HOT"
    
    var color: Color {
        switch self {
        case .stuck: return .gray
        case .cold: return .blue
        case .warm: return .yellow
        case .hot: return .red
        }
    }
}

extension CLLocation {
    func bearing(to destination: CLLocation) -> Double {
        let lat1 = self.coordinate.latitude.toRadians()
        let lon1 = self.coordinate.longitude.toRadians()
        let lat2 = destination.coordinate.latitude.toRadians()
        let lon2 = destination.coordinate.longitude.toRadians()
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let degrees = atan2(y, x).toDegrees()
        return (degrees + 360).truncatingRemainder(dividingBy: 360)
    }
}

extension Double {
    func toRadians() -> Double { self * .pi / 180 }
    func toDegrees() -> Double { self * 180 / .pi }
}


// MARK: - Preview
struct ScavengerHuntView_Previews: PreviewProvider {
    static var previews: some View {
        ScavengerHuntView()
            .environmentObject(LocationManager())
    }
}

