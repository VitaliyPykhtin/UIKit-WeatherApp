//
//  Weather.swift
//  WeatherLib
//
//  Created by Vitaliy Pykhtin on 04.08.2026.
//


public import CoreLocation
package import Toolbox

public struct Weather {
	public let location: CLLocation
	public let current: CurrentWeather
	public let hourly: [HourWeather]
	public let forecast: [DayWeather]

	package init(current: DTOCurrentWeatherResponse, forecast: DTOForecastResponse, location: CLLocation) {
		// Hourly
		let today = forecast.forecast.forecastday.first!
		let hourAgoDate = Date.now - 3600.0
		// Оставшиеся часы текущего дня
		var hourly = today.hour.drop { $0.time < hourAgoDate }.map(HourWeather.init)

		// Все часы следующего дня
		if forecast.forecast.forecastday.count > 1 {
			hourly.append(contentsOf: forecast.forecast.forecastday[1].hour.map(HourWeather.init))
		}

		self.location = location
		self.current = CurrentWeather(dto: current)
		self.hourly = hourly
		self.forecast = forecast.forecast.forecastday.map(DayWeather.init)
	}
}
