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
  ],
  targets: [
    .target(
      name: "CYoga",
      path: "Sources/CYoga",
      publicHeadersPath: ".",
      cSettings: [.define("YG_ENABLE_EVENTS")]
    ),
    // Swift ランタイム
    .target(
      name: "SwiftTUI",
      dependencies: ["CYoga"]
    ),
    .executableTarget(
      name: "ExampleApp",
      dependencies: ["SwiftTUI"]
    )
  ]
)
