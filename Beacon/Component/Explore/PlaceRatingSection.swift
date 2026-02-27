import SwiftUI
/// INFO
///  section where you can rate the place with an description
struct PlaceRatingSection: View {
	let place: Place
	let addRating: (Int) -> Void

	var body: some View {
		VStack(spacing: 8) {
			
			Text("Gi en vurdering")
				.font(.headline)
				.foregroundColor(Theme.highlightBrown)

			HStack(spacing: 8) {
				ForEach(1...5, id: \.self) { value in
					Button("\(value)") {
						addRating(value)
					}
					.buttonStyle(PrimaryButtonStyle(color: Theme.beaconBrown))
				}
			}

			//  THE INFO TEXT IS HERE  ************************************************
			Text("1 stjerne = 20 % fylt <--> 5 stjerner = 100 % fylt")
				.font(.footnote)
				.foregroundStyle(.secondary)
		}
	}
}
