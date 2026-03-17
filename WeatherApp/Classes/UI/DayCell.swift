//
//  DayCell.swift
//  WeatherApp
//
//  Created by Vitaliy Pykhtin on 13.03.2026.
//

import UIKit
import Model

class DayCell: UICollectionViewCell {
	static let id = "DayCell"

	private let dateLabel = UILabel()
	private let iconView = UIImageView()
	private let tempRangeLabel = UILabel()

	override init(frame: CGRect) {
		super.init(frame: frame)
		contentView.backgroundColor = UIColor.systemGray6
		contentView.layer.cornerRadius = 8

		dateLabel.font = .app14Medium
		dateLabel.textAlignment = .center

		iconView.contentMode = .scaleAspectFit
		iconView.tintColor = .label

		tempRangeLabel.font = .app12
		tempRangeLabel.textAlignment = .center

		let stack = UIStackView(arrangedSubviews: [dateLabel, iconView, tempRangeLabel])
		stack.axis = .vertical
		stack.spacing = 6
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

	func configure(with model: DayWeather, image: UIImage) {
		dateLabel.text = model.date.formatted(date: .numeric, time: .omitted)
		tempRangeLabel.text = "\(model.minTemp.formatted()) / \(model.maxTemp.formatted())"
		iconView.image = image
	}
}
