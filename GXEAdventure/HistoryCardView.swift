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
    let onCardTapped: (Adventure) -> Void // This is no longer used but kept for structural consistency
    let onDelete: (UUID) -> Void
    let onToggleFavorite: (UUID) -> Void

    @State private var showDeleteConfirmation: Bool = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // --- CHANGE: This is no longer a Button. It's now a VStack to hold the content. ---
            // This allows the favorite button inside it to be tappable.
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    Text(savedAdventure.adventure.title)
                        .font(.title2.bold())
                        .foregroundStyle(Color.headingColor)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                    Spacer()
                   
                    // Favorite Button is now tappable because its parent is not disabled.
                    Button(action: { onToggleFavorite(savedAdventure.id) }) {
                        Image(systemName: savedAdventure.isFavorite ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundColor(savedAdventure.isFavorite ? .red : .gray)
                            .padding(5)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                // Location
                HStack(spacing: 5) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.subheadline)
                        .foregroundStyle(Color.bodyTextColor)
                    Text(savedAdventure.adventure.location)
                        .font(.subheadline)
                        .foregroundStyle(Color.bodyTextColor)
                        .multilineTextAlignment(.leading)
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
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading) // Ensures the VStack takes full width
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            // --- CHANGE: The .disabled(true) modifier has been removed ---

            // The trash button remains outside the main content block.
            Button(action: { showDeleteConfirmation = true }) {
                Image(systemName: "trash.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .padding(5)
            }
            .padding(.trailing, 15)
            .padding(.bottom, 15)
        }
        .alert("Delete Adventure", isPresented: $showDeleteConfirmation) {
            Button("Confirm", role: .destructive) {
                onDelete(savedAdventure.id)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this adventure?")
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

