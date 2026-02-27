import SwiftUI
import MapKit

/// INFO
/// map pins for the different places are here
/// also the star rating if needed

struct PlaceAnnotationView: View {
	let place: Place
	let fill: Double
	let onSelect: (Place) -> Void

	var body: some View {
		Button {
			onSelect(place)
		} label: {
			VStack(spacing: 4) {
				
				//  THE PIN ICON SECTION IS HERE  ************************
				Image(systemName: "mappin.circle.fill")
					.font(.title2)
					.symbolRenderingMode(.palette)
					.foregroundStyle(Theme.beaconBrown, .white)
					.shadow(radius: 3)

				
				//  THE STAR FILL SECTION IS HERE  ************************
				if fill > 0 {
					StarFillView(fillPercent: fill)
						.frame(width: 28, height: 14)
				}
			}
			.padding(8)
			.contentShape(Rectangle())
		}
		.buttonStyle(.plain)
		.zIndex(20)                   
	}
}
