// The Swift Programming Language
// https://docs.swift.org/swift-book

public import CoreLocation
package import Toolbox
public import UIKit

nonisolated public struct DayWeather: Hashable, Sendable {
	public let date: Date
	public let minTemp: Measurement<UnitTemperature>
	public let maxTemp: Measurement<UnitTemperature>
	public let iconURL: URL

	package init(dto: DTOForecastResponse.ForecastDay) {
		date = dto.date
		minTemp = Measurement(value: dto.day.mintemp_c, unit: .celsius)
		maxTemp = Measurement(value: dto.day.maxtemp_c, unit: .celsius)
		iconURL = URL(string: "https:" + dto.day.condition.icon)!
	}
}

nonisolated public struct HourWeather: Hashable, Sendable {
	public let time: Date
	public let temp: Measurement<UnitTemperature>
	public let iconURL: URL

	package init(dto: DTOForecastResponse.ForecastDay.Hour) {
		time = dto.time
		temp = Measurement(value: dto.temp_c, unit: .celsius)
		iconURL = URL(string: "https:" + dto.condition.icon)!
	}
}

public struct CurrentWeather {
	public let location: String
	public let temperature: Measurement<UnitTemperature>
	public let windSpeed: Measurement<UnitSpeed>
	public let humidity: Int
	public let iconURL: URL

	package init(dto: DTOCurrentWeatherResponse) {
		location = "\(dto.location.name), \(dto.location.country)"
		temperature = Measurement(value: dto.current.temp_c, unit: .celsius)
		windSpeed = Measurement(value: dto.current.wind_kph, unit: .kilometersPerHour)
		humidity = dto.current.humidity
		iconURL = URL(string: "https:" + dto.current.condition.icon)!
	}
}

public struct Weather {
	public let current: CurrentWeather
	public let hourly: [HourWeather]
	public let forecast: [DayWeather]
	public let location: CLLocation
}

extension Weather {
	init(current: DTOCurrentWeatherResponse, forecast: DTOForecastResponse, location: CLLocation) {
		// Hourly
		let today = forecast.forecast.forecastday.first!
		let hourAgoDate = Date.now - 3600.0
		// Оставшиеся часы текущего дня
		var hourly = today.hour.drop { $0.time < hourAgoDate }.map(HourWeather.init)

		// Все часы следующего дня
		if forecast.forecast.forecastday.count > 1 {
			hourly.append(contentsOf: forecast.forecast.forecastday[1].hour.map(HourWeather.init))
		}

		self.init(
			current: CurrentWeather(dto: current),
			hourly: hourly,
			forecast: forecast.forecast.forecastday.map(DayWeather.init),
			location: location
		)
	}
}

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
