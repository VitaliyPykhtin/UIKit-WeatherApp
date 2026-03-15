//
//  InMemoryDownloadService.swift
//  WeatherApp
//
//  Created by Vitaliy Pykhtin on 13.03.2026.
//

import UIKit
import Model

@MainActor
class InMemoryDownloadService: DownloadService {
	
	// MARK: – Private
	
	private let cache = NSCache<NSString, UIImage>()
	private var ongoingRequests: [URL: [(UIImage) -> Void]] = [:]
	
	private let placeholder = UIImage(systemName: "photo") ?? UIImage()
	private let thumbnailSize = CGSize(width: 64, height: 64)
	
	/// Загружает изображение.
	/// Возвращается placeholder сразу, а после загрузки – вызывается `update` для всех
	/// подписчиков к данному URL.
	func loadImage(from url: URL, update: @escaping (UIImage) -> Void) -> UIImage {
		if let cached = cache.object(forKey: url.absoluteString as NSString) {
			return cached
		}
		
		if var handlers = ongoingRequests[url] {
			handlers.append(update)
			ongoingRequests[url] = handlers
			return placeholder
		}
		
		ongoingRequests[url] = [update]
		
		URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
			guard let self = self else { return }
			
			guard let data else {
				DispatchQueue.main.async {
					self.ongoingRequests[url] = nil
				}
				return
			}
			
			UIImage(data: data)?.prepareThumbnail(of: self.thumbnailSize) { thumbnail in
				DispatchQueue.main.async {
					print("Downloaded image: \(url)")
					if let thumbnail {
						self.cache.setObject(thumbnail, forKey: url.absoluteString as NSString)
						let handlers = self.ongoingRequests[url] ?? []
						for handler in handlers {
							handler(thumbnail)
						}
					}
					self.ongoingRequests[url] = nil
				}
			}
		}.resume()
		
		return placeholder
	}
}
