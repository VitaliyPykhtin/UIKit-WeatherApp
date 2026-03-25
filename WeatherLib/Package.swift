// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "WeatherLib",
	platforms: [.iOS(.v18)],
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
// https://www.swift.org/swift-evolution/#?upcoming=true
for target in package.targets {
	var settings = target.swiftSettings ?? []
	settings += [
		// xcrun swiftc -print-supported-features
		// 5.8 till 7
		.enableUpcomingFeature("ExistentialAny"),
		// 6.0 till 7
		.enableUpcomingFeature("InternalImportsByDefault"),
		// 6.1 till 7
		.enableUpcomingFeature("MemberImportVisibility"),
		// 6.2 Approachable concurrency till 7
		.enableUpcomingFeature("NonisolatedNonsendingByDefault"),
		.enableUpcomingFeature("InferIsolatedConformances"),
		// 6.3 till 7
		.enableUpcomingFeature("ImmutableWeakCaptures"),
	]
	target.swiftSettings = settings
}
