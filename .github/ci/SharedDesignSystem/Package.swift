// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "SharedDesignSystem",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "SharedDesignSystem",
            targets: ["SharedDesignSystem"]),
    ],
    targets: [
        .target(
            name: "SharedDesignSystem"),
    ]
)
