// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "appstoreconnect-cli",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "asc",
            targets: ["appstoreconnect-cli"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/johnsundell/files.git",
            from: "4.1.1"
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            exact: "1.1.3"
        ),
        .package(
            url: "https://github.com/AvdLee/appstoreconnect-swift-sdk.git",
            from: "1.7.0"
        ),
        .package(
            url: "https://github.com/jpsim/Yams.git",
            from: "5.0.1"
        ),
        .package(
            url: "https://github.com/scottrhoyt/SwiftyTextTable.git",
            from: "0.9.0"
        ),
        .package(
            url: "https://github.com/dehesa/CodableCSV.git",
            from: "0.5.5"
        ),
        .package(
            url: "https://github.com/MortenGregersen/Bagbutik.git",
            from: "2.0.0"
        ),
        .package(
            url: "https://github.com/JohnSundell/CollectionConcurrencyKit.git",
            from: "0.2.0"
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .executableTarget(name: "appstoreconnect-cli", dependencies: ["AppStoreConnectCLI"]),
        .target(name: "Model"),
        .target(
            name: "FileSystem",
            dependencies: [
                .product(name: "CodableCSV", package: "CodableCSV"),
                .product(name: "Yams", package: "Yams"),
                .product(name: "Files", package: "Files"),
            ]
        ),
        .target(
            name: "AppStoreConnectCLI",
            dependencies: [
                .target(name: "Model"),
                .target(name: "FileSystem"),
                .product(name: "AppStoreConnect-Swift-SDK", package: "AppStoreConnect-Swift-SDK"),
                .product(name: "Bagbutik", package: "Bagbutik"),
                .product(name: "Yams", package: "Yams"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftyTextTable", package: "SwiftyTextTable"),
                .product(name: "CodableCSV", package: "CodableCSV"),
                .product(name: "CollectionConcurrencyKit", package: "CollectionConcurrencyKit"),
            ]
        ),
        .testTarget(
            name: "appstoreconnect-cliTests",
            dependencies: ["appstoreconnect-cli"],
            resources: [
                .copy("Models/Fixtures.bundle")
            ]
        ),
    ]
)
