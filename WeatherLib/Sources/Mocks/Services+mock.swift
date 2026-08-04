//
//  Services+mock.swift
//  WeatherLib
//
//  Created by Vitaliy Pykhtin on 14.03.2026.
//

public import Domain
import Toolbox
import UIKit

struct MockDownloadService: DownloadService {
	func loadImage(from url: URL, update: @escaping (UIImage) -> Void) -> UIImage {
		return UIImage(systemName: "cloud.sun.fill")!
	}
}

struct MockNetworkService: NetworkService {
	func fetchCurrentWeather(latitude: Double, longitude: Double) async throws -> DTOCurrentWeatherResponse {
		throw NetworkServiceError.invalidResponse
	}

	func fetchForecast(latitude: Double, longitude: Double, days: Int) async throws -> DTOForecastResponse {
		throw NetworkServiceError.invalidURL
	}
}

@MainActor
extension Services {
	public static var mock: Services {
		Services(networkService: MockNetworkService(), downloadService: MockDownloadService())
	}
}
