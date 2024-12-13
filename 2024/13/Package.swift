// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Main",
    platforms: [
        .macOS("13.0.0")
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Main",
            dependencies: [])
    ]
)
