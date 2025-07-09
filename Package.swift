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
    .executable(name: "SimpleInteractiveTest", targets: ["SimpleInteractiveTest"]),
    .executable(name: "InteractiveFormTest", targets: ["InteractiveFormTest"]),
    .executable(name: "SpacingTest", targets: ["SpacingTest"]),
    .executable(name: "DirectionalPaddingTest", targets: ["DirectionalPaddingTest"]),
    .executable(name: "ForEachTest", targets: ["ForEachTest"]),
    .executable(name: "ScrollViewTest", targets: ["ScrollViewTest"]),
    .executable(name: "ListTest", targets: ["ListTest"]),
    .executable(name: "DebugHStackTest", targets: ["DebugHStackTest"]),
    .executable(name: "ButtonFocusTest", targets: ["ButtonFocusTest"]),
    .executable(name: "ScrollableListTest", targets: ["ScrollableListTest"]),
    .executable(name: "SimpleScrollableListTest", targets: ["SimpleScrollableListTest"]),
    .executable(name: "ScrollDebugTest", targets: ["ScrollDebugTest"]),
    .executable(name: "ArrowKeyTest", targets: ["ArrowKeyTest"]),
    .executable(name: "SimpleScrollTest", targets: ["SimpleScrollTest"]),
    .executable(name: "ESCTest", targets: ["ESCTest"]),
    .executable(name: "ForEachDebugTest", targets: ["ForEachDebugTest"]),
    .executable(name: "ForEachCellTest", targets: ["ForEachCellTest"]),
    .executable(name: "SimpleForEachCellTest", targets: ["SimpleForEachCellTest"]),
    .executable(name: "QuickForEachTest", targets: ["QuickForEachTest"]),
    .executable(name: "ToggleTest", targets: ["ToggleTest"]),
    .executable(name: "PickerTest", targets: ["PickerTest"]),
    .executable(name: "ProgressViewTest", targets: ["ProgressViewTest"]),
    .executable(name: "SliderTest", targets: ["SliderTest"]),
    .executable(name: "AlertTest", targets: ["AlertTest"]),
    .executable(name: "MinimalButtonTest", targets: ["MinimalButtonTest"]),
    .executable(name: "SimpleButtonActionTest", targets: ["SimpleButtonActionTest"]),
    .executable(name: "ObservableModelTest", targets: ["ObservableModelTest"]),
    .executable(name: "SimpleButtonHStackTest", targets: ["SimpleButtonHStackTest"]),
    .executable(name: "DebugButtonTest", targets: ["DebugButtonTest"]),
    .executable(name: "MinimalHStackButtonTest", targets: ["MinimalHStackButtonTest"]),
    .executable(name: "SimpleObservableTest", targets: ["SimpleObservableTest"]),
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
    ),
    .executableTarget(
      name: "SimpleInteractiveTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "InteractiveFormTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "SpacingTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "DirectionalPaddingTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "MinimalListTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "SimpleForEachTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "KeyTestVerify",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "ForEachTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "ScrollViewTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "ListTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "DebugHStackTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "ButtonFocusTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "BorderHStackTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "SimpleBackgroundTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "DebugBackgroundTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "CellRenderTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "CellHStackTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "SimpleCellTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "SimpleCellDebugTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "CellHStackDebugTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "CellPositionDebugTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "RealCellDebugTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "CellIssueDebugTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "CellAdapterFixTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "CellTextDebugTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "TextCellRenderTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "HStackBackgroundDebugTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "SimpleHStackTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "QuickHStackTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "ManualCellTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "VerboseHStackTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "HStackColorDebugTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "QuickDebugTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "ScrollableListTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "SimpleScrollableListTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "ScrollDebugTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "ArrowKeyTest", 
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "SimpleScrollTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "ESCTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "ForEachDebugTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "ForEachCellTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "SimpleForEachCellTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "QuickForEachTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "ToggleTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "PickerTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "ProgressViewTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "SliderTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "AlertTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "MinimalButtonTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "SimpleButtonActionTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "ObservableModelTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "SimpleButtonHStackTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "DebugButtonTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "MinimalHStackButtonTest",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "DebugHStackButton",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "SingleButtonDebug",
      dependencies: ["SwiftTUI"]
    ),
    .executableTarget(
      name: "SimpleObservableTest",
      dependencies: ["SwiftTUI"]
    )
  ]
)
