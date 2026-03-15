//
//  WeatherData.swift
//  WeatherApp
//
//  Created by Vitaliy Pykhtin on 12.03.2026.
//

package struct DTOCurrentWeatherResponse: Decodable {
	package let location: Location
	package let current: Current

	package struct Location: Decodable {
		package let name: String
		let region: String?
		package let country: String
	}

	package struct Current: Decodable {
		package let temp_c: Double
		package let condition: DTOCondition
		package let wind_kph: Double
		package let humidity: Int
	}
}
