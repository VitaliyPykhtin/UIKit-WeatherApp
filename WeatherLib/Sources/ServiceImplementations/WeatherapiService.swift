//
//  WeatherapiService.swift
//  WeatherApp
//
//  Created by Vitaliy Pykhtin on 12.03.2026.
//

import Foundation
import Model
import Toolbox

actor WeatherapiService: NetworkService {

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

	/// Получить текущую погоду по координатам.
	///
	/// - Parameters:
	///   - latitude: широта
	///   - longitude: долгота
	/// - Returns: `CurrentWeatherResponse` – модель, описанная в API‑документации
	/// - Throws: `NetworkServiceError` – если запрос не удался или JSON‑парсинг не прошёл
	func fetchCurrentWeather(latitude: Double, longitude: Double) async throws -> DTOCurrentWeatherResponse {
		try await performRequest(url: .apiCurrent(latitude: latitude, longitude: longitude))
	}

	/// Получить прогноз на несколько дней (по умолчанию 3 дня) по координатам.
	///
	/// - Parameters:
	///   - latitude: широта
	///   - longitude: долгота
	///   - days: количество дней (от 1 до 10)
	/// - Returns: `ForecastResponse` – модель, описанная в API‑документации
	/// - Throws: `NetworkServiceError`
	func fetchForecast(latitude: Double, longitude: Double, days: Int = 3) async throws -> DTOForecastResponse {
		try await performRequest(url: .apiForecast(latitude: latitude, longitude: longitude, days: days))
	}
}
