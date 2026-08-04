//
//  Models+fixtures.swift
//  WeatherLib
//
//  Created by Vitaliy Pykhtin on 05.08.2026.
//

public import Domain
import Foundation

public extension DayWeather {
	static let fixture = DayWeather(
		date: Date.now,
		minTemp: Measurement(value: 21, unit: .celsius),
		maxTemp: Measurement(value: 27, unit: .celsius),
		iconURL: URL(string: "https://sample.com/icon.png")!,
	)
}

public extension HourWeather {
	static let fixture = HourWeather(
		time: Date.now,
		temp: Measurement(value: 21, unit: .celsius),
		iconURL: URL(string: "https://sample.com/icon.png")!,
	)
}
