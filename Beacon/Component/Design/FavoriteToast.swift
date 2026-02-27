import SwiftUI

/// INFO:
///  toast message that shows when adding or removing a favorite.
/// Shows a brown heart when added and a red one when removed.
struct FavoriteToast: View {
	let isFavorite: Bool

	var body: some View {
		VStack {
			Spacer()
			Text(isFavorite ? "🤎 Added to favorites!" : "💔 Removed from favorites")
				.fontWeight(.semibold)
				.padding(.horizontal, 20)
				.padding(.vertical, 12)
				.background(
					isFavorite
					? Theme.beaconBrown.opacity(0.9)   // brown for added
					: Color.red.opacity(0.85)          // red  for remove
				)
				.foregroundColor(.white)
				.cornerRadius(20)
				.shadow(color: Theme.highlightBrown.opacity(0.4), radius: 4, x: 0, y: 2)
				.transition(.move(edge: .bottom).combined(with: .opacity))
				.animation(.easeInOut, value: isFavorite)
			Spacer().frame(height: 50)
		}
	}
}
