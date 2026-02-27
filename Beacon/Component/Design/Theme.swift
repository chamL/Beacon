import SwiftUI

enum Theme {
	// main colors
	static let beaconBrown = Color("BeaconBrown") // tan brown
	static let highlightBrown = Color("HighlightBrown") // darker brown
	

	// gradient buttons
	static var buttonGradient: LinearGradient {
		LinearGradient(
			colors: [
				beaconBrown,
				highlightBrown
			],
			startPoint: .topLeading,
			endPoint: .bottomTrailing
		)
	}

	// gradient backgrounds
	static var backgroundGradient: LinearGradient {
		LinearGradient(
			colors: [
				Color(hex: 0xE6D3B3),
				beaconBrown
			],
			startPoint: .top,
			endPoint: .bottom
		)
	}

	// darker gradient button
	static var darkBackgroundGradient: LinearGradient {
		LinearGradient(
			colors: [
				Color(hex: 0x3E2F23),
			],
			startPoint: .top,
			endPoint: .bottom
		)
	}

	// gold ish gradient buttons
	static var goldAccentGradient: LinearGradient {
		LinearGradient(
			colors: [
				Color(hex: 0xD4AF7A),
				Color(hex: 0xB89463)
			],
			startPoint: .leading,
			endPoint: .trailing
		)
	}
}

extension Color {
	init(hex: UInt, alpha: Double = 1.0) {
		self.init(
			.sRGB,
			red: Double((hex >> 16) & 0xFF) / 255,
			green: Double((hex >> 8) & 0xFF) / 255,
			blue: Double(hex & 0xFF) / 255,
			opacity: alpha
		)
	}
}
