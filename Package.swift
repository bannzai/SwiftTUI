// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftTUI",
  products: [
    .library(name: "SwiftTUI", targets: ["SwiftTUI"]),
    .executable(name: "ExampleApp", targets: ["ExampleApp"]),
  ],
  targets: [
    .target(name: "SwiftTUI"),
    .executableTarget(
      name: "ExampleApp",
      dependencies: ["SwiftTUI"]
    )
  ]
)
