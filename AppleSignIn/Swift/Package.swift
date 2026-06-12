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
    name: "AppleSignIn",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "AppleSignIn",
            type: libraryType,
            targets: ["AppleSignIn"]),
    ],
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftGodot", branch: "main")
    ],
    targets: [
        .target(
            name: "AppleSignIn",
            dependencies: [
                "SwiftGodot",
            ],
            swiftSettings: [.unsafeFlags(["-suppress-warnings"])]
        ),
        .testTarget(
            name: "AppleSignInTests",
            dependencies: ["AppleSignIn"]
        ),
    ]
)
