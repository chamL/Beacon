import SwiftUI
import Foundation
import MapKit
import CoreLocation


//INFO
/// handing autocomplete for places and address searches using the api
/// alos using secrets.value for to hide the api key
 

struct GeoapifyAutocompleteResult: Identifiable {
	let id = UUID()
	let formatted: String
	let lat: Double
	let lon: Double
}

@MainActor
final class GeoapifyAutocompleteService: ObservableObject {

	private let apiKey: String
	private let baseURL = "https://api.geoapify.com/v1/geocode/autocomplete"

	/// getting the api key from keys.plist if not passed in
	init(apiKey: String? = nil) {
		self.apiKey = apiKey ?? (Secrets.value(forKey: "GeoapifyAPIKey") ?? "")
	}

	/// fetches address place suggestions from api based on  input
	func fetchSuggestions(for query: String) async throws -> [GeoapifyAutocompleteResult] {
		let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmed.isEmpty else { return [] }

		let encodedQuery = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
		let urlString = "\(baseURL)?text=\(encodedQuery)&limit=5&apiKey=\(apiKey)"
		guard let url = URL(string: urlString) else { return [] }

		let (data, response) = try await URLSession.shared.data(from: url)
		guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
			throw URLError(.badServerResponse)
		}

		let decoded = try JSONDecoder().decode(GeoapifyAutocompleteResponse.self, from: data)
		return decoded.features.map {
			GeoapifyAutocompleteResult(
				formatted: $0.properties.formatted,
				lat: $0.properties.lat,
				lon: $0.properties.lon
			)
		}
	}

	private struct GeoapifyAutocompleteResponse: Codable {
		let features: [Feature]

		struct Feature: Codable {
			let properties: Properties

			struct Properties: Codable {
				let formatted: String
				let lat: Double
				let lon: Double
			}
		}
	}
}

/// search bar with suggestions
struct SearchBarWithSuggestions: View {
	@Binding var query: String
	var suggestions: [GeoapifyAutocompleteResult]
	var onSelect: (GeoapifyAutocompleteResult) -> Void
	var onSearch: (String) -> Void
	var onQueryChange: (String) -> Void
	var onCloseSuggestions: () -> Void

	//  THE BODY SECTION IS HERE  ************************************************
	var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			HStack {
				// Main search text field
				TextField("Søk etter sted eller adresse…", text: $query)
					.textFieldStyle(.roundedBorder)
					.onSubmit { onSearch(query) }
					.onChange(of: query) { _, newValue in
						onQueryChange(newValue)
					}

				/// close button shown when we you have suggestions
				if !suggestions.isEmpty {
					Button {
						onCloseSuggestions()
					} label: {
						Image(systemName: "xmark.circle.fill")
							.foregroundColor(.gray)
							.font(.title3)
							.padding(.leading, 4)
							.accessibilityLabel("Lukk søkeforslag")
					}
				}
			}

			/// suggestion list for the search
			if !suggestions.isEmpty {
				ScrollView {
					VStack(alignment: .leading, spacing: 4) {
						ForEach(suggestions) { suggestion in
							Button {
								onSelect(suggestion)
							} label: {
								Text(suggestion.formatted)
									.font(.subheadline)
									.frame(maxWidth: .infinity, alignment: .leading)
									.padding(6)
									.background(Color(.systemGray6))
									.cornerRadius(6)
							}
						}
					}
					.padding(6)
				}
				.frame(maxHeight: 120)
				.background(.thinMaterial)
				.cornerRadius(10)
				.shadow(radius: 3)
				.transition(.move(edge: .top).combined(with: .opacity))
			}
		}
		.animation(.easeInOut, value: suggestions.isEmpty)
	}
}
