import SwiftUI

/// INFO
/// control buttons in the explore, these are for the zoom in and out and also
/// button for center the user in the map
struct MapControlButtons: View {
	let onZoomIn: () -> Void
	let onZoomOut: () -> Void
	let onGpsTap: () -> Void

	var body: some View {
		VStack {
			Spacer()
			HStack {
				Spacer()
				VStack(spacing: 10) {
					
					//  THE ZOOM BUTTONS SECTION IS HERE  *********************************************************
					VStack(spacing: 8) {
						Button(action: onZoomIn) {
							Image(systemName: "plus.magnifyingglass")
								.font(.title2)
								.foregroundColor(.white)
								.padding(10)
								.background(Theme.beaconBrown)
								.clipShape(Circle())
								.shadow(color: Theme.beaconBrown.opacity(0.4), radius: 3, x: 0, y: 2)
						}
						
						Button(action: onZoomOut) {
							Image(systemName: "minus.magnifyingglass")
								.font(.title2)
								.foregroundColor(.white)
								.padding(10)
								.background(Theme.beaconBrown)
								.clipShape(Circle())
								.shadow(color: Theme.beaconBrown.opacity(0.4), radius: 3, x: 0, y: 2)
						}
					}

					//  THE PERSON BUTTON SECTION IS HERE  ****************************************************
					Button(action: onGpsTap) {
						Image(systemName: "figure.arms.open")
							.font(.title2)
							.foregroundColor(.white)
							.padding(10)
							.background(Theme.highlightBrown)
							.clipShape(Circle())
							.shadow(color: Theme.highlightBrown.opacity(0.4), radius: 3, x: 0, y: 2)
					}
				}
				.padding(.trailing, 16)
				.padding(.bottom, 50)
			}
		}
	}
}
