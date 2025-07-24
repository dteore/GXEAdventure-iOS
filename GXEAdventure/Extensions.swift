import Foundation

extension String {
    var doubleValue: Double? {
        let cleanedString = self.filter { "0123456789.".contains($0) }
        return Double(cleanedString)
    }

    func toTitleCase() -> String {
        return self.lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .map { $0.capitalized }
            .joined(separator: " ")
    }
}