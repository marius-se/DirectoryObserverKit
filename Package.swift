// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "DirectoryObserverKit",
    products: [
        .library(
            name: "DirectoryObserverKit",
            targets: ["DirectoryObserverKit"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "DirectoryObserverKit",
            dependencies: []),
        .testTarget(
            name: "DirectoryObserverKitTests",
            dependencies: ["DirectoryObserverKit"])
    ]
)
