//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Vitaliy Pykhtin on 12.03.2026.
//

import Data
import Domain
import Presentation
import UIKit

final class WeatherViewController: UIViewController {
	private let model = Model(services: Services())

	// Loading / error
	private let stateView = StateView()

	// Current weather section
	private let currentWeatherView = CurrentWeatherView()

	// Hourly forecast (collection view)
	@ViewLoading private var collectionView: UICollectionView
	@ViewLoading private var dataSource: UICollectionViewDiffableDataSource<Section, Item>

	// MARK: - Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

		setupPresentation()

		let model = model
		stateView.onRetry = UIAction { _ in model.fetchWeather() }
		// Diffable data sources
		setupDataSource()

		model.startLocationUpdates()
	}

	override func updateProperties() {
		if #available(iOS 26, *) {
			super.updateProperties()
		}

		stateView.isLoading = model.isLoading
		switch model.weather {
		case let .success(weather):
			collectionView.isHidden = false
			// Current
			let image = model.loadImage(from: weather.current.iconURL) { [weak self] currentImage in
				if case let .success(currentWeather) = self?.model.weather {
					self?.currentWeatherView.configure(with: currentWeather.current, image: currentImage)
				}
			}
			currentWeatherView.configure(with: weather.current, image: image)
			// Hourly
			var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
			snapshot.appendSections(Section.allCases)
			snapshot.appendItems(weather.hourly.map(Item.hourly), toSection: .hourly)
			snapshot.appendItems(weather.forecast.map(Item.daily), toSection: .daily)
			dataSource.apply(snapshot, animatingDifferences: true)
		case let .failure(error):
			stateView.errorMessage = error.localizedDescription
		case .none:
			break
		}
	}

	override func viewWillLayoutSubviews() {
		if #unavailable(iOS 26) {
			updateProperties()
		}
		super.viewWillLayoutSubviews()
	}
}

private extension WeatherViewController {

	// MARK: - Setup

	func setupPresentation() {
		view.backgroundColor = .appBackground

		collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: collectionLayout)
		collectionView.preservesSuperviewLayoutMargins = true
		collectionView.isHidden = true

		let contentStack = UIStackView(arrangedSubviews: [
			stateView,
			collectionView,
		])
		contentStack.frame = view.bounds
		contentStack.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		contentStack.preservesSuperviewLayoutMargins = true
		contentStack.axis = .vertical
		contentStack.spacing = 16
		view.addSubview(contentStack)
	}

	// MARK: Layout

	var collectionLayout: UICollectionViewLayout {
		let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
													 heightDimension: .estimated(207))

		let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
																 elementKind: Section.collectionHeader,
																		 alignment: .top)

		let config = UICollectionViewCompositionalLayoutConfiguration()
		config.boundarySupplementaryItems = [header]
		config.contentInsetsReference = .layoutMargins

		let interSpacing = CGFloat(8)

		return UICollectionViewCompositionalLayout(sectionProvider: { sectionIndex, layoutEnvironment in
			guard let sectionKind = Section(rawValue: sectionIndex) else { return nil }

			let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
														 heightDimension: .estimated(21))

			let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionHeaderSize,
																			elementKind: Section.header,
																			 alignment: .top)

			switch sectionKind {
			case .hourly:
				let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25),
													  heightDimension: .fractionalHeight(1))
				let item = NSCollectionLayoutItem(layoutSize: itemSize)

				let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
													   heightDimension: .estimated(120))
				let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
				group.interItemSpacing = .fixed(interSpacing)

				let section = NSCollectionLayoutSection(group: group)
				section.boundarySupplementaryItems = [sectionHeader]
				section.contentInsets = NSDirectionalEdgeInsets(top: interSpacing, leading: 0, bottom: interSpacing, trailing: 0)
				section.orthogonalScrollingBehavior = .continuous
				section.interGroupSpacing = interSpacing

				return section
			case .daily:
				let itemsCount = 3

				let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0/Double(itemsCount)),
													  heightDimension: .fractionalHeight(1))
				let item = NSCollectionLayoutItem(layoutSize: itemSize)


				let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
													   heightDimension: .estimated(200))
				let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: itemsCount)
				group.interItemSpacing = .fixed(interSpacing)

				let section = NSCollectionLayoutSection(group: group)
				section.boundarySupplementaryItems = [sectionHeader]
				section.contentInsets = NSDirectionalEdgeInsets(top: interSpacing, leading: 0, bottom: interSpacing, trailing: 0)

				return section
			}
		}, configuration: config)
	}

	// MARK: - Data Sources

	nonisolated enum Section: Int, CaseIterable {
		static let collectionHeader = "header-element-kind"
		static let header = "section-header-element-kind"

		case hourly, daily
	}

	nonisolated enum Item: Hashable {
		case hourly(HourWeather)
		case daily(DayWeather)
	}

	func setupDataSource() {
		let headerRegistration = UICollectionView.SupplementaryRegistration<CurrentWeatherReusableView>(elementKind: Section.collectionHeader) { [weak self] (supplementaryView, string, indexPath) in

			supplementaryView.view = self?.currentWeatherView
		}
		let sectionHeaderRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(elementKind: Section.header) {
			(supplementaryView, string, indexPath) in

			guard let sectionKind = Section(rawValue: indexPath.section) else { return }

			supplementaryView.label.text =
				switch sectionKind {
				case .hourly: String(localized: "Hourly forecast")
				case .daily: String(localized: "3-day forecast")
				}
		}
		let hourlyCellRegistration = UICollectionView.CellRegistration<HourCell, HourWeather> { [weak self] cell, indexPath, model in
			guard let self else { return }

			let image = self.model.loadImage(from: model.iconURL) {_ in
				self.reconfigure(.hourly(model))
			}

			cell.configure(with: model, image: image)
		}
		let dailyCellRegistration = UICollectionView.CellRegistration<DayCell, DayWeather> { [weak self] cell, indexPath, model in
			guard let self else { return }

			let image = self.model.loadImage(from: model.iconURL) {_ in
				self.reconfigure(.daily(model))
			}
			cell.configure(with: model, image: image)
		}
		dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { (collectionView, indexPath, modelId) in
			switch modelId {
			case .hourly(let model):
				collectionView.dequeueConfiguredReusableCell(using: hourlyCellRegistration, for: indexPath, item: model)
			case .daily(let model):
				collectionView.dequeueConfiguredReusableCell(using: dailyCellRegistration, for: indexPath, item: model)
			}
		}
		dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
			switch kind {
			case Section.header:
				collectionView.dequeueConfiguredReusableSupplementary(using: sectionHeaderRegistration, for: indexPath)
			default:
				collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
			}
		}
	}

	func reconfigure(_ id: Item) {
		var snapshot = dataSource.snapshot()
		snapshot.reconfigureItems([id])
		dataSource.apply(snapshot, animatingDifferences: true)
	}
}
