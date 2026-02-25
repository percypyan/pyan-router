// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PyanRouter",
	platforms: [
		.iOS(.v17),
		.macOS(.v14),
		.tvOS(.v17),
		.watchOS(.v10),
		.visionOS(.v1)
	],
    products: [
        .library(
            name: "PyanRouter",
            targets: ["PyanRouter"]
        ),
		.library(
			name: "PyanRouterSample",
			targets: ["PyanRouterSample"]
		),
    ],
    targets: [
        .target(
            name: "PyanRouter"
        ),
		.target(
			name: "PyanRouterSample",
			dependencies: ["PyanRouter"]
		),
        .testTarget(
            name: "PyanRouterTests",
            dependencies: ["PyanRouter"]
        ),
    ]
)
