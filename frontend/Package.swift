// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "CreatorBridgeFrontend",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "CreatorBridgeFrontend",
            targets: ["CreatorBridgeFrontend"]
        )
    ],
    targets: [
        .target(
            name: "CreatorBridgeFrontend",
            path: ".",
            exclude: [
                "COMPONENT_GUIDE.md",
                "STRUCTURE.md"
            ]
        )
    ]
)
