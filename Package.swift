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
    .executable(name: "DebugExample", targets: ["DebugExample"]),
    .executable(name: "TestExample", targets: ["TestExample"]),
    .executable(name: "SimpleTest", targets: ["SimpleTest"]),
    .executable(name: "SimpleVStackTest", targets: ["SimpleVStackTest"]),
    .executable(name: "HStackTest", targets: ["HStackTest"]),
    .executable(name: "NestedLayoutTest", targets: ["NestedLayoutTest"]),
    .executable(name: "SpacerTest", targets: ["SpacerTest"]),
    .executable(name: "ModifierTest", targets: ["ModifierTest"]),
    .executable(name: "SimplePaddingTest", targets: ["SimplePaddingTest"]),
    .executable(name: "StateTest", targets: ["StateTest"]),
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
    ),
    .executableTarget(
      name: "DebugExample",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "TestExample",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "SimpleTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "SimpleVStackTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "HStackTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "NestedLayoutTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "SpacerTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "ModifierTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "SimplePaddingTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "StateTest",
      dependencies: ["SwiftTUI"]
    )
  ]
)
