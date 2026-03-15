//
//  Services+init.swift
//  WeatherLib
//
//  Created by Vitaliy Pykhtin on 14.03.2026.
//

import Model

public extension Services {
	init() {
		self.init(networkService: WeatherapiService(), downloadService: InMemoryDownloadService())
	}
}
