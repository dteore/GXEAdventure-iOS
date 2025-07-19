//
//  ScavengerHuntView.swift
//  GXEAdventure
//
//  Created by YourName on 2025-07-10.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import SwiftUI
import CoreLocation

public struct ScavengerHuntView: View {
    let adventure: Adventure
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.dismiss) private var dismiss
    let generateNewAdventure: (Bool) -> Void

    private let targetLocation = CLLocation(latitude: 43.6498, longitude: -79.4197)

    @State private var hintState: HintState = .cold
    @State private var showLocationHint = false
    @State private var showSuccessView = false
    @State private var showDistanceAlert = false
    @State private var showAbandonAlert: Bool = false
    
    private var adventureProgress: Double = 0.33

    public init(adventure: Adventure, generateNewAdventure: @escaping (Bool) -> Void) {
        self.adventure = adventure
        self.generateNewAdventure = generateNewAdventure
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 20) {
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
                    Text("ADVENTURE PROGRESS")
                        .font(.footnote)
                        .foregroundStyle(Color.bodyTextColor)
                    ProgressView(value: adventureProgress)
                        .tint(.primaryAppColor)
                }
                .padding(.horizontal, 25)

                // MARK: - Main Content Card
                VStack(spacing: 30) {
                    VStack(spacing: 10) {
                        Text(adventure.title)
                            .font(.title.bold())
                            .foregroundStyle(.white)
                        Text(adventure.nodes.first?.content ?? "No clue available.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true) // Allows text to wrap to multiple lines.
                    }

                    CompassView(
                        targetLocation: targetLocation,
                        hintState: $hintState
                    )
                    
                    Button("Check-in") {
                        handleCheckIn()
                    }
                    .buttonStyle(PressableButtonStyle(normalColor: .gray, pressedColor: .primaryAppColor))
                    .padding(.horizontal, 80)
                }
                .padding(30)
                .background(Color.headingColor)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal)
                .padding(.top, 25)

                Spacer()

                // MARK: - Bottom Action Buttons
                Button("Reveal Location") {
                    showLocationHint = true
                }
                .font(.headline)
                .foregroundStyle(Color.primaryAppColor)
                .padding(.top, 15)
                
                Spacer()

                .alert("Location Revealed", isPresented: $showLocationHint) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("The target is near the main gates of Trinity Bellwoods Park at Queen St W & Strachan Ave.")
                }
            }
            .padding(.vertical)
        }
        .preferredColorScheme(.light)
        .onAppear {
            locationManager.startUpdating()
        }
        .onDisappear {
            locationManager.stopUpdating()
        }
        .fullScreenCover(isPresented: $showSuccessView) {
            SuccessView(
                rewardAmount: 150,
                onNewAdventure: {
                    showSuccessView = false
                    dismiss()
                },
                onKeepGoing: { isRandom in
                    generateNewAdventure(isRandom)
                },
                dismissParent: { dismiss() }
            )
        }
        .alert("Sorry, you aren't quite there yet.", isPresented: $showDistanceAlert) {
            Button("OK", role: .cancel) { }
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
    
    private func handleCheckIn() {
        guard let userLocation = locationManager.userLocation else {
            print("User location not available for check-in.")
            return
        }
        
        let distanceInMeters = userLocation.distance(from: targetLocation)
        let checkInRadiusInMeters: Double = 15.24 // 50 feet

        if distanceInMeters <= checkInRadiusInMeters {
            showSuccessView = true
        } else {
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

    public var body: some View {
        ZStack {
            Image(systemName: "chevron.up")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(hintState.color)
                .offset(y: -110)
                .rotationEffect(Angle(degrees: (bearing - locationManager.smoothedHeading)))
                .animation(.spring(), value: locationManager.smoothedHeading)
                .animation(.easeInOut, value: hintState)

            Circle()
                .fill(hintState.color)
                .frame(width: 180, height: 180)
                .shadow(color: .black.opacity(0.2), radius: 10)
                .overlay(
                    Text(hintState.rawValue)
                        .font(.title.bold())
                        .foregroundColor(.white)
                )
        }
        .frame(height: 220)
        .onAppear(perform: updateHintState)
        .onChange(of: distance) { _, _ in
            updateHintState()
        }
    }
    
    private func updateHintState() {
        withAnimation(.easeInOut) {
            let hotDistance: CLLocationDistance = 15.24 // 50 feet
            let warmDistance: CLLocationDistance = 30.48 // 100 feet
            
            switch distance {
            case ...hotDistance:
                hintState = .hot
            case (hotDistance + 0.1)...warmDistance:
                hintState = .warm
            default:
                hintState = .cold
            }
        }
    }
}

// MARK: - Helper Enum and Extensions (Scoped to this file)
fileprivate enum HintState: String {
    case cold = "COLD"
    case warm = "WARM"
    case hot = "HOT"
    
    var color: Color {
        switch self {
        case .cold: return .blue
        case .warm: return .yellow
        case .hot: return .red
        }
    }
}

fileprivate extension CLLocation {
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

fileprivate extension Double {
    func toRadians() -> Double { self * .pi / 180 }
    func toDegrees() -> Double { self * 180 / .pi }
}


// MARK: - Preview
struct ScavengerHuntView_Previews: PreviewProvider {
    static var previews: some View {
        ScavengerHuntView(adventure: Adventure(
            id: UUID().uuidString,
            questId: nil,
            title: "Test Scavenger Hunt",
            location: "Test Location",
            type: "scavenger-hunt",
            theme: "History",
            playerId: "test-player-id",
            summary: "A test scavenger hunt adventure.",
            status: "created",
            nodes: [
                AdventureNode(id: UUID().uuidString, type: "story", content: "This is the first clue.", metadata: AdventureNodeMetadata(orderIndex: 0, isAnswerNode: false, type: nil, metadata: nil)),
                AdventureNode(id: UUID().uuidString, type: "discovery", content: "This is the second clue.", metadata: AdventureNodeMetadata(orderIndex: 1, isAnswerNode: false, type: nil, metadata: nil))
            ],
            createdAt: "",
            updatedAt: "",
            waypointCount: 0,
            reward: "100 N"
        ), generateNewAdventure: { isRandom in
            print("Generate New Adventure from ScavengerHuntView Preview. isRandom: \(isRandom)")
        })
            .environmentObject(LocationManager())
    }
}
