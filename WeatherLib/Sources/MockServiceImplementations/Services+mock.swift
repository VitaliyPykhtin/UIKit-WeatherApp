//
//  Services+mock.swift
//  WeatherLib
//
//  Created by Vitaliy Pykhtin on 14.03.2026.
//

import UIKit
import Model
import Toolbox

class MockDownloadService: DownloadService {
	func loadImage(from url: URL, update: @escaping (UIImage) -> Void) -> UIImage {
		return UIImage(systemName: "cloud.sun.fill")!
	}
}

actor MockNetworkService: NetworkService {
	func fetchCurrentWeather(latitude: Double, longitude: Double) async throws -> DTOCurrentWeatherResponse {
		throw NetworkServiceError.invalidResponse
	}
	
	func fetchForecast(latitude: Double, longitude: Double, days: Int) async throws -> DTOForecastResponse {
		throw NetworkServiceError.invalidURL
	}
}

public extension Services {
	static var mock: Services {
		Services(networkService: MockNetworkService(), downloadService: MockDownloadService())
	}
}
