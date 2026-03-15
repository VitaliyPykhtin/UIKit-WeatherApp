//
//  DTOForecastResponse.swift
//  WeatherApp
//
//  Created by Vitaliy Pykhtin on 13.03.2026.
//

package struct DTOForecastResponse: Decodable {
	package let forecast: Forecast

	package struct Forecast: Decodable {
		package let forecastday: [ForecastDay]
	}

	package struct ForecastDay: Decodable {
		package let date: String
		package let day: Day
		package let hour: [Hour]

		package struct Day: Decodable {
			package let maxtemp_c: Double
			package let mintemp_c: Double
			package let condition: DTOCondition
		}

		package struct Hour: Decodable {
			package let time: String
			package let temp_c: Double
			package let condition: DTOCondition
		}
	}
}
