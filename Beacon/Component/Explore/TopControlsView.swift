import SwiftUI
import CoreLocation

/// INFO
/// Top controls in the explore page is here
/// it contains the category picker, radius and the fetch and refresh button
/// also an tip that the user should press and hold for 2  seconds when pressing a pin
struct TopControlsView: View {
	@Binding var category: PlaceCategory
	@Binding var radiusKm: Double
	let onFetch: () async -> Void
	let onReset: () async -> Void
	let onRadiusChange: (Double) -> Void

	var body: some View {
		VStack(spacing: 6) {
			
			//  THE CATEGORY AND BUTTONS IS HERE  ************************
			HStack(spacing: 12) {
				SegmentedCategoryPicker(selection: $category)
					.onChange(of: category) { _, _ in
						Task { await onFetch() }
					}

				Button(action: { Task { await onFetch() } }) {
					Text("Finn")
						.font(.title3)
						.foregroundColor(.white)
						.padding(8)
						.background(Theme.beaconBrown)
						.cornerRadius(10)
				}

				Button(action: { Task { await onReset() } }) {
					Image(systemName: "arrow.triangle.2.circlepath")
						.font(.title3)
						.foregroundColor(.white)
						.padding(8)
						.background(Theme.beaconBrown)
						.cornerRadius(10)
				}
			}
			.padding(.horizontal, 10)
			.padding(.top, 8)

			//  THE RADIUS SLIDER IS HERE  ************************
			HStack(spacing: 12) {
				Text("Radius: \(Int(radiusKm)) km")
					.font(.subheadline)

				Slider(value: $radiusKm, in: 1...10, step: 1)
					.onChange(of: radiusKm) { _, _ in
						onRadiusChange(radiusKm)
					}
			}
			.padding(.horizontal, 10)
			.padding(.bottom, 4)

			//  THE USER TIPS IS HERE (HOLD FOR 2 SECONDS) ************************
			HStack(spacing: 6) {
				Image(systemName: "hand.tap")
					.font(.caption2)
				Text("Tips: Hold inne en pin på kartet i ca. 2 sekunder for å åpne detaljsiden.")
					.font(.caption2)
			}
			.foregroundColor(.secondary)
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding(.horizontal, 12)
			.padding(.bottom, 8)
		}
		.background(.ultraThinMaterial)
		.clipShape(RoundedRectangle(cornerRadius: 14))
		.padding(.horizontal)
		.padding(.top, 12)
	}
}
