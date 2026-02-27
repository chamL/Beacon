import Foundation
import CoreLocation


public final class GeoapifyService {

	public static let shared = GeoapifyService(
		apiKey: Secrets.value(forKey: "GeoapifyAPIKey") ?? ""
	)

	private let apiKey: String

	public init(apiKey: String) {
		self.apiKey = apiKey
	}

	//  THE PLACE SEARCH SECTION IS HERE  ************************************************
	/// searches for nearby places by category and location.
	public func searchPlaces(
		center: CLLocationCoordinate2D,
		category: PlaceCategory,
		radiusKm: Double,
		limit: Int = 10
	) async throws -> [Place] {

		let radiusMeters = Int(radiusKm * 1000)

		var components = URLComponents(string: "https://api.geoapify.com/v2/places")
		components?.queryItems = [
			.init(name: "categories", value: category.geoapifyToken),
			.init(name: "filter", value: "circle:\(center.longitude),\(center.latitude),\(radiusMeters)"),
			.init(name: "bias", value: "proximity:\(center.longitude),\(center.latitude)"),
			.init(name: "limit", value: "\(limit)"),
			.init(name: "apiKey", value: apiKey),
			.init(name: "lang", value: "en")
		]

		guard let url = components?.url else { throw GeoapifyError.badURL }

	
		let (data, response) = try await URLSession.shared.data(from: url)
		guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
			throw GeoapifyError.requestFailed
		}


		let collection: GeoapifyFeatureCollection
		do {
			let decoder = JSONDecoder()
			collection = try decoder.decode(GeoapifyFeatureCollection.self, from: data)
		} catch {
			print("❌ JSON decoding failed:", error)
			throw GeoapifyError.decodingFailed
		}

		

		let places: [Place] = collection.features.compactMap { feature in
			let p = feature.properties
			let coords = feature.geometry.coordinates
			guard coords.count >= 2 else { return nil }

			let lat = coords[1]
			let lon = coords[0]

			let appCat = PlaceCategory.infer(from: p.categories ?? [])
			let catString: String? = {
				switch appCat {
				case .restaurant?: return "catering.restaurant"
				case .cafe?:       return "catering.cafe"
				case .hotel?:      return "accommodation.hotel"
				default:           return p.categories?.first
				}
			}()

			return Place(
				id: p.place_id,
				name: p.name ?? "Unknown place",
				address: [p.address_line1, p.address_line2].compactMap { $0 }.joined(separator: ", "),
				coordinate: .init(latitude: lat, longitude: lon),
				category: catString,
				phone: p.contact?.phone,
				openingHours: p.opening_hours
			)
		}

		guard !places.isEmpty else { throw GeoapifyError.empty }
		return places
	}

	//  THE DETAIL FETCH SECTION IS HERE  ************************************************
	/// fetches info for a single place like phone, website, hours
	func fetchPlaceDetails(placeId: String) async throws -> GeoapifyPlaceDetailsDTO {
		var components = URLComponents(string: "https://api.geoapify.com/v2/place-details")
		components?.queryItems = [
			.init(name: "id", value: placeId),
			.init(name: "apiKey", value: apiKey),
			.init(name: "lang", value: "en")
		]
		guard let url = components?.url else { throw GeoapifyError.badURL }

		let (data, response) = try await URLSession.shared.data(from: url)
		guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
			throw GeoapifyError.requestFailed
		}

		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase

		do {
			return try decoder.decode(GeoapifyPlaceDetailsDTO.self, from: data)
		} catch {
			print("❌ Failed to decode place details:", error)
			throw GeoapifyError.decodingFailed
		}
	}
}

//  THE ERROR HANDLING SECTION IS HERE  ************************************************
public enum GeoapifyError: LocalizedError {
	case badURL, requestFailed, decodingFailed, empty

	public var errorDescription: String? {
		switch self {
		case .badURL:        return "Invalid request URL."
		case .requestFailed: return "Failed to fetch data. Please check your network connection."
		case .decodingFailed:return "Could not read data from the service."
		case .empty:         return "No results found."
		}
	}
}

private struct GeoapifyFeatureCollection: Codable {
	let features: [GeoapifyFeature]
}

private struct GeoapifyFeature: Codable {
	let properties: GeoapifyProps
	let geometry: GeoapifyGeometry
}

private struct GeoapifyGeometry: Codable {
	let coordinates: [Double]
}

private struct GeoapifyProps: Codable {
	let place_id: String
	let name: String?
	let address_line1: String?
	let address_line2: String?
	let categories: [String]?
	let opening_hours: String?
	let contact: Contact?
	let website: String?
	let country: String?
	let city: String?

	struct Contact: Codable {
		let phone: String?
	}
}

struct GeoapifyPlaceDetailsDTO: Codable {
	let features: [Feature]

	struct Feature: Codable {
		let properties: Properties
	}

	struct Properties: Codable {
		let name: String?
		let addressLine1: String?
		let addressLine2: String?
		let city: String?
		let country: String?
		let phone: String?
		let website: String?
		let openingHours: String?
		let email: String?
		let categories: [String]?
	}
}
