//
//  CurrentWeatherView.swift
//  WeatherApp
//
//  Created by Vitaliy Pykhtin on 13.03.2026.
//

import UIKit
import Model

/// CurrentWeatherView (location / temp / icon / wind & humidity)
final class CurrentWeatherView: UIView {
    // MARK: Subviews
    private let locationLabel = UILabel()
    private let tempLabel      = UILabel()
    private let conditionImageView = UIImageView()
    private let windHumidityLabel  = UILabel()

    // MARK: Init
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

    required init?(coder: NSCoder) { fatalError() }

    // MARK: Setup
    private func setup() {
		isHidden = true
		
        locationLabel.font = .app20Semibold
		tempLabel.font     = .app64Thin
        conditionImageView.contentMode = .scaleAspectFit
        windHumidityLabel.font = .app15

        let stack = UIStackView(arrangedSubviews: [
            locationLabel,
            tempLabel,
            conditionImageView,
            windHumidityLabel
        ])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center

        addSubview(stack)
		
		stack.translatesAutoresizingMaskIntoConstraints = false

		let bindings: [String : UIView] = ["stack" : stack]
		var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[stack]|",
													  metrics: nil, views: bindings)
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[stack]|",
													  metrics: nil, views: bindings)
		NSLayoutConstraint.activate(constraints)
    }
	
	func configure(with model: CurrentWeather, image: UIImage) {
		isHidden = false
		
		locationLabel.text = model.location
		tempLabel.text = model.temperature.formatted()
		windHumidityLabel.text = "Ветер \(model.windSpeed.formatted()) | Влажность \(model.humidity)%"
		conditionImageView.image = image
	}
}
