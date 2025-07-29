
import Foundation
import SwiftUI
import MapKit

// MARK: - SavedAdventure Model
struct SavedAdventure: Identifiable, Codable {
    let id: UUID
    let adventure: Adventure
    let savedDate: Date
    var isFavorite: Bool = false

    init(adventure: Adventure, savedDate: Date = Date(), isFavorite: Bool = false) {
        self.id = UUID(uuidString: adventure.id) ?? UUID()
        self.adventure = adventure
        self.savedDate = savedDate
        self.isFavorite = isFavorite
    }
}

struct CodableMapRect: Codable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double

    init(from mapRect: MKMapRect) {
        self.x = mapRect.origin.x
        self.y = mapRect.origin.y
        self.width = mapRect.size.width
        self.height = mapRect.size.height
    }

    var mapRect: MKMapRect {
        return MKMapRect(x: x, y: y, width: width, height: height)
    }
}

// MARK: - SavedAdventuresManager
class SavedAdventuresManager: ObservableObject {
    @Published var savedAdventures: [SavedAdventure] = [] {
        didSet {
            saveAdventures()
        }
    }
    @Published var revealedAreas: [MKMapRect] = [] {
        didSet {
            saveRevealedAreas()
        }
    }

    private let userDefaultsKey = "savedAdventures"
    private let revealedAreasKey = "revealedAreas"

    init() { 
        // Data will be loaded asynchronously.
    }

    func loadData() {
        loadAdventures()
        loadRevealedAreas()
    }

    func saveAdventure(_ adventure: Adventure) {
        let newSavedAdventure = SavedAdventure(adventure: adventure)
        savedAdventures.insert(newSavedAdventure, at: 0)
    }

    private func saveAdventures() {
        if let encoded = try? JSONEncoder().encode(savedAdventures) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func saveRevealedAreas() {
        let codableRects = revealedAreas.map { CodableMapRect(from: $0) }
        if let encoded = try? JSONEncoder().encode(codableRects) {
            UserDefaults.standard.set(encoded, forKey: revealedAreasKey)
        }
    }

    private func loadAdventures() {
        if let savedAdventuresData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedAdventures = try? JSONDecoder().decode([SavedAdventure].self, from: savedAdventuresData) {
            self.savedAdventures = decodedAdventures.sorted(by: { $0.savedDate > $1.savedDate })
            print("SavedAdventuresManager: Loaded \(self.savedAdventures.count) adventures.")
            for adventure in self.savedAdventures {
                print("  - Adventure: \(adventure.adventure.title), Location: \(adventure.adventure.location)")
            }
        } else {
            print("SavedAdventuresManager: No adventures found in UserDefaults or decoding failed.")
        }
    }

    private func loadRevealedAreas() {
        if let savedRevealedAreasData = UserDefaults.standard.data(forKey: revealedAreasKey),
           let decodedAreas = try? JSONDecoder().decode([CodableMapRect].self, from: savedRevealedAreasData) {
            self.revealedAreas = decodedAreas.map { $0.mapRect }
            print("SavedAdventuresManager: Loaded \(self.revealedAreas.count) revealed areas.")
        } else {
            print("SavedAdventuresManager: No revealed areas found in UserDefaults or decoding failed.")
        }
    }
    
    func clearAllAdventures() {
        savedAdventures = []
    }

    func deleteAdventure(id: UUID) {
        savedAdventures.removeAll { $0.id == id }
    }

    func deleteAdventure(atOffsets offsets: IndexSet) {
        savedAdventures.remove(atOffsets: offsets)
    }

    func toggleFavorite(id: UUID) {
        if let index = savedAdventures.firstIndex(where: { $0.id == id }) {
            savedAdventures[index].isFavorite.toggle()
        }
    }

    func addRevealedArea(for adventure: Adventure) {
        // This is a placeholder implementation. We need to calculate the actual map rect for the adventure.
        let mapRect = MKMapRect(x: 0, y: 0, width: 100000, height: 100000)
        revealedAreas.append(mapRect)
    }
}
