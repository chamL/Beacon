import SwiftUI

/// INFO
/// explor button that shows more search options can be toggled and is at bottom left corner in explore
struct ListButtonView: View {
	let onTap: () -> Void

	var body: some View {
		VStack {
			Spacer()
			HStack {
				
				Button(action: onTap) {
					HStack(spacing: 6) {
						Image(systemName: "list.bullet.circle.fill")
							.font(.title2)
						Text("Vis liste") 
							.fontWeight(.medium)
					}
					.foregroundStyle(.white)
					.padding(.horizontal, 18)
					.padding(.vertical, 10)
					.background(
						LinearGradient(
							colors: [Theme.beaconBrown, Theme.highlightBrown],
							startPoint: .leading,
							endPoint: .trailing
						)
					)
					.clipShape(Capsule())
					.shadow(color: Theme.highlightBrown.opacity(0.4), radius: 4, x: 0, y: 2)
				}
				.padding(.leading, 16)
				.padding(.bottom, 40)
				
				Spacer()
			}
		}
	}
}
