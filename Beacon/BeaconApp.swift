
import SwiftUI
import SwiftData

/// entry point for the app
/// uses app storage to persist the last map position and search radius
/// uses swift data to store ratings and favorite places
@main
struct BeaconApp: App {
	/// default position  oslo S
	@AppStorage("mapCenterLatitude") private var mapLat: Double = 59.9111
	@AppStorage("mapCenterLongitude") private var mapLon: Double = 10.7503
	@AppStorage("searchRadiusKm") private var radiusKm: Double = 5

	var body: some Scene {
		WindowGroup {
			RootView()
				.modelContainer(for: [Rating.self, FavoritePlace.self])
		}
	}
}

struct RootView: View {
	var body: some View {
		TabView {
			ExploreView()
				.tabItem {
					Label("Utforsk", systemImage: "map")
				}

			FavoritesView()
				.tabItem {
					Label("Mine steder", systemImage: "heart")
				}
		}
		.tint(Theme.highlightBrown) 
	}
}
