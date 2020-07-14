// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Unboxing",
    products: [
        .library(name: "Unboxing", targets: ["Unboxing"]),
    ],
    targets: [
        .target(name: "Unboxing", dependencies: []),
        .testTarget(name: "UnboxingTests", dependencies: ["Unboxing"]),
    ],
    swiftLanguageVersions: [.v5]
)
