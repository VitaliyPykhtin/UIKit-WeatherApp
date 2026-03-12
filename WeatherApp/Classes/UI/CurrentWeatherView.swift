//
//  CurrentWeatherView.swift
//  WeatherApp
//
//  Created by Vitaliy Pykhtin on 13.03.2026.
//

import UIKit

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
		
        locationLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        tempLabel.font     = .systemFont(ofSize: 64, weight: .thin)
        conditionImageView.contentMode = .scaleAspectFit
        windHumidityLabel.font = .systemFont(ofSize: 16)

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
	
	func configure(with current: DTOCurrentWeatherResponse) {
		isHidden = false
		
		locationLabel.text = "\(current.location.name), \(current.location.country)"
		tempLabel.text = Measurement(value: Double(current.current.temp_c), unit: UnitTemperature.celsius).formatted()
		windHumidityLabel.text =
		"Ветер \(Measurement(value: Double(current.current.wind_kph), unit: UnitSpeed.kilometersPerHour).formatted()) | Влажность \(current.current.humidity)%"

		// Icon
		if let url = URL(string: "https:"+current.current.condition.icon) {
			conditionImageView.image = DownloadService.shared.loadImage(from: url) { [weak self] in
				self?.conditionImageView.image = $0
			}
		}
	}
}
