//
//  DayWeather.swift
//  WeatherLib
//
//  Created by Vitaliy Pykhtin on 04.08.2026.
//

public import Foundation
package import Toolbox

public struct DayWeather: Hashable, Sendable {
	public let date: Date
	public let minTemp: Measurement<UnitTemperature>
	public let maxTemp: Measurement<UnitTemperature>
	public let iconURL: URL

	package init(
		date: Date,
		minTemp: Measurement<UnitTemperature>,
		maxTemp: Measurement<UnitTemperature>,
		iconURL: URL
	) {
		self.date = date
		self.minTemp = minTemp
		self.maxTemp = maxTemp
		self.iconURL = iconURL
	}
}

extension DayWeather {
	package init(dto: DTOForecastResponse.ForecastDay) {
		date = dto.date
		minTemp = Measurement(value: dto.day.mintemp_c, unit: .celsius)
		maxTemp = Measurement(value: dto.day.maxtemp_c, unit: .celsius)
		iconURL = URL(string: "https:" + dto.day.condition.icon)!
	}
}
