//
//  StateView.swift
//  WeatherApp
//
//  Created by Vitaliy Pykhtin on 13.03.2026.
//

import UIKit

/// StateView (loading / error / retry)
final class StateView: UIView {

	// MARK: - Subviews

	private let activityIndicator = UIActivityIndicatorView(style: .large)
	private let errorLabel = UILabel()
	private let retryButton = UIButton(configuration: {
		var config = if #available(iOS 26.0, *) {
			UIButton.Configuration.prominentGlass()
		} else {
			UIButton.Configuration.borderedProminent()
		}
		config.title = String(localized: "Retry")
		return config
	}())

	// MARK: - Public API

	var isLoading: Bool {
		get {
			activityIndicator.isAnimating
		}
		set {
			if (newValue) {
				activityIndicator.startAnimating()
				errorLabel.text = nil
				errorLabel.isHidden = true
				retryButton.isHidden = true
			} else {
				activityIndicator.stopAnimating()
			}
		}
	}

	var errorMessage: String? {
		get {
			errorLabel.text
		}
		set {
			errorLabel.text = newValue
			errorLabel.isHidden = newValue?.isEmpty ?? true
			retryButton.isHidden = newValue?.isEmpty ?? true
		}
	}

	var onRetry: UIAction? {
		didSet {
			if let onRetry {
				retryButton.addAction(onRetry, for: .primaryActionTriggered)
			} else if let oldValue {
				retryButton.removeAction(oldValue, for: .primaryActionTriggered)
			}
		}
	}

	// MARK: Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required init?(coder: NSCoder) { fatalError() }

	// MARK: Setup
	private func setup() {
		errorLabel.font = .app12
		errorLabel.numberOfLines = 0
		errorLabel.textAlignment = .center
		errorLabel.isHidden = true
		retryButton.isHidden = true

		let stack = UIStackView(arrangedSubviews: [activityIndicator, errorLabel, retryButton])
		stack.axis = .vertical
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
}

