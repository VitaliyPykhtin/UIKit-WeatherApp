//
//  WeatherData.swift
//  WeatherApp
//
//  Created by Vitaliy Pykhtin on 12.03.2026.
//

import Foundation

nonisolated
struct DTOCurrentWeatherResponse: Decodable {
	let location: Location
	let current: Current

	struct Location: Decodable {
		let name: String
		let region: String?
		let country: String
	}

	struct Current: Decodable {
		let temp_c: Double
		let condition: DTOCondition
		let wind_kph: Double
		let humidity: Int
	}
}
