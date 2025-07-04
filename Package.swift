// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftTUI",
  platforms: [
    .macOS(.v14),
  ],
  products: [
    .library(name: "SwiftTUI", targets: ["SwiftTUI"]),
    .executable(name: "ExampleApp", targets: ["ExampleApp"]),
    .executable(name: "SwiftUILikeExample", targets: ["SwiftUILikeExample"]),
  ],
  dependencies: [
    .package(url: "https://github.com/facebook/yoga.git", .upToNextMinor(from: "3.2.1"))
  ],
  targets: [
    // Swift ランタイム
    .target(
      name: "SwiftTUI",
      dependencies: [
        .product(name: "yoga", package: "yoga")
      ],
      path: "Sources/SwiftTUI"
    ),
    .executableTarget(
      name: "ExampleApp",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "SwiftUILikeExample",
      dependencies: ["SwiftTUI"]
    )
  ]
)
