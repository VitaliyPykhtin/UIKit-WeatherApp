// The Swift Programming Language
// https://docs.swift.org/swift-book

import CoreLocation
import Toolbox
import UIKit

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

extension Notification.Name {
	public static let weatherFetching = Notification.Name("Model.weatherFetching")
	public static let weatherChanged = Notification.Name("Model.weatherChanged")
}

// TODO: Migrate to @Observable
public class Model {
	private let services: Services

	public private(set) var isLoading: Bool = false {
		didSet {
			NotificationCenter.default.post(Notification(name: .weatherFetching))
		}
	}
	public private(set) var weather: Result<Weather, Error>? {
		didSet {
			isLoading = false
			NotificationCenter.default.post(Notification(name: .weatherChanged))
		}
	}

	public init(services: Services) {
		self.services = services
	}

	public func fetchWeather(for location: CLLocation) {
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
