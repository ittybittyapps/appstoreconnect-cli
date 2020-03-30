// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "appstoreconnect-cli",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        .package(
            url: "https://github.com/johnsundell/files.git",
            from: "4.0.0"
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "0.0.2"
        ),
        .package(
            url: "https://github.com/AvdLee/appstoreconnect-swift-sdk.git",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/jpsim/Yams.git",
            from: "2.0.0"
        ),
        .package(
            url: "https://github.com/scottrhoyt/SwiftyTextTable.git",
            from: "0.5.0"
        ),
        .package(
            url: "https://github.com/dehesa/CodableCSV.git",
            from: "0.5.1"
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "appstoreconnect-cli",
            dependencies: ["AppStoreConnectCLI"]),
        .target(
            name: "AppStoreConnectCLI",
            dependencies: [.product(name: "Files", package: "Files"),
                           .product(name: "AppStoreConnect-Swift-SDK", package: "AppStoreConnect-Swift-SDK"),
                           .product(name: "Yams", package: "Yams"),
                           .product(name: "ArgumentParser", package: "swift-argument-parser"),
                           .product(name: "SwiftyTextTable", package: "SwiftyTextTable"),
                           .product(name: "CodableCSV", package: "CodableCSV")]
        ),
        .testTarget(
            name: "appstoreconnect-cliTests",
            dependencies: ["appstoreconnect-cli"]),
    ]
)
