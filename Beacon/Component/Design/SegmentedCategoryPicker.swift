import SwiftUI

/// INFO:
/// a segmented picker switching between categories I n the explore page.
public struct SegmentedCategoryPicker: View {
	@Binding public var selection: PlaceCategory

	public init(selection: Binding<PlaceCategory>) {
		self._selection = selection
	}

	public var body: some View {
		Picker("Category", selection: $selection) {
			ForEach(PlaceCategory.allCases) { category in
				Text(category.displayName).tag(category)
			}
		}
		.pickerStyle(.segmented)
		.tint(Theme.beaconBrown)
	}
}
