// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LoomClone",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(
            name: "LoomClone",
            targets: ["LoomClone"]
        ),
        .library(
            name: "LoomCloneCore",
            targets: ["LoomCloneCore"]
        )
    ],
    targets: [
        .target(
            name: "LoomCloneCore",
            path: "Sources/LoomCloneCore"
        ),
        .executableTarget(
            name: "LoomClone",
            dependencies: ["LoomCloneCore"],
            path: "Sources/LoomClone",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "LoomCloneCoreTests",
            dependencies: ["LoomCloneCore"],
            path: "Tests/LoomCloneCoreTests"
        )
    ]
)
