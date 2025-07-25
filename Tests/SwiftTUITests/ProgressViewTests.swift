//
//  ProgressViewTests.swift
//  SwiftTUITests
//
//  Tests for ProgressView component with determinate and indeterminate progress display
//

import XCTest
import yoga

@testable import SwiftTUI

final class ProgressViewTests: SwiftTUITestCase {

  // MARK: - Helper Methods

  /// Helper method to test progress view output directly since TestRenderer might not work with animations
  private func renderProgressView(_ progressView: ProgressView) -> String {
    let progressLayoutView = progressView._layoutView
    guard let cellLayoutView = progressLayoutView as? CellLayoutView else {
      XCTFail("ProgressViewLayoutView should implement CellLayoutView")
      return ""
    }

    var testBuffer = CellBuffer(width: 50, height: 20)
    cellLayoutView.paintCells(origin: (0, 0), into: &testBuffer)
    let testLines = testBuffer.toANSILines()
    return testLines.map { line in
      // Strip ANSI
      let pattern = "\u{1B}\\[[0-9;]*m"
      let regex = try! NSRegularExpression(pattern: pattern, options: [])
      let range = NSRange(location: 0, length: line.utf16.count)
      return regex.stringByReplacingMatches(in: line, options: [], range: range, withTemplate: "")
    }.joined(separator: "\n")
  }

  // MARK: - Basic Display Tests

  func testProgressViewIndeterminateBasic() {
    // Given - Indeterminate progress without label
    let progressView = ProgressView()

    // When
    let output = renderProgressView(progressView)

    // Then - Should show spinner character
    let spinnerChars = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
    let containsSpinner = spinnerChars.contains { output.contains($0) }
    XCTAssertTrue(containsSpinner, "Should show one of the spinner characters")
    XCTAssertFalse(output.contains("["), "Should not show progress bar")
    XCTAssertFalse(output.contains("%"), "Should not show percentage")
  }

  func testProgressViewIndeterminateWithLabel() {
    // Given - Indeterminate progress with label
    let progressView = ProgressView("Loading...")

    // When
    let output = renderProgressView(progressView)

    // Then - Should show label and spinner
    XCTAssertTrue(output.contains("Loading..."), "Should show label")
    let spinnerChars = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
    let containsSpinner = spinnerChars.contains { output.contains($0) }
    XCTAssertTrue(containsSpinner, "Should show spinner character after label")
  }

  func testProgressViewDeterminateBasic() {
    // Given - Determinate progress without label (50%)
    let progressView = ProgressView(value: 0.5, total: 1.0)

    // When
    let output = renderProgressView(progressView)

    // Then - Should show progress bar and percentage
    XCTAssertTrue(output.contains("["), "Should show progress bar start")
    XCTAssertTrue(output.contains("]"), "Should show progress bar end")
    XCTAssertTrue(output.contains("█"), "Should show filled portion")
    XCTAssertTrue(output.contains("░"), "Should show empty portion")
    XCTAssertTrue(output.contains("50%"), "Should show 50% progress")
  }

  func testProgressViewDeterminateWithLabel() {
    // Given - Determinate progress with label
    let progressView = ProgressView(value: 0.75, total: 1.0, label: "Download")

    // When
    let output = renderProgressView(progressView)

    // Then - Should show label, progress bar, and percentage
    XCTAssertTrue(output.contains("Download"), "Should show label")
    XCTAssertTrue(output.contains("["), "Should show progress bar")
    XCTAssertTrue(output.contains("]"), "Should show progress bar")
    XCTAssertTrue(output.contains("75%"), "Should show 75% progress")
  }

  func testProgressViewSpinnerAnimation() {
    // Given - Indeterminate progress to check spinner chars
    let progressView = ProgressView("Spinning")

    // When
    let output = renderProgressView(progressView)

    // Then - Should contain one spinner character
    let spinnerChars = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
    var foundCount = 0
    for char in spinnerChars {
      if output.contains(char) {
        foundCount += 1
      }
    }
    XCTAssertEqual(foundCount, 1, "Should contain exactly one spinner character")
  }

  // MARK: - Progress Value Tests

  func testProgressViewValueRange() {
    // Given - Different progress values
    let progress0 = ProgressView(value: 0.0, label: "Start")
    let progress50 = ProgressView(value: 0.5, label: "Half")
    let progress100 = ProgressView(value: 1.0, label: "Done")

    // When
    let output0 = renderProgressView(progress0)
    let output50 = renderProgressView(progress50)
    let output100 = renderProgressView(progress100)

    // Then
    XCTAssertTrue(output0.contains("0%"), "Should show 0%")
    XCTAssertTrue(output50.contains("50%"), "Should show 50%")
    XCTAssertTrue(output100.contains("100%"), "Should show 100%")
  }

  func testProgressViewValueClamping() {
    // Given - Values outside 0-1 range
    let progressNegative = ProgressView(value: -0.5, label: "Negative")
    let progressOverflow = ProgressView(value: 1.5, label: "Overflow")

    // When
    let outputNegative = renderProgressView(progressNegative)
    let outputOverflow = renderProgressView(progressOverflow)

    // Then - Should clamp to 0% and 100%
    XCTAssertTrue(outputNegative.contains("0%"), "Should clamp negative to 0%")
    XCTAssertTrue(outputOverflow.contains("100%"), "Should clamp overflow to 100%")

    // Check bar rendering
    let negativeBar =
      outputNegative.components(separatedBy: "[").last?.components(separatedBy: "]").first ?? ""
    XCTAssertFalse(negativeBar.contains("█"), "Negative progress should have empty bar")

    let overflowBar =
      outputOverflow.components(separatedBy: "[").last?.components(separatedBy: "]").first ?? ""
    XCTAssertFalse(overflowBar.contains("░"), "Overflow progress should have full bar")
  }

  func testProgressViewCustomTotal() {
    // Given - Custom total values
    let progress1 = ProgressView(value: 50, total: 100, label: "Steps")
    let progress2 = ProgressView(value: 3, total: 10, label: "Items")

    // When
    let output1 = renderProgressView(progress1)
    let output2 = renderProgressView(progress2)

    // Then
    XCTAssertTrue(output1.contains("50%"), "Should calculate 50/100 = 50%")
    XCTAssertTrue(output2.contains("30%"), "Should calculate 3/10 = 30%")
  }

  func testProgressViewProgressCalculation() {
    // Given - Various progress calculations
    let progress1 = ProgressView(value: 1, total: 3)  // 33.33...%
    let progress2 = ProgressView(value: 2, total: 3)  // 66.66...%
    let progress3 = ProgressView(value: 1, total: 8)  // 12.5%

    // When
    let output1 = renderProgressView(progress1)
    let output2 = renderProgressView(progress2)
    let output3 = renderProgressView(progress3)

    // Then - Should round to nearest percent
    XCTAssertTrue(output1.contains("33%"), "Should show 33% for 1/3")
    XCTAssertTrue(output2.contains("67%"), "Should show 67% for 2/3")
    // 1/8 = 0.125 = 12.5%, which rounds to 12% with %.0f format
    XCTAssertTrue(
      output3.contains("12%") || output3.contains("13%"), "Should show 12% or 13% for 1/8")
  }

  // MARK: - Style and Layout Tests

  func testProgressViewBarRendering() {
    // Given - Progress at 25% (5 filled, 15 empty out of 20)
    let progressView = ProgressView(value: 0.25, label: "Quarter")

    // When
    let output = renderProgressView(progressView)

    // Then - Check bar composition
    if let barContent = output.components(separatedBy: "[").last?.components(separatedBy: "]").first
    {
      let filledCount = barContent.filter { $0 == "█" }.count
      let emptyCount = barContent.filter { $0 == "░" }.count
      XCTAssertEqual(filledCount, 5, "Should have 5 filled blocks for 25%")
      XCTAssertEqual(emptyCount, 15, "Should have 15 empty blocks for 25%")
      XCTAssertEqual(filledCount + emptyCount, 20, "Should have total 20 blocks")
    }
  }

  func testProgressViewWidthCalculation() {
    // Given - Different configurations
    let indeterminate = ProgressView()
    let indeterminateLabel = ProgressView("Test")
    let determinate = ProgressView(value: 0.5)
    let determinateLabel = ProgressView(value: 0.5, label: "Test")

    // When - Render and check output length
    let output1 = renderProgressView(indeterminate)
    let output2 = renderProgressView(indeterminateLabel)
    let output3 = renderProgressView(determinate)
    let output4 = renderProgressView(determinateLabel)

    // Then - Check content exists and is appropriately sized
    XCTAssertTrue(output1.count > 0, "Indeterminate should render something")
    XCTAssertTrue(output2.contains("Test "), "Should show label with space before spinner")
    XCTAssertTrue(output3.contains("[") && output3.contains("]"), "Should show progress bar")
    XCTAssertTrue(output4.contains("Test ["), "Should show label before progress bar")

    // Verify relative sizes
    XCTAssertGreaterThan(output2.count, output1.count, "Label version should be longer")
    XCTAssertGreaterThan(output4.count, output3.count, "Label version should be longer")
  }

  func testProgressViewLabelSpacing() {
    // Given - Progress with label
    let progressView = ProgressView(value: 0.5, label: "Progress")

    // When
    let output = renderProgressView(progressView)

    // Then - Check spacing
    XCTAssertTrue(output.contains("Progress ["), "Should have space between label and bar")
    XCTAssertTrue(output.contains("] 50%"), "Should have space between bar and percentage")
  }

  // MARK: - Edge Cases Tests

  func testProgressViewZeroProgress() {
    // Given - 0% progress
    let progressView = ProgressView(value: 0.0, label: "Empty")

    // When
    let output = renderProgressView(progressView)

    // Then
    XCTAssertTrue(output.contains("0%"), "Should show 0%")
    if let barContent = output.components(separatedBy: "[").last?.components(separatedBy: "]").first
    {
      XCTAssertFalse(barContent.contains("█"), "Should have no filled blocks")
      XCTAssertEqual(barContent.filter { $0 == "░" }.count, 20, "Should have all 20 empty blocks")
    }
  }

  func testProgressViewFullProgress() {
    // Given - 100% progress
    let progressView = ProgressView(value: 1.0, label: "Complete")

    // When
    let output = renderProgressView(progressView)

    // Then
    XCTAssertTrue(output.contains("100%"), "Should show 100%")
    if let barContent = output.components(separatedBy: "[").last?.components(separatedBy: "]").first
    {
      XCTAssertFalse(barContent.contains("░"), "Should have no empty blocks")
      XCTAssertEqual(barContent.filter { $0 == "█" }.count, 20, "Should have all 20 filled blocks")
    }
  }

  func testProgressViewSpecialCharacters() {
    // Given - Special characters in labels
    let progressEmoji = ProgressView(value: 0.8, label: "📦 Package")
    let progressSpecial = ProgressView("⚡️ Lightning <Fast>")

    // When
    let outputEmoji = renderProgressView(progressEmoji)
    let outputSpecial = renderProgressView(progressSpecial)

    // Then
    XCTAssertTrue(outputEmoji.contains("📦 Package"), "Should show emoji in label")
    XCTAssertTrue(outputEmoji.contains("80%"), "Should show percentage with emoji label")
    XCTAssertTrue(outputSpecial.contains("⚡️ Lightning <Fast>"), "Should show special characters")
    let spinnerChars = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
    let containsSpinner = spinnerChars.contains { outputSpecial.contains($0) }
    XCTAssertTrue(containsSpinner, "Should show spinner with special label")
  }
}
