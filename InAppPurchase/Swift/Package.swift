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
        .package(url: "https://github.com/migueldeicaza/SwiftGodot", branch: "7e4c34ccbc149cd61de3c8fa76a09f84bf5583f5")
    ],
    targets: [
        .target(
            name: "InAppPurchase",
            dependencies: [
                "SwiftGodot",
            ],
            swiftSettings: [.unsafeFlags(["-suppress-warnings"])]
        ),
    ]
)
