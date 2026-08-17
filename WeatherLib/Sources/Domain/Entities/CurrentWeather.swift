//
//  CurrentWeather.swift
//  WeatherLib
//
//  Created by Vitaliy Pykhtin on 04.08.2026.
//


public import Foundation
package import Toolbox

public struct CurrentWeather: Equatable {
	public let location: String
	public let humidity: Int
	public let temperature: Measurement<UnitTemperature>
	public let windSpeed: Measurement<UnitSpeed>
	public let iconURL: URL

	package init(location: String, humidity: Int, temperature: Measurement<UnitTemperature>, windSpeed: Measurement<UnitSpeed>, iconURL: URL) {
		self.location = location
		self.humidity = humidity
		self.temperature = temperature
		self.windSpeed = windSpeed
		self.iconURL = iconURL
	}
}

extension CurrentWeather {
	package init(dto: DTOCurrentWeatherResponse) {
		location = "\(dto.location.name), \(dto.location.country)"
		humidity = dto.current.humidity
		temperature = Measurement(value: dto.current.temp_c, unit: .celsius)
		windSpeed = Measurement(value: dto.current.wind_kph, unit: .kilometersPerHour)
		iconURL = URL(string: "https:" + dto.current.condition.icon)!
	}
}
