//
//  WebServiceError.swift
//  WeatherApp
//
//  Created by Vitaliy Pykhtin on 12.03.2026.
//

import Foundation

enum WebServiceError: LocalizedError {
	case invalidURL
	case invalidResponse
	case decodingFailed(Error)
	
	var errorDescription: String? {
		switch self {
		case .invalidURL:
			return "Сформирован неверный URL."
		case .invalidResponse:
			return "Не удалось получить корректный ответ от сервера."
		case .decodingFailed(let err):
			return "Ошибка декодирования: \(err.localizedDescription)"
		}
	}
}
