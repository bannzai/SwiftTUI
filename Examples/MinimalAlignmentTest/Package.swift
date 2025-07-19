// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MinimalAlignmentTest",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(name: "SwiftTUI", path: "../..")
    ],
    targets: [
        .executableTarget(
            name: "MinimalAlignmentTest",
            dependencies: ["SwiftTUI"]
        ),
    ]
)