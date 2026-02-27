import SwiftUI

// INFO
///  list of places with rating and emoji
public struct PlaceListView: View {
	public let places: [Place]
	public let averageFill: (String) -> Double
	public var onSelect: (Place) -> Void
	public var onRefresh: (() async -> Void)?

	public init(
		places: [Place],
		averageFill: @escaping (String) -> Double,
		onSelect: @escaping (Place) -> Void,
		onRefresh: (() async -> Void)? = nil
	) {
		self.places = places
		self.averageFill = averageFill
		self.onSelect = onSelect
		self.onRefresh = onRefresh
	}

	//  THE BODY SECTION IS HERE  ************************************************
	public var body: some View {
		Group {
			if places.isEmpty {
				VStack(spacing: 10) {
					Image(systemName: "magnifyingglass")
						.font(.largeTitle)
						.foregroundColor(Theme.highlightBrown)

					Text("Ingen steder funnet")
						.font(.headline)
						.foregroundColor(Theme.highlightBrown.opacity(0.8))
				}
				.frame(maxWidth: .infinity, minHeight: 200)

			} else {
				/// list of places
				List(places) { place in
					Button {
						onSelect(place)
					} label: {
						VStack(alignment: .leading, spacing: 6) {

							/// name, emoji and title
							HStack(alignment: .center) {
								Text(icon(for: place.category ?? ""))
									.font(.title3)

								Text(place.name)
									.font(.headline)
									.foregroundColor(Theme.highlightBrown)

								Spacer()
							}

							if let address = place.address, !address.isEmpty {
								Text(address)
									.font(.subheadline)
									.foregroundStyle(.secondary)
							}

							/// rating
							let fill = averageFill(place.id)
							if fill > 0 {
								HStack(spacing: 6) {
									StarFillView(fillPercent: fill)
									Text(String(format: "%.1f / 5", fill * 5.0))
										.font(.footnote)
										.foregroundStyle(.secondary)
								}
								.padding(.top, 2)
							}
						}
						.padding(.vertical, 6)
					}
					.buttonStyle(.plain)
					.listRowBackground(Theme.beaconBrown.opacity(0.08))
				}
				.listStyle(.plain)
				.refreshable {
					if let refresh = onRefresh {
						await refresh()
					}
				}
			}
		}
	}

	//  THE HELPER FUNCTIONS SECTION IS HERE  ************************************************
	private func icon(for category: String) -> String {
		let c = category.lowercased()
		if c.contains("catering.restaurant") { return "🍽️" }
		if c.contains("catering.cafe") { return "☕️" }
		if c.contains("accommodation.hotel") || c.contains("accommodation") { return "🏨" }
		return "📍"
	}
}
