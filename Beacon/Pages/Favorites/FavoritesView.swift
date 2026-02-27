import SwiftUI
import SwiftData



// INFO
/// shows all favorite places the user has saved locally.
///  can delete also by button or swiping
///  swift date for storing

public struct FavoritesView: View {
	@Environment(\.modelContext) private var context
	@Query private var favorites: [FavoritePlace]
	@State private var selected: FavoritePlace?

	public init() {}

	//  THE BODY SECTION IS HERE  ************************************************
	public var body: some View {
		NavigationStack {
			ZStack {
				Theme.backgroundGradient
					.ignoresSafeArea()

				Rectangle()
					.fill(.ultraThinMaterial)
					.ignoresSafeArea()

				/// main content here, a list or  empty
				content
			}
			.navigationTitle("Mine favoritter")
			.tint(Theme.highlightBrown)
		}
		/// when favorite is pressed then show detail sheet
		.sheet(item: $selected) { fav in
			PlaceDetailView(
				place: Place(
					id: fav.id,
					name: fav.name,
					address: fav.address,
					coordinate: .init(latitude: 59.9111, longitude: 10.7503),
					category: fav.category ?? "generell"
				)
			)
		}
	}

	@ViewBuilder
	private var content: some View {
		if favorites.isEmpty {
			emptyState
		} else {
			favoritesList
		}
	}

	//  THE EMPTY STATE SECTION IS HERE  ************************************************
	private var emptyState: some View {
		VStack(spacing: 12) {
			Image(systemName: "heart.slash.fill")
				.font(.system(size: 50))
				.foregroundColor(Theme.highlightBrown.opacity(0.8))
				.padding(.bottom, 8)

			Text("Ingen favoritter enda")
				.font(.headline)
				.foregroundColor(Theme.highlightBrown)

			Text("Legg til favoritter fra kartet for å se dem her.")
				.font(.subheadline)
				.foregroundColor(.secondary)
				.multilineTextAlignment(.center)
				.padding(.horizontal)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}

	//  THE FAVORITES LIST SECTION IS HERE  ************************************************
	private var favoritesList: some View {
		List {
			ForEach(favorites) { fav in
				HStack(spacing: 12) {
					
					Text(icon(for: fav.category ?? ""))
						.font(.title3)

					VStack(alignment: .leading, spacing: 4) {
						Text(fav.name)
							.font(.headline)
							.foregroundColor(Theme.highlightBrown)

						if !fav.address.isEmpty {
							Text(fav.address)
								.font(.subheadline)
								.foregroundStyle(.secondary)
						}
					}
					.frame(maxWidth: .infinity, alignment: .leading)
					.contentShape(Rectangle())
					.onTapGesture {
						selected = fav
					}

					/// delete button
					Button {
						deleteFavorite(fav)
					} label: {
						Image(systemName: "trash")
							.foregroundColor(.red)
							.font(.system(size: 18, weight: .semibold))
							.padding(6)
							.background(Color.red.opacity(0.1))
							.clipShape(Circle())
					}
					.buttonStyle(.plain)
				}
				.padding(12)
				.background(
					RoundedRectangle(cornerRadius: 16)
						.fill(Theme.goldAccentGradient.opacity(0.5))
						.shadow(color: Theme.beaconBrown.opacity(0.7), radius: 4, x: 0, y: 2)
				)
				.listRowSeparator(.hidden)
				.listRowBackground(Color.clear)
			}
			.onDelete(perform: deleteMultiple)
		}
		.scrollContentBackground(.hidden)
		.listStyle(.plain)
		.padding(.horizontal, 8)
		.padding(.vertical, 4)
	}

	//  THE HELPER FUNCTIONS SECTION IS HERE  ************************************************
	private func deleteFavorite(_ fav: FavoritePlace) {
		withAnimation {
			context.delete(fav)
			try? context.save()
		}
	}

	private func deleteMultiple(at offsets: IndexSet) {
		withAnimation {
			offsets.forEach { index in
				let fav = favorites[index]
				context.delete(fav)
			}
			try? context.save()
		}
	}

	private func icon(for category: String) -> String {
		let c = category.lowercased()
		if c.contains("catering.restaurant") { return "🍽️" }
		if c.contains("catering.cafe") { return "☕️" }
		if c.contains("accommodation.hotel") || c.contains("accommodation") { return "🏨" }
		return "📍"
	}
}
