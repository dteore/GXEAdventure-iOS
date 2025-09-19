import SwiftUI
import MapKit

public struct TourView: View {
    let adventure: Adventure
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var adventureViewModel: AdventureViewModel
    
    @StateObject private var landmarkSearchService = LandmarkSearchService()
    @State private var mapCameraPosition: MapCameraPosition = .region(MKCoordinateRegion())
    @State private var currentNodeIndex: Int = 0
    @State private var isMapFullScreen = false
    @State private var showAnswerAlert = false
    @State private var answerContent: String?

    public init(adventure: Adventure) {
        self.adventure = adventure
        _currentNodeIndex = State(initialValue: adventure.nodes.firstIndex(where: { $0.type != "start" }) ?? 0)
    }
    
    @State private var showSuccessView = false
    @State private var isCardExpanded: Bool = true
    @State private var showAbandonAlert: Bool = false
    
    private var tourProgress: Double {
        guard !adventure.nodes.isEmpty else { return 0.0 }
        return Double(currentNodeIndex + 1) / Double(adventure.nodes.count)
    }

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    // Header and Progress Bar
                    HStack {
                        Button(action: { showAbandonAlert = true }) {
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
                            .foregroundStyle(.white) // Changed to white
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if adventure.nodes.indices.contains(currentNodeIndex) {
                            Text(adventure.nodes[currentNodeIndex].content)
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.8)) // Changed to white
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Map(position: $mapCameraPosition) {
                            if let center = landmarkSearchService.region?.center {
                                Marker("", coordinate: center)
                            }
                        }
                        .frame(height: 200)
                        .cornerRadius(15)
                        .overlay(alignment: .bottomTrailing) {
                            Button(action: { isMapFullScreen = true }) {
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Circle())
                            }
                            .padding(10)
                        }
                    }
                    .padding(40)
                    .background(Color.appBackground) // Changed to appBackground
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)
                    .padding(.top, 25)

                    // Action Buttons
                    VStack(spacing: 10) {
                        if currentNodeIndex < adventure.nodes.count - 1 {
                            let currentNodeType = adventure.nodes[currentNodeIndex].type.lowercased()
                            let buttonText = (adventure.type.lowercased() == "scavenger_hunt" && currentNodeType == "clue") ? "REVEAL ANSWER" : "NEXT"
                            
                            Button(buttonText) {
                                if buttonText == "REVEAL ANSWER" {
                                    let nextNodeIndex = currentNodeIndex + 1
                                    if nextNodeIndex < adventure.nodes.count && adventure.nodes[nextNodeIndex].type.lowercased() == "answer" {
                                        answerContent = adventure.nodes[nextNodeIndex].content
                                        showAnswerAlert = true
                                    } else {
                                        currentNodeIndex += 1
                                    }
                                } else {
                                    currentNodeIndex += 1
                                }
                            }
                            .buttonStyle(PressableButtonStyle(normalColor: .primaryAppColor, pressedColor: .pressedButtonColor))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        } else if adventure.nodes[currentNodeIndex].type.lowercased() == "ending" {
                            Button("COMPLETE TOUR") { showSuccessView = true }
                                .buttonStyle(PressableButtonStyle(normalColor: .primaryAppColor, pressedColor: .primaryAppColor))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }

                        if currentNodeIndex > 1 {
                            Button(action: { currentNodeIndex -= 1 }) {
                                Text("BACK").fontWeight(.semibold).frame(maxWidth: .infinity)
                            }
                            .padding(.vertical, 12)
                            .foregroundStyle(.gray)
                            .background(.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                }
            }
            .background(Color.black.ignoresSafeArea()) // Changed to black
            .navigationBarHidden(true)
            .onAppear(perform: setupInitialRegion)
            .onChange(of: currentNodeIndex) { 
                searchForLandmark() 
            }
            .onChange(of: landmarkSearchService.regionUpdateID) {
                if let newRegion = landmarkSearchService.region {
                    withAnimation {
                        mapCameraPosition = .region(newRegion)
                    }
                }
            }
            .alert("Answer", isPresented: $showAnswerAlert) { // Removed presenting: answerContent
                Button("Next") { currentNodeIndex += 2 }
            } message: {
                Text(answerContent ?? "") // Directly use answerContent
            }
        }
        .sheet(isPresented: $isMapFullScreen) {
            Map(position: $mapCameraPosition) {
                if let center = landmarkSearchService.region?.center {
                    Marker("", coordinate: center)
                }
            }
            .ignoresSafeArea()
            .overlay(alignment: .topTrailing) {
                Button(action: { isMapFullScreen = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .padding()
                        .foregroundColor(.gray)
                }
            }
        }
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
                    adventureViewModel.generateAdventure(theme: theme)
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
                        onKeepPlaying: { showAbandonAlert = false }
                    )
                }
            }
        )
    }
    
    private func setupInitialRegion() {
        let geocodingService = GeocodingService()
        Task {
            if let coordinates = await geocodingService.geocodeAddress(adventure.location) {
                let initialRegion = MKCoordinateRegion(
                    center: coordinates,
                    span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                )
                await MainActor.run {
                    mapCameraPosition = .region(initialRegion)
                    searchForLandmark(in: initialRegion)
                }
            }
        }
    }

    private func searchForLandmark(in region: MKCoordinateRegion? = nil) {
        guard currentNodeIndex >= 0 && currentNodeIndex < adventure.nodes.count else { return }
        let waypointIndex = (currentNodeIndex - 1) / 2
        guard waypointIndex >= 0, let path = adventure.path, !path.waypoints.isEmpty, path.waypoints.indices.contains(waypointIndex) else { return }
        
        let landmarkName = path.waypoints[waypointIndex].landmarkName
        landmarkSearchService.search(for: landmarkName, in: region ?? landmarkSearchService.region)
    }
}

@MainActor
private class LandmarkSearchService: ObservableObject {
    @Published private(set) var region: MKCoordinateRegion?
    @Published private(set) var regionUpdateID = UUID()
    private var localSearch: MKLocalSearch?

    func search(for landmarkName: String, in initialRegion: MKCoordinateRegion?) {
        localSearch?.cancel()

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = landmarkName
        if let initialRegion = initialRegion {
            request.region = initialRegion
        }

        let search = MKLocalSearch(request: request)
        self.localSearch = search

        search.start { [weak self] (response, error) in
            guard let self = self else { return }

            guard let response = response, let mapItem = response.mapItems.first else {
                print("Landmark '\(landmarkName)' not found")
                return
            }
            
            self.region = MKCoordinateRegion(
                center: mapItem.placemark.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            self.regionUpdateID = UUID()
        }
    }

    deinit {
        print("LandmarkSearchService deinit, cancelling search.")
        localSearch?.cancel()
    }
}

struct IdentifiableCoordinate: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
