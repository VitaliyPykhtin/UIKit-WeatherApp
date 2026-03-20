//
//  NetworkServiceError.swift
//  WeatherApp
//
//  Created by Vitaliy Pykhtin on 12.03.2026.
//

public  import Foundation

public enum NetworkServiceError: LocalizedError {
	case invalidURL
	case invalidResponse
	case decodingFailed(any Error)
	
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
