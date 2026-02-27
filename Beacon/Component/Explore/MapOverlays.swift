import SwiftUI
import MapKit

///INFO
/// an overlay for loading... used in the explore when i fetch from the api
struct LoadingOverlay: View {
	var body: some View {
		VStack {
			ProgressView("Laster steder i nærheten…")
				.progressViewStyle(CircularProgressViewStyle(tint: Theme.beaconBrown))
				.font(.headline)
				.padding()
				.background(.ultraThinMaterial)
				.cornerRadius(12)
				.shadow(color: Theme.highlightBrown.opacity(0.4), radius: 6, x: 0, y: 2)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.background(Color.black.opacity(0.3))
		.ignoresSafeArea()
	}
}

//  THE ERROR TEXT SECTION IS HERE  ************************

/// INFO
/// banner for the errors, used in the explore 

struct ErrorBanner: View {
	let text: String

	var body: some View {
		VStack {
			Text("⚠️ \(text)")
				.foregroundColor(.white)
				.font(.headline)
				.padding(.horizontal, 16)
				.padding(.vertical, 10)
				.background(
					Color.red.opacity(0.9)
				)
				.cornerRadius(10)
				.shadow(color: Color.red.opacity(0.5), radius: 4, x: 0, y: 2)
		}
		.padding(.top, 60)
	}
}
