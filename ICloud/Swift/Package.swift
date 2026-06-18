// swift-tools-version: 5.9.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ICloud",
    platforms: [.iOS(.v17),(.macOS(.v14))],
    products: [
        .library(
            name: "ICloud",
            type: .dynamic,
            targets: ["ICloud"]),
    ],
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftGodot", revision: "f528ba67accbe3cca06c1d401c8f9d7c17022f63")
    ],
    targets: [
        .target(
            name: "ICloud",
            dependencies: [
                "SwiftGodot",
            ],
            swiftSettings: [.unsafeFlags(["-suppress-warnings"])]
        ),
        .testTarget(
            name: "ICloudTests",
            dependencies: ["ICloud"]
        ),
    ]
)
