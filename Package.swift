// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VisilabsIOS",
    platforms: [.iOS(.v10)],
    products: [
        .library(
            name: "VisilabsIOS",
            targets: ["VisilabsIOS"])
    ],
    targets: [
        .target(
            name: "VisilabsIOS",
            path: "Sources",
	   resources: [.process("Assets")])
    ]
)
