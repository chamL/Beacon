import SwiftUI

// INFO
/// information about a selected place info like
/// name, address, coordinates, contact info, and rating stars
struct PlaceInfoSection: View {
	let place: Place
	let details: Place?
	let averageFill: Double

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			
			/// place name
			Text(place.name)
				.font(.title3.bold())
				.foregroundColor(Theme.highlightBrown)

			/// address
			Text(place.address ?? "No address available")
				.foregroundStyle(.secondary)

			//( coordinates
			Text("Coordinates: \(String(format: "%.5f", place.coordinate.latitude)), \(String(format: "%.5f", place.coordinate.longitude))")
				.font(.footnote)
				.foregroundStyle(.secondary)

			/// phone number
			if let phone = (details ?? place).phone, !phone.isEmpty {
				Text("📞 \(phone)")
					.foregroundColor(Theme.highlightBrown)
			}

			/// opening hours
			if let hours = (details ?? place).openingHours, !hours.isEmpty {
				Text("🕒 Opening hours: \(hours)")
					.foregroundColor(Theme.highlightBrown)
			}

			/// average rating
			if averageFill > 0 {
				HStack(spacing: 6) {
					StarFillView(fillPercent: averageFill)
					Text(String(format: "%.1f / 5", averageFill * 5.0))
						.foregroundStyle(.secondary)
				}
			}
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}
