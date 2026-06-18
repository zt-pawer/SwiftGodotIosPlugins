// swift-tools-version: 5.9.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InAppPurchase",
    platforms: [.iOS(.v17),(.macOS(.v14))],
    products: [
        .library(
            name: "InAppPurchase",
            type: .dynamic,
            targets: ["InAppPurchase"]),
    ],
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftGodot", revision: "f528ba67accbe3cca06c1d401c8f9d7c17022f63")
    ],
    targets: [
        .target(
            name: "InAppPurchase",
            dependencies: [
                "SwiftGodot",
            ],
            swiftSettings: [.unsafeFlags(["-suppress-warnings"])]
        ),
        .testTarget(
            name: "InAppPurchaseTests",
            dependencies: ["InAppPurchase"]
        ),
    ]
)
