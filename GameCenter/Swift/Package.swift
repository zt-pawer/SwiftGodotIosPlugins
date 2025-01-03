// swift-tools-version: 5.9.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var libraryType: Product.Library.LibraryType
#if os(Windows)
libraryType = .static
#else
libraryType = .dynamic
#endif

let package = Package(
    name: "GameCenter",
    platforms: [.iOS(.v17),(.macOS(.v14))],
    products: [
        .library(
            name: "GameCenter",
            type: libraryType,
            targets: ["GameCenter"]),
    ],
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftGodot", branch: "727a0bbe44d9fa4b4f6d38e78ba12e5b395bba4e")
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
