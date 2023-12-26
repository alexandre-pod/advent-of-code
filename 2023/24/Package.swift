// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Main",
    platforms: [
        .macOS("11.0.0")
    ],
    dependencies: [
        .package(url: "https://github.com/alexandertar/LASwift", from: "0.3.2")
    ],
    targets: [
        .target(
            name: "Main",
            dependencies: [
                .product(name: "LASwift", package: "LASwift")
            ]
//            swiftSettings: [
//                SwiftSetting.define("ACCELERATE_NEW_LAPACK"),
//                SwiftSetting.define("ACCELERATE_LAPACK_ILP64")
//
//            ]
        )
    ]
)
