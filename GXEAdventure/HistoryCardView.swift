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
    let onDelete: (UUID) -> Void
    let onToggleFavorite: (UUID) -> Void

    @State private var showDeleteConfirmation: Bool = false
    @State private var isExpanded: Bool = false // New state for accordion expansion

    private var hasSummary: Bool {
        !savedAdventure.adventure.summary.isEmpty
    }

    private func formatLocationForShare(_ location: String) -> String {
        let components = location.components(separatedBy: ", ")
        if components.count >= 2 {
            return "\(components[components.count - 2]), \(components[components.count - 1])"
        }
        return location // Fallback if format is unexpected
    }

    private func shareAdventure() {
        let formattedLocation = formatLocationForShare(savedAdventure.adventure.location)
        let shareText = "Check out this adventure: \(savedAdventure.adventure.title) in \(formattedLocation)!\n\n\(savedAdventure.adventure.summary)"
        
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        // Present the share sheet
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                // Header with Title and Action Buttons
                HStack(alignment: .top) {
                    Text(savedAdventure.adventure.title)
                        .font(.title2.bold())
                        .foregroundStyle(Color.headingColor)
                        .lineLimit(isExpanded ? nil : 2)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Button(action: { onToggleFavorite(savedAdventure.id) }) {
                        Image(systemName: savedAdventure.isFavorite ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundColor(savedAdventure.isFavorite ? .red : .gray)
                            .offset(y: 3) // Adjust vertical alignment
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(width: 44, height: 44) // Standardize size

                    Button(action: {
                        shareAdventure()
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(width: 44, height: 44) // Standardize size
                }

                // Summary/Details (conditionally shown)
                if isExpanded {
                    if hasSummary {
                        Text(savedAdventure.adventure.summary)
                            .font(.body)
                            .foregroundStyle(Color.bodyTextColor)
                            .multilineTextAlignment(.leading)
                            .padding(.top, 5)
                    } else {
                        Text("No summary available for this adventure.")
                            .font(.body)
                            .foregroundStyle(Color.bodyTextColor)
                            .multilineTextAlignment(.leading)
                            .padding(.top, 5)
                    }
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
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .frame(width: 44, height: 44) // Standardize size
                        .rotationEffect(.degrees(isExpanded ? -90 : 0))
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }
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
        VStack {
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
                        summary: "A beautiful tour of the desert landscape and architecture.",
                        status: "completed",
                        nodes: [],
                        createdAt: "",
                        updatedAt: "",
                        waypointCount: 0,
                        reward: ""
                    ),
                    savedDate: Date()
                ),
                onDelete: { id in
                    print("Delete adventure with ID: \(id)")
                },
                onToggleFavorite: { id in
                    print("Toggle favorite for adventure with ID: \(id)")
                }
            )
            
            HistoryCardView(
                savedAdventure: SavedAdventure(
                    adventure: Adventure(
                        id: UUID().uuidString,
                        questId: nil,
                        title: "Adventure Without a Summary",
                        location: "Someplace, USA",
                        type: "Scavenger Hunt",
                        theme: "Mystery",
                        playerId: "test-player-id",
                        summary: "", // Empty summary
                        status: "completed",
                        nodes: [],
                        createdAt: "",
                        updatedAt: "",
                        waypointCount: 0,
                        reward: ""
                    ),
                    savedDate: Date()
                ),
                onDelete: { id in
                    print("Delete adventure with ID: \(id)")
                },
                onToggleFavorite: { id in
                    print("Toggle favorite for adventure with ID: \(id)")
                }
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
