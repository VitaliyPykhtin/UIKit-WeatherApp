//
//  Services+init.swift
//  WeatherLib
//
//  Created by Vitaliy Pykhtin on 14.03.2026.
//

public import Model

@MainActor
extension Services {
	public init() {
		self.init(networkService: WeatherapiService(), downloadService: InMemoryDownloadService())
	}
}
