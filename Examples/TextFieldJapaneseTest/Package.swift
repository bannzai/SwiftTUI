// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "TextFieldJapaneseTest",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(name: "SwiftTUI", path: "../..")
    ],
    targets: [
        .executableTarget(
            name: "TextFieldJapaneseTest",
            dependencies: ["SwiftTUI"]
        ),
    ]
)