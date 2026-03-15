//
//  UIFont+Factory.swift
//  WeatherApp
//
//  Created by Vitaliy Pykhtin on 15.03.2026.
//

import UIKit

extension UIFont {
	static var app12: UIFont {
		.preferredFont(forTextStyle: .caption1)
	}
	
	static var app14Medium: UIFont {
		UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: .systemFont(ofSize: 14, weight: .medium))
	}
	
	static var app15: UIFont {
		.preferredFont(forTextStyle: .subheadline)
	}

	static var app17Semibold: UIFont {
		.preferredFont(forTextStyle: .headline)
	}
	
	static var app20Semibold: UIFont {
		UIFontMetrics(forTextStyle: .title3).scaledFont(for: .systemFont(ofSize: 20, weight: .semibold))
	}

	static var app64Thin: UIFont {
		UIFontMetrics(forTextStyle: .extraLargeTitle).scaledFont(for: .systemFont(ofSize: 64, weight: .thin))
	}
}
