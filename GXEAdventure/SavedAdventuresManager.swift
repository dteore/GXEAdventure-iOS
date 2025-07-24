
import Foundation
import SwiftUI

// MARK: - SavedAdventure Model
struct SavedAdventure: Identifiable, Codable {
    let id: UUID
    let adventure: Adventure
    let savedDate: Date
    var isFavorite: Bool = false

    init(adventure: Adventure, savedDate: Date = Date(), isFavorite: Bool = false) {
        self.id = UUID()
        self.adventure = adventure
        self.savedDate = savedDate
        self.isFavorite = isFavorite
    }
}

// MARK: - SavedAdventuresManager
class SavedAdventuresManager: ObservableObject {
    @Published var savedAdventures: [SavedAdventure] = [] {
        didSet {
            saveAdventures()
        }
    }

    private let userDefaultsKey = "savedAdventures"

    init() {
        loadAdventures()
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

    private func loadAdventures() {
        if let savedAdventuresData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedAdventures = try? JSONDecoder().decode([SavedAdventure].self, from: savedAdventuresData) {
            self.savedAdventures = decodedAdventures.sorted(by: { $0.savedDate > $1.savedDate })
            print("SavedAdventuresManager: Loaded \(self.savedAdventures.count) adventures.")
        } else {
            print("SavedAdventuresManager: No adventures found in UserDefaults or decoding failed.")
        }
    }
    
    func clearAllAdventures() {
        savedAdventures = []
    }

    func deleteAdventure(id: UUID) {
        savedAdventures.removeAll { $0.id == id }
    }

    func toggleFavorite(id: UUID) {
        if let index = savedAdventures.firstIndex(where: { $0.id == id }) {
            savedAdventures[index].isFavorite.toggle()
        }
    }
}
