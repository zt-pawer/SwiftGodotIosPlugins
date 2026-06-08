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
    name: "GodotFirebase",
    platforms: [.iOS(.v17), (.macOS(.v14))],
    products: [
        .library(
            name: "GodotFirebase",
            type: libraryType,
            targets: ["GodotFirebase"]),
    ],
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftGodot", revision: "b8809f5a0568339c76e5965224e72ef91045d739"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.25.0")
    ],
    targets: [
        .target(
            name: "GodotFirebase",
            dependencies: [
                "SwiftGodot",
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAppCheck", package: "firebase-ios-sdk"),
            ],
            swiftSettings: [.unsafeFlags(["-suppress-warnings"])]
        ),
    ]
)
