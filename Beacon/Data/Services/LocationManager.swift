import Foundation
import CoreLocation

// INFO
/// handles user location updates and authorization.
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

	private let manager = CLLocationManager()
	@Published var currentLocation: CLLocation?
	@Published var authorization: CLAuthorizationStatus = .notDetermined

	override init() {
		super.init()
		manager.delegate = self
		manager.desiredAccuracy = kCLLocationAccuracyBest
		manager.distanceFilter = 10 
	}

	//  THE PUBLIC FUNCTIONS SECTION IS HERE  ************************
	func request() {
		if manager.authorizationStatus == .notDetermined {
			manager.requestWhenInUseAuthorization()
		}
	}

	/// called when the user presses the gps button to go to my location.
	func locate() {
		switch authorization {
		case .authorizedAlways, .authorizedWhenInUse:
			manager.startUpdatingLocation()
		case .notDetermined:
			manager.requestWhenInUseAuthorization()
		default:
			break
		}
	}

	func stop() {
		manager.stopUpdatingLocation()
	}

	//  THE DELEGATE METHODS HERE  ************************
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		let status = manager.authorizationStatus

		DispatchQueue.main.async {
			self.authorization = status

			switch status {
			case .authorizedAlways, .authorizedWhenInUse:
				self.manager.startUpdatingLocation()
			case .denied, .restricted:
				self.manager.stopUpdatingLocation()
				self.currentLocation = nil
			case .notDetermined:
				break
			@unknown default:
				break
			}
		}
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let last = locations.last else { return }
		DispatchQueue.main.async {
			self.currentLocation = last
		}
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		DispatchQueue.main.async {
			print("❌ Failed to get location: \(error.localizedDescription)")
		}
	}
}
