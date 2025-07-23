import SwiftUI

// MARK: - Date Formatter Extension
extension DateFormatter {
    static let mediumDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

struct HistoryCardView: View {
    let savedAdventure: SavedAdventure
    let onCardTapped: (Adventure) -> Void
    let onDelete: (UUID) -> Void
    let onToggleFavorite: (UUID) -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: { onCardTapped(savedAdventure.adventure) }) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {
                        Text(savedAdventure.adventure.title)
                            .font(.title2.bold())
                            .foregroundStyle(Color.headingColor)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        
                        // Favorite Button
                        Button(action: { onToggleFavorite(savedAdventure.id) }) {
                            Image(systemName: savedAdventure.isFavorite ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundColor(savedAdventure.isFavorite ? .red : .gray)
                                .padding(5)
                        }
                        .buttonStyle(PlainButtonStyle()) // Use PlainButtonStyle to avoid default button styling
                    }

                    // Location
                    HStack(spacing: 5) {
                        Image(systemName: "map.pin")
                            .font(.subheadline)
                            .foregroundStyle(Color.bodyTextColor)
                        Text(savedAdventure.adventure.location)
                            .font(.subheadline)
                            .foregroundStyle(Color.bodyTextColor)
                    }

                    // Saved Date
                    HStack(spacing: 5) {
                        Image(systemName: "calendar")
                            .font(.subheadline)
                            .foregroundStyle(Color.bodyTextColor)
                        Text("Saved: \(savedAdventure.savedDate, formatter: DateFormatter.mediumDate)")
                            .font(.subheadline)
                            .foregroundStyle(Color.bodyTextColor)
                    }

                    // Type and Theme Tags
                    HStack(spacing: 5) {
                        Text(savedAdventure.adventure.type)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.primaryAppColor.opacity(0.1))
                            .cornerRadius(5)
                            .foregroundStyle(Color.primaryAppColor)

                        if let theme = savedAdventure.adventure.theme {
                            Text(theme)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.primaryAppColor.opacity(0.1))
                                .cornerRadius(5)
                                .foregroundStyle(Color.primaryAppColor)
                        }
                    }
                    Text("Replay")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.primaryAppColor)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }

            Button(action: { onDelete(savedAdventure.id) }) {
                Image(systemName: "trash.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .padding(5)
            }
            .offset(x: 10, y: -10) // Adjust position to be outside the card slightly
        }
    }
}

// MARK: - Preview
struct HistoryCardView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryCardView(
            savedAdventure: SavedAdventure(
                adventure: Adventure(
                    id: UUID().uuidString,
                    questId: nil,
                    title: "Palm Springs: Desert Canvas Tour",
                    location: "1200 N Sunrise Way, Palm Springs, CA 92262, USA",
                    type: "Tour",
                    theme: "Photography",
                    playerId: "test-player-id",
                    summary: "",
                    status: "completed",
                    nodes: [],
                    createdAt: "",
                    updatedAt: "",
                    waypointCount: 0,
                    reward: ""
                ),
                savedDate: Date()
            ),
            onCardTapped: { adventure in
                print("Card tapped for: \(adventure.title)")
            },
            onDelete: { id in
                print("Delete adventure with ID: \(id)")
            },
            onToggleFavorite: { id in
                print("Toggle favorite for adventure with ID: \(id)")
            }
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}