//
//  ContentView.swift
//  GXEAdventure
//
//  Created by YourName on 2023-10-27.
//  Copyright © 2025 YourCompany. All rights reserved.
//

import SwiftUI
import CoreLocation

// MARK: - Main Content View
struct ContentView: View {
    @State private var selectedTab: Tab = .adventures
    @State private var showSettings: Bool = false
    
    enum Tab {
        case adventures, rewards
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            AdventuresTabView(showSettings: $showSettings)
                .tabItem {
                    Label("Adventures", systemImage: "map.fill")
                }
                .tag(Tab.adventures)

            RewardsTabView(showSettings: $showSettings)
                .tabItem {
                    Label("Rewards", systemImage: "star.fill")
                }
                .tag(Tab.rewards)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .accentColor(.primaryAppColor)
    }
}

// MARK: - Adventures Tab
struct AdventuresTabView: View {
    @Binding var showSettings: Bool
    @State private var isLoading: Bool = false
    @State private var isAdventureReady: Bool = false
    @State private var adventureTitle: String = ""
    @State private var adventureReward: String = ""
    @State private var adventureDetails: String = ""
    @State private var apiError: AppError? = nil
    @State private var adventureTask: Task<Void, Error>?
    @State private var selectedAdventureType: String? = "Tour"
    @State private var selectedTheme: String?
    
    @EnvironmentObject private var locationManager: LocationManager
    
    private var isLocationAuthorized: Bool {
        locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways
    }
    
    private func generateAdventure(isRandom: Bool) {
        isLoading = true
        adventureTask = Task {
            do {
                let (adventure, details) = try await AdventureService.generateAdventure(
                    type: isRandom ? nil : selectedAdventureType,
                    theme: isRandom ? nil : selectedTheme,
                    userLocation: locationManager.lastKnownLocation
                )
                self.adventureTitle = adventure.title
                self.adventureReward = adventure.reward
                self.adventureDetails = adventure.summary ?? "Your adventure is ready! Get ready to explore Trinity Bellwoods."
                self.isAdventureReady = true
            } catch {
                if !(error is CancellationError) {
                    self.apiError = AppError(message: error.localizedDescription)
                }
            }
            self.isLoading = false
        }
    }
    
    private func cancelAdventure() {
        adventureTask?.cancel()
        isLoading = false
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isLocationAuthorized {
                    NotificationBannerView()
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HeaderSection(showSettings: $showSettings)
                        
                        if isLocationAuthorized {
                            StartAdventureSection(isLoading: $isLoading, generateAction: { generateAdventure(isRandom: true) })
                        } else {
                            LocationRequiredSection()
                        }
                        
                        CustomizationSection(
                            selectedAdventureType: $selectedAdventureType,
                            selectedTheme: $selectedTheme,
                            isLoading: $isLoading,
                            isLocationAuthorized: isLocationAuthorized,
                            generateAction: { generateAdventure(isRandom: false) }
                        )
                    }
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .overlay(
            Group {
                if isLoading {
                    LoadingView(isLoading: $isLoading, cancelAction: cancelAdventure)
                } else if isAdventureReady {
                    ReadyView(
                        adventureTitle: $adventureTitle,
                        adventureReward: $adventureReward,
                        fullAdventureDetails: $adventureDetails,
                        dismissAction: { isAdventureReady = false }
                    )
                }
            }
        )
        .alert(item: $apiError) { error in
            Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
        }
        .onAppear(perform: locationManager.fetchLocationStatus)
    }
}

// MARK: - Networking Models and Service
struct Adventure {
    let id: String
    let title: String
    let summary: String?
    let type: String
    // For display purposes, we'll calculate reward based on type
    var reward: String {
        switch type {
        case "tour":
            return "25 N"
        case "scavenger_hunt":
            return "100 N"
        default:
            return "50 N"
        }
    }
}

// API Response Models
struct CreateAdventureResponse: Codable {
    let adventure: AdventureData
}

struct AdventureData: Codable {
    let id: String
    let title: String
    let summary: String?
    let type: String
    let playerId: String
    // Include other fields as needed
}

struct CreateAdventureRequest: Codable {
    let prompt: String
    let playerProfile: PlayerProfile
    let adventureType: String?
    let location: String?
    let origin: Origin?
    let distanceKm: Double?
    let segments: Int?
}

struct Origin: Codable {
    let lat: Double
    let lng: Double
}

struct PlayerProfile: Codable {
    let id: String
    let name: String?
}

struct AdventureService {
    static func generateAdventure(type: String?, theme: String?, userLocation: CLLocation?) async throws -> (adventure: Adventure, details: String) {
        guard let url = URL(string: "https://nvrse-ai.fly.dev/api/adventures") else {
            throw AppError(message: "Invalid API URL.")
        }
        let playerID = "test-player-id-\(UUID().uuidString.prefix(8))"
        
        // Determine adventure type for API
        var adventureType: String? = nil
        if let type = type {
            if type.contains("Tour") {
                adventureType = "tour"
            } else if type.contains("Scavenger Hunt") {
                adventureType = "scavenger_hunt"
            }
        }
        
        // Build prompt text
        var promptText = "Create a"
        if let theme = theme {
            promptText += " \(theme.lowercased().replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: ""))"
        }
        if let type = adventureType {
            promptText += " \(type.replacingOccurrences(of: "_", with: " "))"
        } else {
            promptText += " random adventure"
        }
        promptText += " in Trinity Bellwoods, Toronto"
        
        // Add location and adventure parameters
        var origin: Origin? = nil
        if let location = userLocation {
            origin = Origin(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
        }
        
        // Set distance and segments based on adventure type
        let distanceKm: Double? = adventureType == "tour" ? 1.5 : (adventureType == "scavenger_hunt" ? 2.5 : nil)
        let segments: Int? = adventureType == "tour" ? 3 : (adventureType == "scavenger_hunt" ? 5 : nil)
        
        let requestBody = CreateAdventureRequest(
            prompt: promptText,
            playerProfile: PlayerProfile(id: playerID, name: nil),
            adventureType: adventureType,
            location: "Trinity Bellwoods, Toronto, ON",
            origin: origin,
            distanceKm: distanceKm,
            segments: segments
        )
        
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(requestBody)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 500
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown server error."
            throw AppError(message: "Server returned status \(statusCode):\n\(errorBody)")
        }
        
        // First, let's see what the API actually returns
        let details = String(data: data, encoding: .utf8) ?? "Could not decode adventure details."
        
        // Try to decode the response
        do {
            let response = try JSONDecoder().decode(CreateAdventureResponse.self, from: data)
            let adventureData = response.adventure
            
            // Convert to our simplified Adventure model
            let adventure = Adventure(
                id: adventureData.id,
                title: adventureData.title,
                summary: adventureData.summary,
                type: adventureData.type
            )
            
            return (adventure, details)
        } catch {
            print("Decoding error: \(error)")
            print("Raw response: \(details)")
            throw AppError(message: "Could not parse adventure data: \(error.localizedDescription)")
        }
    }
}

// MARK: - Reusable Child Views
private struct HeaderSection: View {
    @Binding var showSettings: Bool
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
                    .font(.body).foregroundStyle(Color.bodyTextColor).padding(.top, 5)
            }.padding(.horizontal, 20).padding(.bottom, 45)
            SettingsButton(showSettings: $showSettings)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 217/255, green: 217/255, blue: 217/255))
    }
}

private struct LocationRequiredSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Location Required for Adventure!").font(.title.bold()).foregroundStyle(Color.headingColor)
            Text("To guide you on tours and verify scavenger hunt progress, we need your location. Please enable it in Settings.").font(.subheadline).foregroundStyle(Color.bodyTextColor).padding(.bottom, 25)
            Button("ENABLE LOCATION") {
                if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
            }.primaryActionButton()
        }.padding(.horizontal).padding(.vertical, 25)
    }
}

private struct StartAdventureSection: View {
    @Binding var isLoading: Bool
    let generateAction: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeaderView(
                title: "Start your Adventure",
                subtitle: "Choose a random adventure, or customize yours with types and themes below."
            )
            Button("GENERATE ADVENTURE (100-250 N)") {
                isLoading = true
                generateAction()
            }
            .primaryActionButton()
            .padding(.horizontal)
            .padding(.bottom, 25)
        }.background(Color.appBackground)
    }
}

private struct CustomizationSection: View {
    @Binding var selectedAdventureType: String?
    @Binding var selectedTheme: String?
    @Binding var isLoading: Bool
    let isLocationAuthorized: Bool
    let generateAction: () -> Void
    private let themes = ["History", "Culture", "Landmarks", "Nature", "[Timely]", "[Ghost Stories]"]
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Customization")
                .font(.title.bold())
                .foregroundStyle(Color.headingColor)
            Text("Type")
                .font(.headline)
                .foregroundStyle(Color.headingColor)
            HStack(spacing: 15) {
                TypeSelectionButton(title: "Tour (+25 N)", selection: $selectedAdventureType)
                TypeSelectionButton(title: "Scavenger Hunt (+100 N)", selection: $selectedAdventureType)
                Spacer()
            }
            Text("Theme")
                .font(.headline)
                .foregroundStyle(Color.headingColor)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 10)], spacing: 10) {
                ForEach(themes, id: \.self) { theme in ThemeSelectionButton(title: theme, selection: $selectedTheme) }
            }
            Button("GENERATE ADVENTURE (100-250 N)") {
                isLoading = true
                generateAction()
            }
            .buttonStyle(PressableButtonStyle(normalColor: isLocationAuthorized ? .primaryAppColor : .gray.opacity(0.5), pressedColor: isLocationAuthorized ? .pressedButtonColor : .gray.opacity(0.7)))
            .disabled(!isLocationAuthorized)
            .padding(.top, 50)
        }
        .padding()
        .background(Color.white)
        .opacity(isLocationAuthorized ? 1.0 : 0.5)
    }
}

private struct TypeSelectionButton: View {
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

private struct ThemeSelectionButton: View {
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

private struct NotificationBannerView: View {
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
                CloseButton(action: { withAnimation { showBanner = false } }, color: .white.opacity(0.7))
            }
            .padding()
            .background(LinearGradient(colors: [.primaryAppColor, .primaryAppColor], startPoint: .topLeading, endPoint: .bottomTrailing))
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LocationManager())
            .environmentObject(NotificationManager())
            .preferredColorScheme(.dark)
    }
}

