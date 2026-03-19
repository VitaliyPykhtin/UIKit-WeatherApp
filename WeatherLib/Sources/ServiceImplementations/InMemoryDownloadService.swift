//
//  InMemoryDownloadService.swift
//  WeatherApp
//
//  Created by Vitaliy Pykhtin on 13.03.2026.
//

import Model
import UIKit

@MainActor
class InMemoryDownloadService: DownloadService {

	// MARK: – Private

	private let cache = NSCache<NSString, UIImage>()
	private var ongoingRequests: [URL: [(UIImage) -> Void]] = [:]

	private let placeholder = UIImage(systemName: "photo") ?? UIImage()
	private let thumbnailSize = CGSize(width: 64, height: 64)

	private func storeAndBroadcast(_ thumbnail: UIImage, for url: URL) {
		cache.setObject(
			thumbnail,
			forKey: url.absoluteString as NSString,
			cost: Int(thumbnail.size.width * thumbnail.size.height)
		)
		let handlers = ongoingRequests[url] ?? []
		for handler in handlers {
			handler(thumbnail)
		}
	}

	private func cleanUp(for url: URL) {
		ongoingRequests[url] = nil
	}

	/// Loads an image.
	/// Returns placeholder immediately, and after loading - calls `update` for all
	/// subscribers to this URL.
	func loadImage(from url: URL, update: @escaping (UIImage) -> Void) -> UIImage {
		if let cached = cache.object(forKey: url.absoluteString as NSString) {
			return cached
		}

		if var handlers = ongoingRequests[url] {
			handlers += [update]
			ongoingRequests[url] = handlers
			return placeholder
		}

		ongoingRequests[url] = [update]

		Task {
			if let response = try? await URLSession.shared.data(from: url),
				let thumbnail = await UIImage(data: response.0)?.byPreparingThumbnail(ofSize: thumbnailSize)
			{
				print("Downloaded image: \(url)")
				storeAndBroadcast(thumbnail, for: url)
			}
			cleanUp(for: url)
		}

		return placeholder
	}
}
