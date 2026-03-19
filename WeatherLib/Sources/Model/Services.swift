//
//  Services.swift
//  WeatherLib
//
//  Created by Vitaliy Pykhtin on 14.03.2026.
//

import Toolbox
import UIKit

package protocol DownloadService: Sendable {
	/// Загружает изображение.
	/// Возвращается placeholder сразу, а после загрузки – вызывается `update` для всех
	/// подписчиков к данному URL.
	func loadImage(from url: URL, update: @escaping (UIImage) -> Void) -> UIImage
}

nonisolated package protocol NetworkService: Sendable {
	/// Получить текущую погоду по координатам.
	///
	/// - Parameters:
	///   - latitude: широта
	///   - longitude: долгота
	/// - Returns: `CurrentWeatherResponse` – модель, описанная в API‑документации
	/// - Throws: `NetworkServiceError` – если запрос не удался или JSON‑парсинг не прошёл
	func fetchCurrentWeather(latitude: Double, longitude: Double) async throws -> DTOCurrentWeatherResponse

	/// Получить прогноз на несколько дней (по умолчанию 3 дня) по координатам.
	///
	/// - Parameters:
	///   - latitude: широта
	///   - longitude: долгота
	///   - days: количество дней (от 1 до 10)
	/// - Returns: `ForecastResponse` – модель, описанная в API‑документации
	/// - Throws: `NetworkServiceError`
	func fetchForecast(latitude: Double, longitude: Double, days: Int) async throws -> DTOForecastResponse
}

nonisolated public struct Services {
	let networkService: NetworkService
	let downloadService: DownloadService

	package init(networkService: NetworkService, downloadService: DownloadService) {
		self.networkService = networkService
		self.downloadService = downloadService
	}
}
