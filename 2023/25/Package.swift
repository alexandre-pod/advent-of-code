// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Main",
    platforms: [
        .macOS("11.0.0")
    ],
    dependencies: [
//        .package(url: "https://github.com/SwiftDocOrg/GraphViz", from: "0.4.1"),
    ],
    targets: [
        .target(
            name: "Main",
            dependencies: [])
    ]
)
