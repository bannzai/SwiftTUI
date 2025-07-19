// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "BorderDebug",
  platforms: [.macOS(.v14)],
  dependencies: [
    .package(path: "../../")
  ],
  targets: [
    .executableTarget(
      name: "BorderDebug",
      dependencies: ["SwiftTUI"]
    )
  ]
)
