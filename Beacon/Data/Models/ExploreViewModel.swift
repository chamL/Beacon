import Foundation
import CoreLocation
import SwiftUI
// INFO
/// viewmodel handeling fetching, filtering and sorting places
@MainActor
final class ExploreViewModel: ObservableObject {
	@Published var category: PlaceCategory = .restaurant
	@Published var places: [Place] = []
	@Published var isLoading: Bool = false
	@Published var errorMessage: String?
	@Published var showList: Bool = false

	/// search & sorting controls
	@Published var query: String = ""
	@Published var sort: SortMode = .distance
	@Published var onlyFavorites: Bool = false

	private let service: GeoapifyService
	private let debouncer = Debouncer()

	init(service: GeoapifyService) {
		self.service = service
	}

	//  THE FETCHING SECTION IS HERE  ************************
	/// fetchin places from Geoapify based on category and radius
	func fetch(center: CLLocationCoordinate2D, radiusKm: Double) async {
		isLoading = true
		errorMessage = nil

		do {
			let results = try await service.searchPlaces(
				center: center,
				category: category,
				radiusKm: radiusKm,
				limit: 10
			)
			places = results
		} catch let error as GeoapifyError {
			errorMessage = error.localizedDescription
			places = []
		} catch {
			errorMessage = "Noe gikk galt med henting av steder."
			places = []
		}

		isLoading = false
	}

	func debouncedFetch(center: CLLocationCoordinate2D, radiusKm: Double) {
		Task {
			await debouncer.debounce(milliseconds: 300) { [weak self] in
				guard let self else { return }
				await self.fetch(center: center, radiusKm: radiusKm)
			}
		}
	}

	//  THE SORTING MODE IS HERE  ************************
	enum SortMode: String, CaseIterable, Identifiable {
		case distance
		case rating
		case name

		var id: String { rawValue }

		var title: String {
			switch self {
			case .distance: return "Avstand"
			case .rating:   return "Vurdering"
			case .name:     return "Alfabetisk"
			}
		}
	}
}
