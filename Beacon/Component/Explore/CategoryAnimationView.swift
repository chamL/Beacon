import SwiftUI

/// INFO
///  animatons for the different emojis depending on the different categorys (PlaceDetailView)
struct CategoryAnimationView: View {
	let category: String
	@Binding var rotation: Double
	@Binding var scale: CGFloat
	@Binding var steam1: Bool
	@Binding var steam2: Bool
	@Binding var steam3: Bool

	var body: some View {
		let cat = category.lowercased()

		switch true {
		case cat.contains("catering.restaurant"):
			Text("🍽️")
				.font(.system(size: 56))
				.rotationEffect(.degrees(rotation)) // rotation animation for restaurants

		case cat.contains("catering.cafe"):
			ZStack {
				Text("☕️")
					.font(.system(size: 56))
				ZStack {
					steam(yOffset: steam1 ? -30 : 0).opacity(steam1 ? 0 : 1)
					steam(yOffset: steam2 ? -30 : 0).opacity(steam2 ? 0 : 1)
					steam(yOffset: steam3 ? -30 : 0).opacity(steam3 ? 0 : 1)
				}
			} // animated steam for cafes

		case cat.contains("accommodation"):
			Text("🏨")
				.font(.system(size: 56))
				.scaleEffect(scale) // scale animation for hotels

		default:
			Text("📍")
				.font(.system(size: 56)) //  emoji for unknow placese
		}
	}

	private func steam(yOffset: CGFloat) -> some View {
		Text("💨")
			.offset(y: yOffset)
			.transition(.opacity)
	}
}
