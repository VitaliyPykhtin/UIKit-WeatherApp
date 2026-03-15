//
//  HourCell.swift
//  WeatherApp
//
//  Created by Vitaliy Pykhtin on 12.03.2026.
//

import UIKit
import Model

class HourCell: UICollectionViewCell {
	static let id = "HourCell"

	private let timeLabel = UILabel()
	private let iconView = UIImageView()
	private let tempLabel = UILabel()

	override init(frame: CGRect) {
		super.init(frame: frame)
		contentView.backgroundColor = UIColor.systemGray6
		contentView.layer.cornerRadius = 8

		timeLabel.font = .app12
		timeLabel.textAlignment = .center

		iconView.contentMode = .scaleAspectFit
		iconView.tintColor = .label

		tempLabel.font = .app14Medium
		tempLabel.textAlignment = .center

		let stack = UIStackView(arrangedSubviews: [timeLabel, iconView, tempLabel])
		stack.axis = .vertical
		stack.spacing = 4
		stack.alignment = .center
		contentView.addSubview(stack)
		
		stack.translatesAutoresizingMaskIntoConstraints = false
		
		iconView.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
		iconView.setContentCompressionResistancePriority(.defaultHigh - 1, for: .vertical)

		let bindings: [String : UIView] = ["stack" : stack]
		var constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-[stack]-|",
													  metrics: nil, views: bindings)
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[stack]-|",
													  metrics: nil, views: bindings)
		NSLayoutConstraint.activate(constraints)
	}

	required init?(coder: NSCoder) { fatalError() }

	func configure(with model: HourWeather, image: UIImage) {
		timeLabel.text = model.time
		tempLabel.text = model.temp.formatted()
		iconView.image = image
	}
}
