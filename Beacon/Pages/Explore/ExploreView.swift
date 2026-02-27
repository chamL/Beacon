import SwiftUI
import MapKit
import CoreLocation
import SwiftData



//INFO
/// this is the main explore screen showing nearby places on a map
/// Handles fetching from the  api, showing user location,
/// displaying search and autocomplete results, and letting users open detailed place info
/// also supports filtering, sorting, and marking favorites
public struct ExploreView: View {

	/// stored state and data
	@AppStorage("mapCenterLatitude") private var mapLat: Double = 59.9111
	@AppStorage("mapCenterLongitude") private var mapLon: Double = 10.7503
	@AppStorage("searchRadiusKm") private var radiusKm: Double = 5

	@StateObject private var locationManager = LocationManager()

	/// main view model and autocomplete helper
	/// both use the same  api key from Secrets
	@StateObject private var viewModel: ExploreViewModel
	@StateObject private var autocompleteService: GeoapifyAutocompleteService

	@Query private var allRatings: [Rating]
	@Query private var favorites: [FavoritePlace]

	/// camera, selected place, and map region
	@State private var cameraPosition: MapCameraPosition = .region(
		MKCoordinateRegion(
			center: CLLocationCoordinate2D(latitude: 59.9111, longitude: 10.7503),
			span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
		)
	)
	@State private var selectedPlace: Place?
	@State private var currentRegion: MKCoordinateRegion?
	@State private var suggestions: [GeoapifyAutocompleteResult] = []

	/// current map center coordinate
	private var centreCoordinate: CLLocationCoordinate2D {
		CLLocationCoordinate2D(latitude: mapLat, longitude: mapLon)
	}

	public init() {
		let key = Secrets.value(forKey: "GeoapifyAPIKey") ?? ""
		_viewModel = StateObject(
			wrappedValue: ExploreViewModel(service: GeoapifyService(apiKey: key))
		)
		_autocompleteService = StateObject(
			wrappedValue: GeoapifyAutocompleteService(apiKey: key)
		)
	}

	/// filters by search text favorites and sorting
	private var filteredSortedPlaces: [Place] {
		var list = viewModel.places

		///  search filter on name or address
		if !viewModel.query.isEmpty {
			let q = viewModel.query.lowercased()
			list = list.filter {
				$0.name.lowercased().contains(q) ||
				($0.address ?? "").lowercased().contains(q)
			}
		}

		/// only show favorites when enabled
		if viewModel.onlyFavorites {
			let favIds = Set(favorites.map { $0.id })
			list = list.filter { favIds.contains($0.id) }
		}

		/// apply selected sort mode
		switch viewModel.sort {
		case .distance:
			let centerLoc = CLLocation(
				latitude: centreCoordinate.latitude,
				longitude: centreCoordinate.longitude
			)
			list.sort {
				let d0 = CLLocation(
					latitude: $0.coordinate.latitude,
					longitude: $0.coordinate.longitude
				).distance(from: centerLoc)

				let d1 = CLLocation(
					latitude: $1.coordinate.latitude,
					longitude: $1.coordinate.longitude
				).distance(from: centerLoc)

				return d0 < d1
			}

		case .rating:
			list.sort { averageFill(for: $0.id) > averageFill(for: $1.id) }

		case .name:
			list.sort {
				$0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
			}
		}

		return list
	}

	//  THE BODY IS HERE  ************************************************
	public var body: some View {
		ZStack(alignment: .top) {

			/// main map
			Map(position: $cameraPosition, interactionModes: .all) {

				///  user current location
				if let userLocation = locationManager.currentLocation {
					Annotation("", coordinate: userLocation.coordinate) {
						Image(systemName: "figure.arms.open")
							.font(.title)
							.symbolRenderingMode(.palette)
							.foregroundStyle(Theme.highlightBrown, .white)
							.padding(6)
							.shadow(radius: 5)
							.accessibilityLabel("Din posisjon")
					}
				}

				///  places on the map
				ForEach(filteredSortedPlaces) { place in
					let fill = averageFill(for: place.id)

					Annotation("", coordinate: place.coordinate) {
						PlaceAnnotationView(place: place, fill: fill) { tappedPlace in
							// Open detail view for this place
							selectedPlace = tappedPlace
						}
						.accessibilityLabel(place.name)
					}
				}
			}
			.mapStyle(.standard(elevation: .realistic))
			.ignoresSafeArea()
			.onMapCameraChange { ctx in
				mapLat = ctx.region.center.latitude
				mapLon = ctx.region.center.longitude
				currentRegion = ctx.region
			}
			.onTapGesture {
				suggestions = []
			}

			///  loading overlay while fetching from api
			if viewModel.isLoading {
				LoadingOverlay()
			}

			/// error message from view model
			if let error = viewModel.errorMessage {
				ErrorBanner(text: error)
			}

			/// top bar with category picker, radius and buttons
			TopControlsView(
				category: $viewModel.category,
				radiusKm: $radiusKm,
				onFetch: {
					await viewModel.fetch(center: centreCoordinate, radiusKm: radiusKm)
				},
				onReset: {
					await resetFiltersAsync()
				},
				onRadiusChange: { newRadius in
					/// debounce no spamming
					Task {
						viewModel.debouncedFetch(
							center: centreCoordinate,
							radiusKm: newRadius
						)
					}
				}
			)

			///  list button to show the bottom list sheet
			if !viewModel.showList {
				ListButtonView {
					withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
						viewModel.showList.toggle()
					}
				}
			}

			/// zoom and the gps button
			MapControlButtons(
				onZoomIn: zoomIn,
				onZoomOut: zoomOut,
				onGpsTap: handleGpsButton
			)
		}
		.onAppear {
			setupInitialRegion()
		}
		.onChange(of: locationManager.currentLocation) { _, loc in
			updateRegionForLocation(loc)
		}
		.sheet(item: $selectedPlace) { place in
			PlaceDetailView(place: place)
		}
		.safeAreaInset(edge: .bottom) {
			bottomSheet
		}
	}

	//  THE LIST SECTION IS HERE  ************************************************
	private var bottomSheet: some View {
		Group {
			if viewModel.showList {
				VStack(spacing: 10) {

					/// collapse list button
					HStack {
						Button {
							withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
								viewModel.showList = false
							}
						} label: {
							Image(systemName: "chevron.down.circle.fill")
								.font(.title2)
								.foregroundColor(.white)
								.padding(6)
								.background(Theme.beaconBrown)
								.cornerRadius(12)
								.shadow(radius: 3)
						}

						//( search bar
						SearchBarWithSuggestions(
							query: $viewModel.query,
							suggestions: suggestions,
							onSelect: { suggestion in
								Task {
									suggestions = []
									viewModel.query = suggestion.formatted

									let coordinate = CLLocationCoordinate2D(
										latitude: suggestion.lat,
										longitude: suggestion.lon
									)

									moveMap(to: coordinate)
									await viewModel.fetch(
										center: coordinate,
										radiusKm: radiusKm
									)
									withAnimation {
										viewModel.showList = false
									}
								}
							},
							onSearch: { query in
								Task {
									await searchForAddress(query)
									suggestions = []
									withAnimation {
										viewModel.showList = false
									}
								}
							},
							onQueryChange: { newValue in
								Task {
									if newValue.count >= 3 {
										do {
											suggestions = try await autocompleteService
												.fetchSuggestions(for: newValue)
										} catch {
											suggestions = []
										}
									} else {
										suggestions = []
									}
								}
							},
							onCloseSuggestions: {
								suggestions = []
								withAnimation {
									viewModel.showList = false
								}
							}
						)
					}
					.padding(.top, 8)

					/// sorting and favorites toggle
					HStack {
						Picker("Sorter", selection: $viewModel.sort) {
							ForEach(ExploreViewModel.SortMode.allCases) { mode in
								Text(mode.title).tag(mode)
							}
						}
						.pickerStyle(.segmented)

						Toggle("Kun favoritter", isOn: $viewModel.onlyFavorites)
							.toggleStyle(.switch)
					}

					Divider()

					/// list of places with filters
					PlaceListView(
						places: filteredSortedPlaces,
						averageFill: { averageFill(for: $0) },
						onSelect: { place in
							selectedPlace = place
						},
						onRefresh: {
							await viewModel.fetch(center: centreCoordinate, radiusKm: radiusKm)
						}
					)
					.background(.thinMaterial)
				}
				.padding(.horizontal)
				.padding(.top, 20)
				.padding(.bottom)
				.background(
					RoundedRectangle(cornerRadius: 25)
						.fill(.ultraThinMaterial)
						.ignoresSafeArea(edges: .bottom)
				)
				.transition(.move(edge: .bottom))
			}
		}
	}

	//  THE HELPER FUNCTIONS SECTION IS HERE  ************************************************

	/// sets the starting map position
	private func setupInitialRegion() {
		let startRegion = MKCoordinateRegion(
			center: CLLocationCoordinate2D(latitude: mapLat, longitude: mapLon),
			span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
		)
		currentRegion = startRegion
		cameraPosition = .region(startRegion)
	}

	/// moves map position to a new user location
	private func updateRegionForLocation(_ loc: CLLocation?) {
		guard let loc else { return }

		withAnimation(.easeInOut(duration: 0.4)) {
			let region = MKCoordinateRegion(
				center: loc.coordinate,
				span: .init(latitudeDelta: 0.03, longitudeDelta: 0.03)
			)
			currentRegion = region
			cameraPosition = .region(region)
		}
	}

	/// moves map to a specific coordinate and updates stored center
	private func moveMap(to coordinate: CLLocationCoordinate2D) {
		withAnimation(.easeInOut(duration: 0.4)) {
			let region = MKCoordinateRegion(
				center: coordinate,
				span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05)
			)
			currentRegion = region
			cameraPosition = .region(region)
			mapLat = coordinate.latitude
			mapLon = coordinate.longitude
		}
	}

	/// resets filters to defaults and refetches from api
	private func resetFiltersAsync() async {
		viewModel.query = ""
		radiusKm = 5
		viewModel.category = .restaurant
		viewModel.sort = .distance
		viewModel.onlyFavorites = false

		mapLat = 59.9111
		mapLon = 10.7503

		setupInitialRegion()
		await viewModel.fetch(center: centreCoordinate, radiusKm: radiusKm)
	}

	/// fixes average rating for a place
	private func averageFill(for placeId: String) -> Double {
		let ratings = allRatings.filter { $0.placeId == placeId }
		guard !ratings.isEmpty else { return 0 }

		let sum = ratings.map(\.value).reduce(0, +)
		let avg = Double(sum) / Double(ratings.count)

		return max(0, min(1, avg / 5.0))
	}

	/// zooming in on map here
	private func zoomIn() {
		guard let region = currentRegion else { return }

		withAnimation(.easeInOut(duration: 0.25)) {
			let newSpan = MKCoordinateSpan(
				latitudeDelta: max(region.span.latitudeDelta * 0.8, 0.002),
				longitudeDelta: max(region.span.longitudeDelta * 0.8, 0.002)
			)
			let newRegion = MKCoordinateRegion(center: region.center, span: newSpan)
			currentRegion = newRegion
			cameraPosition = .region(newRegion)
		}
	}

	/// zooming out on map here
	private func zoomOut() {
		guard let region = currentRegion else { return }

		withAnimation(.easeInOut(duration: 0.25)) {
			let newSpan = MKCoordinateSpan(
				latitudeDelta: min(region.span.latitudeDelta * 1.25, 1.0),
				longitudeDelta: min(region.span.longitudeDelta * 1.25, 1.0)
			)
			let newRegion = MKCoordinateRegion(center: region.center, span: newSpan)
			currentRegion = newRegion
			cameraPosition = .region(newRegion)
		}
	}

	/// handles tap on the gps button
	private func handleGpsButton() {
		switch locationManager.authorization {
		case .authorizedAlways, .authorizedWhenInUse:
			if let loc = locationManager.currentLocation {
				updateRegionForLocation(loc)
			} else {
				locationManager.locate()
				fallbackToOsloS()
			}

		case .notDetermined:
			locationManager.request()

		default:
			fallbackToOsloS()
		}
	}
 /// fallback to solo s
	private func fallbackToOsloS() {
		let oslo = CLLocationCoordinate2D(latitude: 59.9111, longitude: 10.7503)
		moveMap(to: oslo)
	}

	private func searchForAddress(_ query: String) async {
		guard !query.isEmpty else { return }

		let request = MKLocalSearch.Request()
		request.naturalLanguageQuery = query

		let search = MKLocalSearch(request: request)

		do {
			let response = try await search.start()
			if let firstResult = response.mapItems.first {
				let coordinate = firstResult.placemark.coordinate
				moveMap(to: coordinate)
				await viewModel.fetch(center: coordinate, radiusKm: radiusKm)
			}
		} catch {
			viewModel.errorMessage = "Fant ingen treff for '\(query)'."
		}
	}
}
