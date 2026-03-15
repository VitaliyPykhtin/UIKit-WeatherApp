//
//  NetworkServiceError.swift
//  WeatherApp
//
//  Created by Vitaliy Pykhtin on 12.03.2026.
//

import Foundation

public enum NetworkServiceError: LocalizedError {
	case invalidURL
	case invalidResponse
	case decodingFailed(Error)
	
	public var errorDescription: String? {
		switch self {
		case .invalidURL:
			"Сформирован неверный URL."
		case .invalidResponse:
			"Не удалось получить корректный ответ от сервера."
		case .decodingFailed(let err):
			"Ошибка декодирования: \(err.localizedDescription)"
		}
	}
}
