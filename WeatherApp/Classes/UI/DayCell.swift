//
//  DayCell.swift
//  WeatherApp
//
//  Created by Vitaliy Pykhtin on 13.03.2026.
//

import UIKit

nonisolated
struct DayCellModel: Hashable {
	let date: String
	let minTempC: Double
	let maxTempC: Double
	let iconURL: URL

	init(day: DTOForecastResponse.ForecastDay) {
		self.date = day.date
		self.minTempC = day.day.mintemp_c
		self.maxTempC = day.day.maxtemp_c
		self.iconURL = URL(string: "https:"+day.day.condition.icon) ?? URL(fileURLWithPath: "")
	}
}

class DayCell: UICollectionViewCell {
	static let id = "DayCell"

	private let dateLabel = UILabel()
	private let iconView = UIImageView()
	private let tempRangeLabel = UILabel()

	override init(frame: CGRect) {
		super.init(frame: frame)
		contentView.backgroundColor = UIColor.systemGray6
		contentView.layer.cornerRadius = 8

		dateLabel.font = .systemFont(ofSize: 14, weight: .medium)
		dateLabel.textAlignment = .center

		iconView.contentMode = .scaleAspectFit
		iconView.tintColor = .label

		tempRangeLabel.font = .systemFont(ofSize: 12)
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

	func configure(with model: DayCellModel, image: UIImage) {
		dateLabel.text = model.date
		tempRangeLabel.text = "\(Measurement(value: Double(model.minTempC), unit: UnitTemperature.celsius).formatted()) / \(Measurement(value: Double(model.maxTempC), unit: UnitTemperature.celsius).formatted())"
		iconView.image = image
	}
}
