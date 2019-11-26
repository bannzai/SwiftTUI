// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftTUI",
    products: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .executable(name: "Demo", targets: ["Demo"]),
        .library(
          name: "SwiftTUI",
          targets: ["SwiftTUI"]),
    ],
    dependencies: [
			.package(url: "https://github.com/wickwirew/Runtime.git", from: Version(2, 1, 1)),
		],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Demo",
            dependencies: ["SwiftTUI"]),
        .target(
            name: "SwiftTUI",
            dependencies: ["Runtime"]),
        .testTarget(
            name: "SwiftTUITests",
            dependencies: ["SwiftTUI", "Runtime"]),
    ]
)
