//
//  HourWeather.swift
//  WeatherLib
//
//  Created by Vitaliy Pykhtin on 04.08.2026.
//


public import Foundation
package import Toolbox

public struct HourWeather: Hashable, Sendable {
	public let time: Date
	public let temp: Measurement<UnitTemperature>
	public let iconURL: URL

	package init(time: Date, temp: Measurement<UnitTemperature>, iconURL: URL) {
		self.time = time
		self.temp = temp
		self.iconURL = iconURL
	}
}

extension HourWeather {
	package init(dto: DTOForecastResponse.ForecastDay.Hour) {
		time = dto.time
		temp = Measurement(value: dto.temp_c, unit: .celsius)
		iconURL = URL(string: "https:" + dto.condition.icon)!
	}
}
