// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "DirectoryObserverKit",
    products: [
        .library(
            name: "DirectoryObserverKit",
            targets: ["DirectoryObserverKit"]),
        .executable(
            name: "directory-observer-kit",
            targets: ["DirectoryObserverKitCLI"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "DirectoryObserverKit",
            dependencies: []),
        .target(
            name: "DirectoryObserverKitCLI",
            dependencies: ["DirectoryObserverKit"]),
        .testTarget(
            name: "DirectoryObserverKitTests",
            dependencies: ["DirectoryObserverKit"]),
    ]
)
