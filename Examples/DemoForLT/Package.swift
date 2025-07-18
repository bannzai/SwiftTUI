// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "DemoForLT",
  platforms: [.macOS(.v14)],
  dependencies: [
    .package(path: "../..")
  ],
  targets: [
    .executableTarget(
      name: "DemoForLT",
      dependencies: ["SwiftTUI"]
    )
  ]
)
