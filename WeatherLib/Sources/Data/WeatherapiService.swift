//
//  WeatherapiService.swift
//  WeatherApp
//
//  Created by Vitaliy Pykhtin on 12.03.2026.
//

import Domain
import Foundation
import Toolbox

struct WeatherapiService: NetworkService {

	private let serviceDateDecodingStrategy = JSONDecoder.DateDecodingStrategy.custom { decoder in
		let container = try decoder.singleValueContainer()
		let dateStr = try container.decode(String.self)
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		if dateStr.count == 10 {
			dateFormatter.dateFormat = "yyyy-MM-dd"
		} else {
			dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
		}
		guard let date = dateFormatter.date(from: dateStr) else {
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateStr)")
		}
		return date
	}

	// MARK: - Methods

	private func performRequest<T: Decodable>(url: URL) async throws -> T {
		print("Request from: \(url)")
		let (data, response) = try await URLSession.shared.data(from: url)
		print("Response: \(response)")

		guard let httpResp = response as? HTTPURLResponse, 200..<300 ~= httpResp.statusCode else {
			throw NetworkServiceError.invalidResponse
		}
		print(String(data: data, encoding: .utf8) ?? "")

		do {
			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = serviceDateDecodingStrategy
			return try decoder.decode(T.self, from: data)
		} catch {
			print(error)
			throw NetworkServiceError.decodingFailed(error)
		}
	}

	// MARK: - Public

	/// Get current weather by coordinates.
	///
	/// - Parameters:
	///   - latitude: latitude
	///   - longitude: longitude
	/// - Returns: `CurrentWeatherResponse` – model described in API documentation
	/// - Throws: `NetworkServiceError` – if request failed or JSON parsing failed
	func fetchCurrentWeather(latitude: Double, longitude: Double) async throws -> DTOCurrentWeatherResponse {
		try await performRequest(url: .apiCurrent(latitude: latitude, longitude: longitude))
	}

	/// Get forecast for several days (default 3 days) by coordinates.
	///
	/// - Parameters:
	///   - latitude: latitude
	///   - longitude: longitude
	///   - days: number of days (from 1 to 3)
	/// - Returns: `ForecastResponse` – model described in API documentation
	/// - Throws: `NetworkServiceError`
	func fetchForecast(latitude: Double, longitude: Double, days: Int = 3) async throws -> DTOForecastResponse {
		try await performRequest(url: .apiForecast(latitude: latitude, longitude: longitude, days: days))
	}
}
