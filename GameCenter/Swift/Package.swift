// swift-tools-version: 5.9.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GameCenter",
    platforms: [.iOS(.v17),(.macOS(.v14))],
    products: [
        .library(
            name: "GameCenter",
            type: .dynamic,
            targets: ["GameCenter"]),
    ],
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftGodot", branch: "9c15f48d1529a0499208c1678b35f8993691c9f1")
    ],
    targets: [
        .target(
            name: "GameCenter",
            dependencies: [
                "SwiftGodot",
            ],
            swiftSettings: [.unsafeFlags(["-suppress-warnings"])]
        ),
    ]
)
