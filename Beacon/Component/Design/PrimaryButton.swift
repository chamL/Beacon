import SwiftUI

/// INFO:
/// button styles with a brown gradient and and a animation.
struct PrimaryButtonStyle: ButtonStyle {
	var color: Color = Theme.beaconBrown

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.padding(.horizontal, 16)
			.padding(.vertical, 10)
			.frame(maxWidth: .infinity)
			.background(
				LinearGradient(
					colors: [
						color.opacity(configuration.isPressed ? 0.8 : 1.0),
						Theme.highlightBrown.opacity(configuration.isPressed ? 0.7 : 0.9)
					],
					startPoint: .topLeading,
					endPoint: .bottomTrailing
				)
			)
			.foregroundColor(.white)
			.font(.headline)
			.cornerRadius(12)
			.shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
			.scaleEffect(configuration.isPressed ? 0.97 : 1.0)
			.animation(.easeOut(duration: 0.15), value: configuration.isPressed)
	}
}
