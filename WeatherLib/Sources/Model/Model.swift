// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit
import CoreLocation
import Toolbox

public struct DayWeather: Hashable, Sendable {
	public let date: String
	public let minTemp: Measurement<UnitTemperature>
	public let maxTemp: Measurement<UnitTemperature>
	public let iconURL: URL
	
	package init(dto: DTOForecastResponse.ForecastDay) {
		date = dto.date
		minTemp = Measurement(value: dto.day.mintemp_c, unit: .celsius)
		maxTemp = Measurement(value: dto.day.maxtemp_c, unit: .celsius)
		iconURL = URL(string: "https:"+dto.day.condition.icon)!
	}
}

public struct HourWeather: Hashable, Sendable {
	public let time: String
	public let temp: Measurement<UnitTemperature>
	public let iconURL: URL

	package init(dto: DTOForecastResponse.ForecastDay.Hour) {
		time = dto.time.split(separator: " ").last.map(String.init) ?? ""
		temp = Measurement(value: dto.temp_c, unit: .celsius)
		iconURL = URL(string: "https:"+dto.condition.icon)!
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
		iconURL = URL(string: "https:"+dto.current.condition.icon)!
	}
}

public struct Weather {
	public let current: CurrentWeather
	public let hourly: [HourWeather]
	public let forecast: [DayWeather]
	public let location: CLLocation
}

public extension Notification.Name {
	static let weatherFetching = Notification.Name("Model.weatherFetching")
	static let weatherChanged = Notification.Name("Model.weatherChanged")
}

@MainActor
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
	
	private func updateModel(current: DTOCurrentWeatherResponse, forecast: DTOForecastResponse, location: CLLocation) {
		// Current
		let current = CurrentWeather(dto: current)

		// Hourly
		let today = forecast.forecast.forecastday.first!
		let nowHourIndex = Calendar.current.component(.hour, from: Date())
		// Оставшиеся часы текущего дня
		var hourly = today.hour.dropFirst(nowHourIndex).map(HourWeather.init)
		
		// Все часы следующего дня
		if forecast.forecast.forecastday.count > 1 {
			hourly.append(contentsOf: forecast.forecast.forecastday[1].hour.map(HourWeather.init))
		}

		// 3‑day forecast
		let forecast = forecast.forecast.forecastday.map(DayWeather.init)
		
		weather = .success(Weather(current: current, hourly: hourly, forecast: forecast, location: location))
	}
	
	public func fetchWeather(for location: CLLocation) {
		guard isLoading == false else { return }
		
		let coordinate = location.coordinate
		isLoading = true
		Task {
			do {
				let current = try await services.networkService.fetchCurrentWeather(
					latitude: coordinate.latitude,
					longitude: coordinate.longitude)
				
				let forecast = try await services.networkService.fetchForecast(
					latitude: coordinate.latitude,
					longitude: coordinate.longitude,
					days: 3)
				
				await MainActor.run {
					updateModel(current: current, forecast: forecast, location: location)
				}
			} catch {
				await MainActor.run {
					weather = .failure(error)
				}
			}
		}
	}
	
	public func loadImage(from url: URL, update: @escaping (UIImage) -> Void) -> UIImage {
		services.downloadService.loadImage(from: url, update: update)
	}
}
