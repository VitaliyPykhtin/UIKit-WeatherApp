//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Vitaliy Pykhtin on 12.03.2026.
//

import UIKit
import CoreLocation

final class WeatherViewController: UIViewController {

	// MARK: - UI

	// Loading / error
	private let stateView = StateView()
	
	// Current weather section
	private let currentWeatherView = CurrentWeatherView()

	// Hourly forecast (collection view)
	private var hourlyCollectionView: UICollectionView!
	private var hourlyDataSource: UICollectionViewDiffableDataSource<Section, HourCellModel>!

	// 3‑day forecast (collection view)
	private var dailyCollectionView: UICollectionView!
	private var dailyDataSource: UICollectionViewDiffableDataSource<Section, DayCellModel>!

	// MARK: - Data

	private var currentLocation: CLLocation?
	private var lastFetchedLocation: CLLocation?
	private var locationTask: Task<Void, Never>?

	// MARK: - View Life Cycle

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		setupUI()
		
		startLocationUpdates()
	}

	// MARK: - UI Setup

	private func setupUI() {
		// Scroll view + stack
		let scrollView = UIScrollView()
		scrollView.preservesSuperviewLayoutMargins = true
		view.addSubview(scrollView)
		
		let contentStack = UIStackView()
		contentStack.axis = .vertical
		contentStack.spacing = 16
		scrollView.addSubview(contentStack)
		
		stateView.onRetry = { [weak self] in self?.fetchWeather() }
		contentStack.addArrangedSubview(stateView)
		
		contentStack.addArrangedSubview(currentWeatherView)
		
		// Hourly forecast
		let hourlyHeader = UILabel()
		hourlyHeader.text = "Почасовой прогноз"
		hourlyHeader.font = .systemFont(ofSize: 18, weight: .medium)
		contentStack.addArrangedSubview(hourlyHeader)
		
		let hourlyLayout = UICollectionViewFlowLayout()
		hourlyLayout.scrollDirection = .horizontal
		hourlyLayout.itemSize = CGSize(width: 80, height: 120)
		hourlyLayout.minimumLineSpacing = 8
		hourlyCollectionView = UICollectionView(frame: .zero, collectionViewLayout: hourlyLayout)
		hourlyCollectionView.showsHorizontalScrollIndicator = false
		hourlyCollectionView.backgroundColor = .clear
		contentStack.addArrangedSubview(hourlyCollectionView)
		
		// 3‑day forecast
		let dailyHeader = UILabel()
		dailyHeader.text = "Прогноз на 3 дня"
		dailyHeader.font = .systemFont(ofSize: 18, weight: .medium)
		contentStack.addArrangedSubview(dailyHeader)
		
		let dailyLayout = UICollectionViewFlowLayout()
		dailyLayout.scrollDirection = .horizontal
		dailyLayout.itemSize = CGSize(width: 120, height: 200)
		dailyLayout.minimumLineSpacing = 12
		dailyCollectionView = UICollectionView(frame: .zero, collectionViewLayout: dailyLayout)
		dailyCollectionView.showsHorizontalScrollIndicator = false
		dailyCollectionView.backgroundColor = .clear
		contentStack.addArrangedSubview(dailyCollectionView)
		
		// Diffable data sources
		configureHourlyDataSource()
		configureDailyDataSource()
		
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		contentStack.translatesAutoresizingMaskIntoConstraints = false
		hourlyCollectionView.translatesAutoresizingMaskIntoConstraints = false
		dailyCollectionView.translatesAutoresizingMaskIntoConstraints = false
		
		let bindings: [String : UIView] = ["scrollView" : scrollView,
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
		]
		constraints += [
			hourlyCollectionView.heightAnchor.constraint(equalToConstant: 120),
			dailyCollectionView.heightAnchor.constraint(equalToConstant: 200),
		]
		NSLayoutConstraint.activate(constraints)
	}

	// MARK: - Location

	private func startLocationUpdates() {
		locationTask?.cancel()
		
		locationTask = Task {
			do {
				for try await update in CLLocationUpdate.liveUpdates() {
					print("Location updates: \(String(describing: update.location))")
					print("authorizationRequestInProgress: \(update.authorizationRequestInProgress)")
					print("accuracyLimited: \(update.accuracyLimited)")
					print("authorizationDenied: \(update.authorizationDenied)")
					print("authorizationDeniedGlobally: \(update.authorizationDeniedGlobally)")
					print("authorizationRestricted: \(update.authorizationRestricted)")
					print("insufficientlyInUse: \(update.insufficientlyInUse)")
					print("locationUnavailable: \(update.locationUnavailable)")
					print("serviceSessionRequired: \(update.serviceSessionRequired)")
					print("stationary: \(update.stationary)")
					
					if let location = update.location {
						
						guard lastFetchedLocation == nil || lastFetchedLocation!.distance(from: location) > 15_000 else {
							continue
						}
						
						currentLocation = location
						fetchWeather()
					} else if
						update.authorizationRequestInProgress == false &&
							update.authorizationDenied == true ||
							update.authorizationDeniedGlobally == true ||
							update.authorizationRestricted == true ||
							update.locationUnavailable == true ||
							update.serviceSessionRequired == true {
						useDefaultLocation()
					}
				}
			} catch {
				print("CLLocationUpdate error: $error)")
				useDefaultLocation()
			}
		}
	}

	private func useDefaultLocation() {
		if currentLocation == nil {
			// Москва
			currentLocation = CLLocation(latitude: 55.7558, longitude: 37.6173)
		}
		fetchWeather()
	}

	deinit {
		locationTask?.cancel()
	}

	// MARK: Networking

	private func fetchWeather() {
		guard let coord = currentLocation?.coordinate, stateView.isLoading == false else { return }
		
		stateView.isLoading = true
		
		Task {
			do {
				let current = try await WebService.shared.fetchCurrentWeather(
					latitude: coord.latitude,
					longitude: coord.longitude)

				let forecast = try await WebService.shared.fetchForecast(
					latitude: coord.latitude,
					longitude: coord.longitude)

				await MainActor.run {
					lastFetchedLocation = currentLocation
					stateView.isLoading = false
					updateUI(current: current, forecast: forecast)
				}
			} catch {
				await MainActor.run {
					stateView.errorMessage = error.localizedDescription
				}
			}
		}
	}

	// MARK: - UI Update

	private var hourlyModels: [HourCellModel] = []
	private var dailyModels: [DayCellModel] = []

	private func updateUI(current: DTOCurrentWeatherResponse, forecast: DTOForecastResponse) {
		// Current
		currentWeatherView.configure(with: current)

		// Hourly
		hourlyModels = []
		let today = forecast.forecast.forecastday.first!
		let nowHourIndex = Calendar.current.component(.hour, from: Date())
		// Оставшиеся часы текущего дня
		hourlyModels.append(contentsOf: today.hour.dropFirst(nowHourIndex).map(HourCellModel.init))
		
		// Все часы следующего дня
		if forecast.forecast.forecastday.count > 1 {
			hourlyModels.append(contentsOf: forecast.forecast.forecastday[1].hour.map(HourCellModel.init))
		}
		var snapshot = NSDiffableDataSourceSnapshot<Section, HourCellModel>()
		snapshot.appendSections([Section.main])
		snapshot.appendItems(hourlyModels)
		hourlyDataSource.apply(snapshot, animatingDifferences: true)

		// 3‑дневный прогноз
		dailyModels = forecast.forecast.forecastday.map(DayCellModel.init)
		var daySnapshot = NSDiffableDataSourceSnapshot<Section, DayCellModel>()
		daySnapshot.appendSections([Section.main])
		daySnapshot.appendItems(dailyModels)
		dailyDataSource.apply(daySnapshot, animatingDifferences: true)
	}
}

// MARK: - Data Sources

extension WeatherViewController {
	nonisolated
	private enum Section { case main }

	private func configureHourlyDataSource() {
		let cellRegistration = UICollectionView.CellRegistration<HourCell, HourCellModel> { [weak self] cell, indexPath, model in
			guard let self else { return }
			
			let image = DownloadService.shared.loadImage(from: model.iconURL) {_ in
				self.setHourlyNeedsUpdate(model)
			}
			
			cell.configure(with: model, image: image)
		}
		hourlyDataSource = UICollectionViewDiffableDataSource<Section, HourCellModel>(collectionView: hourlyCollectionView) { (collectionView, indexPath, model) in
			collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: model)
		}
	}

	private func configureDailyDataSource() {
		let cellRegistration = UICollectionView.CellRegistration<DayCell, DayCellModel> { [weak self] cell, indexPath, model in
			guard let self else { return }
			
			let image = DownloadService.shared.loadImage(from: model.iconURL) {_ in
				self.setDailyNeedsUpdate(model)
			}
			cell.configure(with: model, image: image)
		}
		dailyDataSource = UICollectionViewDiffableDataSource<Section, DayCellModel>(collectionView: dailyCollectionView) { (collectionView, indexPath, model) in
			collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: model)
		}
	}
	
	private func setHourlyNeedsUpdate(_ id: HourCellModel) {
		var snapshot = hourlyDataSource.snapshot()
		snapshot.reconfigureItems([id])
		hourlyDataSource.apply(snapshot, animatingDifferences: true)
	}
	
	private func setDailyNeedsUpdate(_ id: DayCellModel) {
		var snapshot = dailyDataSource.snapshot()
		snapshot.reconfigureItems([id])
		dailyDataSource.apply(snapshot, animatingDifferences: true)
	}
}
