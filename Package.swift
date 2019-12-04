// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftTUI",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .executable(name: "Demo", targets: ["Demo"]),
        .library(
          name: "SwiftTUI",
          targets: ["SwiftTUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/wickwirew/Runtime.git", from: Version(2, 1, 1)),
    ],
    targets: [
        .systemLibrary(name: "cncurses", pkgConfig: "ncurses"),
        .target(
            name: "Demo",
            dependencies: ["SwiftTUI"]
        ),
        .target(
            name: "SwiftTUI",
            dependencies: ["Runtime", "cncurses"]
        ),
        .testTarget(
            name: "SwiftTUITests",
            dependencies: ["SwiftTUI", "Runtime"]),
    ]
)
