import SwiftUI
import MapKit
import SwiftData

// INFO
/// displays info about a selected place with animatio, info, rating and favorites
public struct PlaceDetailView: View {
	public let place: Place

	@Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var context
	@Query private var allRatings: [Rating]
	@Query private var favorites: [FavoritePlace]

	@State private var details: Place?
	@State private var rotation: Double = 0
	@State private var scale: CGFloat = 0.5
	@State private var steam1 = false
	@State private var steam2 = false
	@State private var steam3 = false
	@State private var showFavoriteToast = false
	@State private var isFavorite = false

	public init(place: Place) {
		self.place = place
	}

	//  THE BODY SECTION IS HERE  ************************************************
	public var body: some View {
		NavigationStack {
			ZStack {
				Theme.backgroundGradient
					.ignoresSafeArea()
				Rectangle()
					.fill(.ultraThinMaterial)
					.ignoresSafeArea()

				ScrollView {
					VStack(spacing: 20) {
						
						/// animated category icon
						CategoryAnimationView(
							category: place.category ?? "",
							rotation: $rotation,
							scale: $scale,
							steam1: $steam1,
							steam2: $steam2,
							steam3: $steam3
						)
						.frame(height: 80)
						.padding(.top, 20)

						/// info card and action buttons
						VStack(spacing: 16) {
							PlaceInfoSection(
								place: place,
								details: details,
								averageFill: averageFill
							)

							Divider().background(Theme.beaconBrown.opacity(0.4))

							/// buttons for maps and favorite
							HStack(spacing: 10) {
								Button("Åpne i Apple Maps", action: openInMaps)
									.buttonStyle(PrimaryButtonStyle(color: Theme.highlightBrown))

								favoriteButton
							}

							Divider().background(Theme.beaconBrown.opacity(0.4))

							/// rating section
							PlaceRatingSection(place: place, addRating: addRating)
						}
						.padding(20)
						.background(
							RoundedRectangle(cornerRadius: 18)
								.fill(Theme.goldAccentGradient.opacity(0.6))
								.shadow(color: Theme.beaconBrown.opacity(0.4),
										radius: 8, x: 0, y: 3)
						)
						.padding(.horizontal, 16)
						.padding(.bottom, 30)
					}
				}
				.navigationTitle("Detaljer")
				.navigationBarTitleDisplayMode(.inline)
				.tint(Theme.highlightBrown.opacity(0.8))
				.toolbar {
					ToolbarItem(placement: .topBarTrailing) {
						Button("Lukk") { dismiss() }
							.foregroundColor(Theme.highlightBrown)
					}
				}

				/// notification when favorite is added or removed
				if showFavoriteToast {
					FavoriteToast(isFavorite: isFavorite)
				}
			}
		}
		.onAppear {
			runCategoryAnimation()
			Task {
				await loadDetailsIfPossible()
			}
			isFavorite = favorites.contains(where: { $0.id == place.id })
		}
	}

	//  THE FAVORITE BUTTON SECTION IS HERE  ************************************************
	private var favoriteButton: some View {
		Button(action: toggleFavorite) {
			HStack {
				Image(systemName: isFavorite ? "heart.fill" : "heart")
				Text(isFavorite ? "Fjern favoritt" : "Legg til favoritt")
			}
			.fontWeight(.semibold)
			.padding(.horizontal, 14)
			.padding(.vertical, 10)
			.background(isFavorite ? Color.red.opacity(0.9) : Theme.beaconBrown)
			.foregroundColor(.white)
			.cornerRadius(12)
			.shadow(color: Theme.highlightBrown.opacity(0.4), radius: 4, x: 0, y: 2)
		}
	}

	//  THE MAIN ACTION FUNCTIONS SECTION IS HERE  ************************************************
	/// this opens the current place in Apple Maps
	private func openInMaps() {
		let item = MKMapItem(placemark: MKPlacemark(coordinate: place.coordinate))
		item.name = place.name
		item.openInMaps()
	}

	/// adds or removes a favorite with feedback.
	private func toggleFavorite() {
		do {
			let favorites = try context.fetch(FetchDescriptor<FavoritePlace>())
			if let existing = favorites.first(where: { $0.id == place.id }) {
				context.delete(existing)
				try context.save()
				isFavorite = false
				showToast(added: false)
			} else {
				context.insert(FavoritePlace(
					id: place.id,
					name: place.name,
					address: place.address ?? "",
					category: place.category
				))
				try context.save()
				isFavorite = true
				showToast(added: true)
			}
		} catch {
			print("❌ Error changing favorite status: \(error)")
		}
	}

	/// adds a rating to the current place.
	private func addRating(_ value: Int) {
		context.insert(Rating(placeId: place.id, value: value))
		try? context.save()
	}

	/// shows the favorite  for 2 seconds
	private func showToast(added: Bool) {
		withAnimation { showFavoriteToast = true }
		Task {
			try? await Task.sleep(for: .seconds(2))
			await MainActor.run {
				withAnimation { showFavoriteToast = false }
			}
		}
	}

	//  THE RATING AND ANIMATION SECTION IS HERE  ************************************************
	private var placeRatings: [Rating] {
		allRatings.filter { $0.placeId == place.id }
	}

	/// star fill
	private var averageFill: Double {
		let ratings = placeRatings
		guard !ratings.isEmpty else { return 0 }
		let avg = Double(ratings.map(\.value).reduce(0, +)) / Double(ratings.count)
		return max(0, min(1, avg / 5.0))
	}

	/// runs animation for on category
	private func runCategoryAnimation() {
		rotation = 0
		scale = 0.5
		let cat = (place.category ?? "").lowercased()

		if cat.contains("catering.restaurant") {
			withAnimation(.easeInOut(duration: 1.0)) { rotation = 360 }
		} else if cat.contains("catering.cafe") {
			withAnimation(.easeOut(duration: 1.0).repeatForever(autoreverses: false)) { steam1.toggle() }
			withAnimation(.easeOut(duration: 1.0).delay(0.3).repeatForever(autoreverses: false)) { steam2.toggle() }
			withAnimation(.easeOut(duration: 1.0).delay(0.6).repeatForever(autoreverses: false)) { steam3.toggle() }
		} else if cat.contains("accommodation") {
			withAnimation(.spring(response: 0.5, dampingFraction: 0.4)) { scale = 1.0 }
		}
	}

	private func loadDetailsIfPossible() async {
		do {
			let id = place.id
			let dto = try await GeoapifyService.shared.fetchPlaceDetails(placeId: id)

			if let props = dto.features.first?.properties {
				await MainActor.run {
					self.details = Place(
						id: place.id,
						name: props.name ?? place.name,
						address: props.addressLine1 ?? place.address,
						coordinate: place.coordinate,
						category: place.category,
						phone: props.phone ?? place.phone,
						openingHours: props.openingHours ?? place.openingHours
					)
				}
			}
		} catch {
			print("❌ Failed to load place details: \(error.localizedDescription)")
		}
	}
}
