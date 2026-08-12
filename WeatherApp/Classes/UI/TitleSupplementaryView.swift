//
//  TitleSupplementaryView.swift
//  WeatherApp
//
//  Created by Vitaliy Pykhtin on 11.08.2026.
//

import UIKit

final class TitleSupplementaryView: UICollectionReusableView {
	let label = UILabel()

	// MARK: - Lifecycle

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required init?(coder: NSCoder) {
		fatalError()
	}

	// MARK: - Setup

	private func setup() {
		directionalLayoutMargins = .zero

		label.font = .app17Semibold
		label.adjustsFontForContentSizeCategory = true
		addSubview(label)

		label.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			label.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor),
			label.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor),
			label.topAnchor.constraint(equalTo: readableContentGuide.topAnchor),
			label.bottomAnchor.constraint(equalTo: readableContentGuide.bottomAnchor),
		])
	}
}

#Preview {
	let view = TitleSupplementaryView(frame: .init(x: 0, y: 0, width: 300, height: 30))
	view.label.text = "Title"

	view.layer.borderWidth = 1
	view.layer.borderColor = UIColor.tintColor.cgColor

	return view
}
