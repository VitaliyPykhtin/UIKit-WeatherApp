//
//  CurrentWeatherReusableView.swift
//  WeatherApp
//
//  Created by Vitaliy Pykhtin on 12.08.2026.
//

import UIKit

final class CurrentWeatherReusableView: UICollectionReusableView {
	var view: CurrentWeatherView? {
		didSet {
			if let oldValue {
				oldValue.removeFromSuperview()
			}
			guard let view else { return }

			view.frame = bounds
			view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			addSubview(view)
		}
	}
}
