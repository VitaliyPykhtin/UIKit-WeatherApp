// The Swift Programming Language
// https://docs.swift.org/swift-book

public import CoreLocation
public import Domain
public import UIKit

@Observable
public class Model {
	@ObservationIgnored
	private let services: Services
	@ObservationIgnored
	private var locationTask: Task<Void, Never>?

	public private(set) var isLoading: Bool = false
	public private(set) var weather: Result<Weather, any Error>? {
		didSet {
			isLoading = false
		}
	}

	public init(services: Services) {
		self.services = services
	}

	deinit {
		locationTask?.cancel()
	}

	public func startLocationUpdates() {
		locationTask?.cancel()

		locationTask = Task {
			do {
				// Implicit service sessions since iOS 18
				for try await update in CLLocationUpdate.liveUpdates() {
					print("Location updates: \(String(describing: update.location))")
					print("authorizationRequestInProgress: \(update.authorizationRequestInProgress)")
					print("accuracyLimited: \(update.accuracyLimited)")
					print("authorizationDenied: \(update.authorizationDenied)")
					print("authorizationDeniedGlobally: \(update.authorizationDeniedGlobally)")
					print("authorizationRestricted: \(update.authorizationRestricted)")
					print("insufficientlyInUse: \(update.insufficientlyInUse)")
					print("locationUnavailable: \(update.locationUnavailable)")
					print("serviceSessionRequired: \(update.serviceSessionRequired)")
					print("stationary: \(update.stationary)")

					if let location = update.location {
						if case let .success(weather) = weather, weather.location.distance(from: location) < 15_000 {
							continue
						}

						fetchWeather(for: location)
					} else if
						update.authorizationRequestInProgress == false &&
							update.authorizationDenied == true ||
							update.authorizationDeniedGlobally == true ||
							update.authorizationRestricted == true ||
							update.locationUnavailable == true ||
							update.serviceSessionRequired == true {
						fetchWeather()
					}
				}
			} catch {
				print("CLLocationUpdate error: $error)")
				fetchWeather()
			}
		}
	}

	public func fetchWeather(for location: CLLocation = CLLocation(latitude: 55.7558, longitude: 37.6173)) {
		guard isLoading == false else { return }

		isLoading = true
		Task { [networkService = services.networkService] in
			do {
				async let current = try networkService.fetchCurrentWeather(
					latitude: location.coordinate.latitude,
					longitude: location.coordinate.longitude
				)

				async let forecast = try networkService.fetchForecast(
					latitude: location.coordinate.latitude,
					longitude: location.coordinate.longitude,
					days: 3
				)

				weather = .success(try await Weather(current: current, forecast: forecast, location: location))
			} catch {
				weather = .failure(error)
			}
		}
	}

	public func loadImage(from url: URL, update: @escaping (UIImage) -> Void) -> UIImage {
		services.downloadService.loadImage(from: url, update: update)
	}
}
