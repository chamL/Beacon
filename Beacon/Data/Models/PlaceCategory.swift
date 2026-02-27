import Foundation

// INFO
/// matching the category with the emoji and names form api
public enum PlaceCategory: String, CaseIterable, Identifiable, Codable {
	case restaurant
	case cafe
	case hotel

	public var id: String { rawValue }

	//  THE DISPLAY NAME IS HERE  ************************************************
	public var displayName: String {
		switch self {
		case .restaurant: return "Restaurant"
		case .cafe: return "Café"
		case .hotel: return "Hotel"
		}
	}

	//  THE GEOAPIFY TOKEN IS HERE  ************************************************
	public var geoapifyToken: String {
		switch self {
		case .restaurant: return "catering.restaurant"
		case .cafe: return "catering.cafe"
		case .hotel: return "accommodation.hotel"
		}
	}

	//  THE EMOJI IS HERE  ************************************************
	public var emoji: String {
		switch self {
		case .restaurant: return "🍽"
		case .cafe: return "☕"
		case .hotel: return "🏨"
		}
	}

	/// guessing the app cateegory with a fallback of accomodation and catering
	public static func infer(from categories: [String]) -> PlaceCategory? {
		let lower = categories.map { $0.lowercased() }

		if lower.contains(where: { $0.contains("catering.restaurant") }) { return .restaurant }
		if lower.contains(where: { $0.contains("catering.cafe") }) { return .cafe }
		if lower.contains(where: { $0.contains("accommodation.hotel") }) { return .hotel }

		// Fallback guesses for broader matches
		if lower.contains(where: { $0.contains("accommodation") }) { return .hotel }
		if lower.contains(where: { $0.contains("catering") }) { return .restaurant }

		return nil
	}
}
