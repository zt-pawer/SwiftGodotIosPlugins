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
    name: "AdMob",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "AdMob",
            type: libraryType,
            targets: ["AdMob"]),
    ],
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftGodot", branch: "main"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: "11.0.0")
    ],
    targets: [
        .target(
            name: "AdMob",
            dependencies: [
                "SwiftGodot",
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
            ],
            swiftSettings: [.unsafeFlags(["-suppress-warnings"])]
        ),
        .testTarget(
            name: "AdMobTests",
            dependencies: ["AdMob"]
        ),
    ]
)
