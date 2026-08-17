//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Vitaliy Pykhtin on 12.03.2026.
//

import Domain
import Presentation
import UIKit

final class WeatherViewController: UICollectionViewController {
	private let model: Model

	private var appliedState: Weather?
	private var pendingState: Weather?
	private var isApplyingSnapshot = false

	// Current weather section
	private let currentWeatherView = CurrentWeatherView()

	@ViewLoading private var dataSource: UICollectionViewDiffableDataSource<Section, Item>

	// MARK: - Lifecycle

	init(model: Model) {
		self.model = model
		super.init(collectionViewLayout: WeatherViewController.collectionLayout)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		setupPresentation()
		// Diffable data sources
		setupDataSource()

		model.startLocationUpdates()
	}

	override func updateProperties() {
		if #available(iOS 26, *) {
			super.updateProperties()
		}

		switch model.weather {
		case let .success(weather):
			pendingState = weather

			applyPendingStateIfNeeded()
		default:
			break
		}
	}

	override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
		var config: UIContentUnavailableConfiguration?
		switch model.weather {
		case let .failure(error):
			let model = model
			
			var buttonConfig = if #available(iOS 26.0, *) {
				UIButton.Configuration.prominentGlass()
			} else {
				UIButton.Configuration.borderedProminent()
			}
			buttonConfig.title = String(localized: "Retry")

			config = .empty()
			config?.text = error.localizedDescription
			config?.button = buttonConfig
			config?.buttonProperties.primaryAction = UIAction { _ in model.fetchWeather() }
		default:
			config = model.isLoading ? .loading() : nil
		}
		contentUnavailableConfiguration = config
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

		collectionView.preservesSuperviewLayoutMargins = true
	}

	// MARK: Layout

	static var collectionLayout: UICollectionViewLayout {
		let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
													 heightDimension: .estimated(223))

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

	func applyPendingStateIfNeeded() {
		guard !isApplyingSnapshot, let state = pendingState else {
			return
		}

		guard state != appliedState else {
			pendingState = nil
			return
		}

		pendingState = nil
		isApplyingSnapshot = true

		let image = model.loadImage(from: state.current.iconURL) { [weak self] currentImage in
			if case let .success(currentWeather) = self?.model.weather {
				self?.currentWeatherView.configure(with: currentWeather.current, image: currentImage)
			}
		}
		currentWeatherView.configure(with: state.current, image: image)

		var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
		snapshot.appendSections(Section.allCases)
		snapshot.appendItems(state.hourly.map(Item.hourly), toSection: .hourly)
		snapshot.appendItems(state.forecast.map(Item.daily), toSection: .daily)
		dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
			guard let self else { return }

			self.appliedState = state
			self.isApplyingSnapshot = false

			// If state changed during animation, applying latest pending state.
			self.applyPendingStateIfNeeded()
		}
	}

	func reconfigure(_ id: Item) {
		var snapshot = dataSource.snapshot()
		snapshot.reconfigureItems([id])
		dataSource.apply(snapshot, animatingDifferences: true)
	}
}
