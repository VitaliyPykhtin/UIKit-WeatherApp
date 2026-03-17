// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "WeatherLib",
	platforms: [.iOS(.v15)],
	products: [
		.library(
			name: "WeatherLib",
			targets: ["Model", "ServiceImplementations"],
		),
		.library(
			name: "MockServiceImplementations",
			targets: ["MockServiceImplementations"],
		),
	],
	targets: [
		.target(
			name: "Model",
			dependencies: ["Toolbox"],
			swiftSettings: [.defaultIsolation(MainActor.self)]
		),
		.target(
			name: "ServiceImplementations",
			dependencies: ["Model", "Toolbox"],
		),
		.target(
			name: "Toolbox",
		),
		.target(
			name: "MockServiceImplementations",
			dependencies: ["Model", "Toolbox"],
		),
		.testTarget(
			name: "WeatherLibTests",
			dependencies: ["MockServiceImplementations", "Model"],
		),
	],
)

for target in package.targets {
	var settings = target.swiftSettings ?? []
	settings += [
		// 6.2 Approachable concurrency
		.enableUpcomingFeature("NonisolatedNonsendingByDefault"),
		.enableUpcomingFeature("InferIsolatedConformances"),
	]
	target.swiftSettings = settings
}
