//
//  WebService.swift
//  WeatherApp
//
//  Created by Vitaliy Pykhtin on 12.03.2026.
//

import Foundation

actor WebService {

	// MARK: - Singleton

	static let shared = WebService()

	// MARK: - Methods

	private func performRequest<T: Decodable>(url: URL) async throws -> T {
		print("Request from: \(url)")
		let (data, response) = try await URLSession.shared.data(from: url)

		guard let httpResp = response as? HTTPURLResponse,
			  200..<300 ~= httpResp.statusCode else {
			throw WebServiceError.invalidResponse
		}

		do {
			// В API‑документации время в формате ISO8601, но для простоты
			// оставляем стандартный decoder.
			return try JSONDecoder().decode(T.self, from: data)
		} catch {
			throw WebServiceError.decodingFailed(error)
		}
	}

	// MARK: - Public

	/// Получить текущую погоду по координатам.
	///
	/// - Parameters:
	///   - latitude: широта
	///   - longitude: долгота
	/// - Returns: `CurrentWeatherResponse` – модель, описанная в API‑документации
	/// - Throws: `WebServiceError` – если запрос не удался или JSON‑парсинг не прошёл
	func fetchCurrentWeather(latitude: Double,
							 longitude: Double) async throws -> DTOCurrentWeatherResponse {
		try await performRequest(url: .apiCurrent(latitude: latitude, longitude: longitude))
	}

	/// Получить прогноз на несколько дней (по умолчанию 3 дня) по координатам.
	///
	/// - Parameters:
	///   - latitude: широта
	///   - longitude: долгота
	///   - days: количество дней (от 1 до 10)
	/// - Returns: `ForecastResponse` – модель, описанная в API‑документации
	/// - Throws: `WebServiceError`
	func fetchForecast(latitude: Double,
					   longitude: Double,
					   days: Int = 3) async throws -> DTOForecastResponse {
		try await performRequest(url: .apiForecast(latitude: latitude, longitude: longitude, days: days))
	}

	
}
