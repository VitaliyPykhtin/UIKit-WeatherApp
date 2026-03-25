//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Vitaliy Pykhtin on 12.03.2026.
//

import UIKit
import Model
import ServiceImplementations

final class WeatherViewController: UIViewController {
	private let model = Model(services: Services())
	private var observer: AnyObject!

	// MARK: - UI

	// Loading / error
	private let stateView = StateView()

	// Current weather section
	private let currentWeatherView = CurrentWeatherView()

	// Hourly forecast (collection view)
	private var hourlyCollectionView: UICollectionView!
	private var hourlyDataSource: UICollectionViewDiffableDataSource<Section, HourWeather>!

	// 3‑day forecast (collection view)
	private var dailyCollectionView: UICollectionView!
	private var dailyDataSource: UICollectionViewDiffableDataSource<Section, DayWeather>!

	// MARK: - View Life Cycle

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .appBackgroud
		setupUI()
		NotificationCenter.default.addObserver(self, selector: #selector(updateLoadingUI), name: .weatherFetching, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .weatherChanged, object: nil)

		model.startLocationUpdates()
	}

	// MARK: - UI Setup

	private func setupUI() {
		let model = model
		stateView.onRetry = UIAction { _ in model.fetchWeather() }

		// Hourly forecast
		let hourlyHeader = UILabel()
		hourlyHeader.text = NSLocalizedString("Hourly forecast", comment: "Hourly forecast header")
		hourlyHeader.font = .app17Semibold

		let hourlyLayout = UICollectionViewFlowLayout()
		hourlyLayout.scrollDirection = .horizontal
		hourlyLayout.itemSize = CGSize(width: 80, height: 120)
		hourlyLayout.minimumLineSpacing = 8
		hourlyCollectionView = UICollectionView(frame: .zero, collectionViewLayout: hourlyLayout)
		hourlyCollectionView.showsHorizontalScrollIndicator = false
		hourlyCollectionView.backgroundColor = .clear

		// 3‑day forecast
		let dailyHeader = UILabel()
		dailyHeader.text = NSLocalizedString("3-day forecast", comment: "3-day forecast header")
		dailyHeader.font = .app17Semibold

		let dailyLayout = UICollectionViewFlowLayout()
		dailyLayout.scrollDirection = .horizontal
		dailyLayout.itemSize = CGSize(width: 120, height: 200)
		dailyLayout.minimumLineSpacing = 12
		dailyCollectionView = UICollectionView(frame: .zero, collectionViewLayout: dailyLayout)
		dailyCollectionView.showsHorizontalScrollIndicator = false
		dailyCollectionView.backgroundColor = .clear

		// Scroll view + stack
		let scrollView = UIScrollView()
		scrollView.preservesSuperviewLayoutMargins = true
		view.addSubview(scrollView)

		let contentStack = UIStackView(arrangedSubviews: [
			stateView,
			currentWeatherView,
			hourlyHeader,
			hourlyCollectionView,
			dailyHeader,
			dailyCollectionView,
		])
		contentStack.axis = .vertical
		contentStack.spacing = 16
		scrollView.addSubview(contentStack)

		// Diffable data sources
		configureHourlyDataSource()
		configureDailyDataSource()

		scrollView.translatesAutoresizingMaskIntoConstraints = false
		contentStack.translatesAutoresizingMaskIntoConstraints = false
		hourlyCollectionView.translatesAutoresizingMaskIntoConstraints = false
		dailyCollectionView.translatesAutoresizingMaskIntoConstraints = false

		let bindings: [String : UIView] = [
			"scrollView" : scrollView,
			"contentStack" : contentStack,
		]
		var constraints = [NSLayoutConstraint]()
		constraints += [scrollView.topAnchor.constraint(equalTo: view.readableContentGuide.topAnchor)]
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[scrollView]|",
													  metrics: nil, views: bindings)
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|",
													  metrics: nil, views: bindings)
		constraints += [
			contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
			contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
			contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
			contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32),
			hourlyCollectionView.heightAnchor.constraint(equalToConstant: 120),
			dailyCollectionView.heightAnchor.constraint(equalToConstant: 200),
		]
		NSLayoutConstraint.activate(constraints)
	}

	// MARK: - UI Update

	@objc
	private func updateLoadingUI() {
		stateView.isLoading = model.isLoading
	}

	@objc
	private func updateUI() {
		switch model.weather {
		case let .success(weather):
			// Current
			let image = model.loadImage(from: weather.current.iconURL) { [weak self] currentImage in
				if case let .success(currentWeather) = self?.model.weather {
					self?.currentWeatherView.configure(with: currentWeather.current, image: currentImage)
				}
			}
			currentWeatherView.configure(with: weather.current, image: image)
			// Hourly
			var snapshot = NSDiffableDataSourceSnapshot<Section, HourWeather>()
			snapshot.appendSections([Section.main])
			snapshot.appendItems(weather.hourly)
			hourlyDataSource.apply(snapshot, animatingDifferences: true)
			// 3‑day forecast
			var daySnapshot = NSDiffableDataSourceSnapshot<Section, DayWeather>()
			daySnapshot.appendSections([Section.main])
			daySnapshot.appendItems(weather.forecast)
			dailyDataSource.apply(daySnapshot, animatingDifferences: true)
		case let .failure(error):
			stateView.errorMessage = error.localizedDescription
		case .none:
			break
		}
	}
}

// MARK: - Data Sources

extension WeatherViewController {
	nonisolated
	private enum Section { case main }

	private func configureHourlyDataSource() {
		let cellRegistration = UICollectionView.CellRegistration<HourCell, HourWeather> { [weak self] cell, indexPath, model in
			guard let self else { return }

			let image = self.model.loadImage(from: model.iconURL) {_ in
				self.setHourlyNeedsUpdate(model)
			}

			cell.configure(with: model, image: image)
		}
		hourlyDataSource = UICollectionViewDiffableDataSource<Section, HourWeather>(collectionView: hourlyCollectionView) { (collectionView, indexPath, model) in
			collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: model)
		}
	}

	private func configureDailyDataSource() {
		let cellRegistration = UICollectionView.CellRegistration<DayCell, DayWeather> { [weak self] cell, indexPath, model in
			guard let self else { return }

			let image = self.model.loadImage(from: model.iconURL) {_ in
				self.setDailyNeedsUpdate(model)
			}
			cell.configure(with: model, image: image)
		}
		dailyDataSource = UICollectionViewDiffableDataSource<Section, DayWeather>(collectionView: dailyCollectionView) { (collectionView, indexPath, model) in
			collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: model)
		}
	}

	private func setHourlyNeedsUpdate(_ id: HourWeather) {
		var snapshot = hourlyDataSource.snapshot()
		snapshot.reconfigureItems([id])
		hourlyDataSource.apply(snapshot, animatingDifferences: true)
	}

	private func setDailyNeedsUpdate(_ id: DayWeather) {
		var snapshot = dailyDataSource.snapshot()
		snapshot.reconfigureItems([id])
		dailyDataSource.apply(snapshot, animatingDifferences: true)
	}
}

