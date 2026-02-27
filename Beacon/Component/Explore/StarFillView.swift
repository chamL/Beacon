import SwiftUI

/// INFO
///   star thet fills up from 1 - 5 and can press multiple times to fill up the star for a avarage rating
public struct StarFillView: View {
	public let fillPercent: Double

	public var body: some View {
		ZStack {
			// Empty star in background
			Image(systemName: "star")
				.foregroundStyle(.gray.opacity(0.4))

			// filling the  star overlay with mask for filling
			GeometryReader { geometry in
				let width = geometry.size.width * fillPercent
				Image(systemName: "star.fill")
					.mask(alignment: .leading) {
						Rectangle().frame(width: width)
					}
					.foregroundStyle(Theme.highlightBrown)
			}
		}
		.frame(width: 20, height: 20)
		.accessibilityLabel("Rating")
	}
}
