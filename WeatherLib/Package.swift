// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

// TODO: lower version to 5.9 (package visibility)
import PackageDescription

let package = Package(
    name: "WeatherLib",
	platforms: [.iOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "WeatherLib",
			targets: ["Model", "ServiceImplementations"],
        ),
		.library(
			name: "MockServiceImplementations",
			targets: ["MockServiceImplementations"],
		)
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
		.target(
			name: "Model",
			dependencies: ["Toolbox"],
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
    ]
)
