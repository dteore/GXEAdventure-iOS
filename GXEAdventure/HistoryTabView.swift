import SwiftUI

struct HistoryTabView: View {
    @Binding var showSettings: Bool
    @EnvironmentObject var savedAdventuresManager: SavedAdventuresManager
    @EnvironmentObject private var adventureViewModel: AdventureViewModel

    var body: some View {
        NavigationView {
            List {
                HistoryHeaderView(showSettings: $showSettings)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .background(Color.appBackground)

                if savedAdventuresManager.savedAdventures.isEmpty {
                    Text("No adventures saved yet. Complete an adventure to see it here!")
                        .font(.headline)
                        .foregroundStyle(Color.bodyTextColor)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(savedAdventuresManager.savedAdventures.indices, id: \.self) { index in
                        let savedAdventure = savedAdventuresManager.savedAdventures[index]
                        HistoryCardView(savedAdventure: savedAdventure, onDelete: { id in
                            savedAdventuresManager.deleteAdventure(id: id)
                        }, onToggleFavorite: { id in
                            savedAdventuresManager.toggleFavorite(id: id)
                        })
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .padding(.top, index == 0 ? 10 : 0) // Add 10px padding to the top of the first card
                    }
                    .onDelete { indexSet in
                        savedAdventuresManager.deleteAdventure(atOffsets: indexSet)
                    }
                }
            }
            .listStyle(.plain) // Use plain style for custom appearance
            .background(Color.appBackground.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.light)
    }
}

private struct HistoryHeaderView: View {
    @Binding var showSettings: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Your Adventure History")
                    .font(.system(size: 36, weight: .bold))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .lineSpacing(-5)
                    .foregroundStyle(Color.headingColor)
                    .padding(.top, 30)

                Text("Relive your past explorations and see all the adventures you've completed.")
                    .font(.body)
                    .foregroundStyle(Color.bodyTextColor)
                    .padding(.top, 5)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20) // Adjusted padding to match card spacing
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(red: 217/255, green: 217/255, blue: 217/255))

            Button { showSettings = true } label: {
                Image(systemName: "gearshape")
                    .font(.title2)
                    .foregroundStyle(Color.headingColor)
                    .padding(.top, 25)
                    .padding(.trailing, 20)
            }
        }
    }
}

struct HistoryTabView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryTabView(showSettings: .constant(false))
            .environmentObject(SavedAdventuresManager())
            .environmentObject(AdventureViewModel(locationManager: LocationManager()))
    }
}

