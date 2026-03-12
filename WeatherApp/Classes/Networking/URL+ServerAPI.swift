//
//  URL+ServerAPI.swift
//  WeatherApp
//
//  Created by Vitaliy Pykhtin on 12.03.2026.
//

import Foundation

private extension URL {
	enum API {
		static let base = URL(string: "https://api.weatherapi.com/")!
		static let apiKey = "fa8b3df74d4042b9aa7135114252304"
		
		enum Path {
			static let current = "v1/current.json"
			static let forecast = "v1/forecast.json"
		}
	}
	
	// TODO: Check again
	init(apiPath: String, latitude: Double, longitude: Double, queryItems: [URLQueryItem] = [], relativeTo url: URL = API.base) {
		var components = URLComponents(url: URL(string: apiPath, relativeTo: url)!,
									   resolvingAgainstBaseURL: true)!
		components.queryItems = [
			.init(name: "key", value: API.apiKey),
			.init(name: "q", value: "\(latitude),\(longitude)")
		] + queryItems
		self.init(string: components.string!)!
	}
}

extension URL {
	/// GET
	static func apiCurrent(latitude: Double, longitude: Double) -> URL {
		URL(apiPath: API.Path.current, latitude: latitude, longitude: longitude)
	}
	/// GET
	static func apiForecast(latitude: Double, longitude: Double, days: Int) -> URL {
		URL(apiPath: API.Path.forecast, latitude: latitude, longitude: longitude, queryItems: [.init(name: "days", value: "\(days)")])
	}
}
