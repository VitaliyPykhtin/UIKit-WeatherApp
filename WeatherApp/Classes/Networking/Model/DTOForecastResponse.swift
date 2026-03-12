//
//  DTOForecastResponse.swift
//  WeatherApp
//
//  Created by Vitaliy Pykhtin on 13.03.2026.
//


nonisolated
struct DTOForecastResponse: Decodable {
	let forecast: Forecast

	struct Forecast: Decodable {
		let forecastday: [ForecastDay]
	}

	struct ForecastDay: Decodable {
		let date: String
		let day: Day
		let hour: [Hour]

		struct Day: Decodable {
			let maxtemp_c: Double
			let mintemp_c: Double
			let condition: DTOCondition
		}

		struct Hour: Decodable {
			let time: String
			let temp_c: Double
			let condition: DTOCondition
		}
	}
}
