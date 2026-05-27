// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LoomClone",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "LoomClone",
            targets: ["LoomClone"]
        )
    ],
    targets: [
        .executableTarget(
            name: "LoomClone",
            path: "Sources/LoomClone",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
