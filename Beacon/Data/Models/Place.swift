import Foundation
import CoreLocation

//INFO
/// Main model representing a single place.
/// Used across the app for displaying map pins, list items, and details.
public struct Place: Identifiable, Codable, Hashable, Equatable {
	public let id: String
	public let name: String
	public let address: String?
	public let coordinate: CLLocationCoordinate2D
	public let category: String?
	public let phone: String?
	public let openingHours: String?

	enum CodingKeys: String, CodingKey {
		case id, name, address, lat, lon, category, phone, openingHours
	}

	public init(
		id: String,
		name: String,
		address: String?,
		coordinate: CLLocationCoordinate2D,
		category: String?,
		phone: String? = nil,
		openingHours: String? = nil
	) {
		self.id = id
		self.name = name
		self.address = address
		self.coordinate = coordinate
		self.category = category
		self.phone = phone
		self.openingHours = openingHours
	}

	public init(from decoder: Decoder) throws {
		let c = try decoder.container(keyedBy: CodingKeys.self)
		id = try c.decode(String.self, forKey: .id)
		name = try c.decode(String.self, forKey: .name)
		address = try c.decodeIfPresent(String.self, forKey: .address)

		let lat = try c.decode(Double.self, forKey: .lat)
		let lon = try c.decode(Double.self, forKey: .lon)
		coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)

		category = try c.decodeIfPresent(String.self, forKey: .category)
		phone = try c.decodeIfPresent(String.self, forKey: .phone)
		openingHours = try c.decodeIfPresent(String.self, forKey: .openingHours)
	}

	public func encode(to encoder: Encoder) throws {
		var c = encoder.container(keyedBy: CodingKeys.self)
		try c.encode(id, forKey: .id)
		try c.encode(name, forKey: .name)
		try c.encodeIfPresent(address, forKey: .address)
		try c.encode(coordinate.latitude, forKey: .lat)
		try c.encode(coordinate.longitude, forKey: .lon)
		try c.encodeIfPresent(category, forKey: .category)
		try c.encodeIfPresent(phone, forKey: .phone)
		try c.encodeIfPresent(openingHours, forKey: .openingHours)
	}

	public static func == (lhs: Place, rhs: Place) -> Bool { lhs.id == rhs.id }

	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
