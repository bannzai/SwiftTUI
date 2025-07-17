//
//  SliderTests.swift
//  SwiftTUITests
//
//  Tests for Slider component with value adjustment and binding functionality
//

import XCTest
import yoga

@testable import SwiftTUI

final class SliderTests: SwiftTUITestCase {

  // MARK: - Helper Methods

  /// Helper method to test slider output directly since TestRenderer doesn't work with Slider
  private func renderSlider<V: BinaryFloatingPoint>(_ slider: Slider<V>) -> String
  where V.Stride: BinaryFloatingPoint {
    let sliderLayoutView = slider._layoutView
    guard let cellLayoutView = sliderLayoutView as? CellLayoutView else {
      XCTFail("SliderLayoutView should implement CellLayoutView")
      return ""
    }

    // FocusManagerの状態をリセットしてクリーンな状態で開始
    FocusManager.shared.reset()

    var testBuffer = CellBuffer(width: 50, height: 20)
    cellLayoutView.paintCells(origin: (0, 0), into: &testBuffer)
    let testLines = testBuffer.toANSILines()
    let result = testLines.map { line in
      // Strip ANSI
      let pattern = "\u{1B}\\[[0-9;]*m"
      let regex = try! NSRegularExpression(pattern: pattern, options: [])
      let range = NSRange(location: 0, length: line.utf16.count)
      return regex.stringByReplacingMatches(in: line, options: [], range: range, withTemplate: "")
    }.joined(separator: "\n")

    // テスト後にFocusManagerをクリア
    FocusManager.shared.reset()

    return result
  }

  // MARK: - Basic Display Tests

  func testSliderBasicDisplay() {
    // Given - Slider with basic configuration
    let slider = Slider(value: .constant(0.5), in: 0...1, label: "Volume")

    // When
    let output = renderSlider(slider)

    // Then - Should show label, slider bar, and value
    XCTAssertTrue(output.contains("Volume"), "Should show label")
    XCTAssertTrue(output.contains("["), "Should show slider start bracket")
    XCTAssertTrue(output.contains("]"), "Should show slider end bracket")
    XCTAssertTrue(output.contains("0.50"), "Should show current value")
  }

  func testSliderValueRange() {
    // Given - Slider with different ranges
    let slider1 = Slider(value: .constant(5.0), in: 0...10, label: "Test")
    let slider2 = Slider(value: .constant(-5.0), in: -10...10, label: "Range")

    // When
    let output1 = renderSlider(slider1)
    let output2 = renderSlider(slider2)

    // Then
    XCTAssertTrue(output1.contains("5.00"), "Should show value 5.00")
    XCTAssertTrue(output2.contains("-5.00"), "Should show negative value")
    XCTAssertTrue(output1.contains("Test"), "Should show first label")
    XCTAssertTrue(output2.contains("Range"), "Should show second label")
  }

  func testSliderInitialValue() {
    // Given - Sliders with different initial values
    let sliderMin = Slider(value: .constant(0.0), in: 0...1, label: "Min")
    let sliderMid = Slider(value: .constant(0.5), in: 0...1, label: "Mid")
    let sliderMax = Slider(value: .constant(1.0), in: 0...1, label: "Max")

    // When
    let outputMin = renderSlider(sliderMin)
    let outputMid = renderSlider(sliderMid)
    let outputMax = renderSlider(sliderMax)

    // Then
    XCTAssertTrue(outputMin.contains("0.00"), "Should show minimum value")
    XCTAssertTrue(outputMid.contains("0.50"), "Should show middle value")
    XCTAssertTrue(outputMax.contains("1.00"), "Should show maximum value")
  }

  func testSliderNoLabel() {
    // Given - Slider without label
    let slider = Slider(value: .constant(0.7), in: 0...1)

    // When
    let output = renderSlider(slider)

    // Then - Should show slider and value without label
    XCTAssertTrue(output.contains("["), "Should show slider brackets")
    XCTAssertTrue(output.contains("0.70"), "Should show current value")
    XCTAssertFalse(output.contains(":"), "Should not contain colon from label")
  }

  func testSliderDifferentTypes() {
    // Given - Sliders with Double and Float types
    let doubleSlider = Slider(value: .constant(0.33), in: 0.0...1.0, label: "Double")
    let floatSlider = Slider(value: .constant(Float(0.66)), in: Float(0)...Float(1), label: "Float")

    // When
    let doubleOutput = renderSlider(doubleSlider)
    let floatOutput = renderSlider(floatSlider)

    // Then
    XCTAssertTrue(doubleOutput.contains("0.33"), "Should show double value")
    XCTAssertTrue(floatOutput.contains("0.66"), "Should show float value")
    XCTAssertTrue(doubleOutput.contains("Double"), "Should show double label")
    XCTAssertTrue(floatOutput.contains("Float"), "Should show float label")
  }

  // MARK: - Binding Value Management Tests

  func testSliderBinding() {
    // Given - Slider with binding to constant value
    let slider = Slider(value: .constant(0.3), in: 0...1, label: "Binding")

    // When
    let output = renderSlider(slider)

    // Then
    XCTAssertTrue(output.contains("0.30"), "Should show bound value")
    XCTAssertTrue(output.contains("Binding"), "Should show slider label")
    XCTAssertTrue(output.contains("["), "Should show slider structure")
  }

  func testSliderValueReflection() {
    // Given - Sliders with different bound values
    let slider1 = Slider(value: .constant(0.25), in: 0...1, label: "Quarter")
    let slider2 = Slider(value: .constant(0.75), in: 0...1, label: "ThreeQuarter")

    // When
    let output1 = renderSlider(slider1)
    let output2 = renderSlider(slider2)

    // Then
    XCTAssertTrue(output1.contains("0.25"), "Should show quarter value")
    XCTAssertTrue(output2.contains("0.75"), "Should show three-quarter value")
    XCTAssertTrue(output1.contains("Quarter"), "Should show first label")
    XCTAssertTrue(output2.contains("ThreeQuarter"), "Should show second label")
  }

  func testSliderMultipleBindings() {
    // Given - Multiple sliders with independent bindings
    let volumeSlider = Slider(value: .constant(0.8), in: 0...1, label: "Volume")
    let brightnessSlider = Slider(value: .constant(0.4), in: 0...1, label: "Brightness")

    // When
    let volumeOutput = renderSlider(volumeSlider)
    let brightnessOutput = renderSlider(brightnessSlider)

    // Then
    XCTAssertTrue(volumeOutput.contains("Volume"), "Should show volume label")
    XCTAssertTrue(brightnessOutput.contains("Brightness"), "Should show brightness label")
    XCTAssertTrue(volumeOutput.contains("0.80"), "Should show volume value")
    XCTAssertTrue(brightnessOutput.contains("0.40"), "Should show brightness value")
  }

  func testSliderBindingTypes() {
    // Given - Sliders with different binding types
    let doubleSlider = Slider(value: .constant(50.0), in: 0...100, label: "Double")
    let floatSlider = Slider(
      value: .constant(Float(25.5)), in: Float(0)...Float(50), label: "Float")

    // When
    let doubleOutput = renderSlider(doubleSlider)
    let floatOutput = renderSlider(floatSlider)

    // Then
    XCTAssertTrue(doubleOutput.contains("50.00"), "Should show double value")
    XCTAssertTrue(floatOutput.contains("25.50"), "Should show float value")
  }

  // MARK: - Range and Step Tests

  func testSliderCustomRange() {
    // Given - Sliders with custom ranges
    let temperatureSlider = Slider(value: .constant(20.0), in: -10...40, label: "Temperature")
    let percentSlider = Slider(value: .constant(85.0), in: 0...100, label: "Progress")

    // When
    let tempOutput = renderSlider(temperatureSlider)
    let progressOutput = renderSlider(percentSlider)

    // Then
    XCTAssertTrue(tempOutput.contains("20.00"), "Should show temperature value")
    XCTAssertTrue(progressOutput.contains("85.00"), "Should show progress value")
    XCTAssertTrue(tempOutput.contains("Temperature"), "Should show temperature label")
    XCTAssertTrue(progressOutput.contains("Progress"), "Should show progress label")
  }

  func testSliderWithStep() {
    // Given - Slider with step specification
    let slider = Slider(value: .constant(5.0), in: 0...10, step: 1.0, label: "Stepped")

    // When
    let output = renderSlider(slider)

    // Then
    XCTAssertTrue(output.contains("5.00"), "Should show current value")
    XCTAssertTrue(output.contains("Stepped"), "Should show label")
    XCTAssertTrue(output.contains("["), "Should show slider structure")
  }

  func testSliderBoundaryValues() {
    // Given - Sliders at boundary values
    let minSlider = Slider(value: .constant(0.0), in: 0...10, label: "Minimum")
    let maxSlider = Slider(value: .constant(10.0), in: 0...10, label: "Maximum")

    // When
    let minOutput = renderSlider(minSlider)
    let maxOutput = renderSlider(maxSlider)

    // Then
    XCTAssertTrue(minOutput.contains("0.00"), "Should show minimum value")
    XCTAssertTrue(maxOutput.contains("10.00"), "Should show maximum value")
    XCTAssertTrue(minOutput.contains("Minimum"), "Should show minimum label")
    XCTAssertTrue(maxOutput.contains("Maximum"), "Should show maximum label")
  }

  // MARK: - Focus Management Tests

  func testSliderFocusDisplay() {
    // Given - Slider that can be focused
    let slider = Slider(value: .constant(0.6), in: 0...1, label: "Focusable")

    // When
    let output = renderSlider(slider)

    // Then - Basic display (focus state not testable in static test)
    XCTAssertTrue(output.contains("Focusable"), "Should show label")
    XCTAssertTrue(output.contains("0.60"), "Should show value")
    XCTAssertTrue(output.contains("["), "Should show slider structure")
  }

  func testSliderFocusSize() {
    // Given - Slider size calculation
    let slider = Slider(value: .constant(0.5), in: 0...1, label: "Test")

    // When
    let output = renderSlider(slider)

    // Then - Test that slider renders correctly
    XCTAssertTrue(output.contains("Test"), "Should show slider label")
    XCTAssertFalse(output.isEmpty, "Should produce some output")
    XCTAssertTrue(output.contains("0.50"), "Should show value")
  }

  func testSliderMultipleFocus() {
    // Given - Multiple sliders (test that each renders independently)
    let slider1 = Slider(value: .constant(0.1), in: 0...1, label: "First")
    let slider2 = Slider(value: .constant(0.5), in: 0...1, label: "Second")
    let slider3 = Slider(value: .constant(0.9), in: 0...1, label: "Third")

    // When
    let output1 = renderSlider(slider1)
    let output2 = renderSlider(slider2)
    let output3 = renderSlider(slider3)

    // Then - All sliders should render correctly
    XCTAssertTrue(output1.contains("First"), "Should show First")
    XCTAssertTrue(output2.contains("Second"), "Should show Second")
    XCTAssertTrue(output3.contains("Third"), "Should show Third")
    XCTAssertTrue(output1.contains("0.10"), "Should show first value")
    XCTAssertTrue(output2.contains("0.50"), "Should show second value")
    XCTAssertTrue(output3.contains("0.90"), "Should show third value")
  }

  // MARK: - Edge Cases Tests

  func testSliderMinMaxValues() {
    // Given - Sliders at extreme values
    let verySmallSlider = Slider(value: .constant(0.001), in: 0...1, label: "Small")
    let veryLargeSlider = Slider(value: .constant(999.99), in: 0...1000, label: "Large")

    // When
    let smallOutput = renderSlider(verySmallSlider)
    let largeOutput = renderSlider(veryLargeSlider)

    // Then
    XCTAssertTrue(smallOutput.contains("0.00"), "Should show small value (rounded)")
    XCTAssertTrue(largeOutput.contains("999.99"), "Should show large value")
    XCTAssertTrue(smallOutput.contains("Small"), "Should show small label")
    XCTAssertTrue(largeOutput.contains("Large"), "Should show large label")
  }

  func testSliderZeroRange() {
    // Given - Slider with very small range (to avoid division by zero)
    let smallRangeSlider = Slider(value: .constant(5.0), in: 4.99...5.01, label: "Small")

    // When
    let output = renderSlider(smallRangeSlider)

    // Then - Should still show structure
    XCTAssertTrue(output.contains("Small"), "Should show label even with small range")
    XCTAssertTrue(output.contains("5.00"), "Should show the value")
    XCTAssertTrue(output.contains("["), "Should show slider structure")
  }

  func testSliderLongLabels() {
    // Given - Slider with long label
    let slider = Slider(value: .constant(0.5), in: 0...1, label: "This is a very long slider label")

    // When
    let output = renderSlider(slider)

    // Then - Check for parts that should be present (long text may be truncated in display)
    XCTAssertTrue(output.contains("very long slider label"), "Should show long label")
    XCTAssertTrue(output.contains("["), "Should show slider structure")
    XCTAssertTrue(output.contains("█"), "Should show slider bar")
    // Note: Value might be truncated due to display width constraints
  }

  func testSliderSpecialValues() {
    // Given - Sliders with special characters in labels
    let emojiSlider = Slider(value: .constant(0.5), in: 0...1, label: "🎵 Volume")
    let specialSlider = Slider(value: .constant(0.8), in: 0...1, label: "Value (%)")

    // When
    let emojiOutput = renderSlider(emojiSlider)
    let specialOutput = renderSlider(specialSlider)

    // Then
    XCTAssertTrue(emojiOutput.contains("🎵 Volume"), "Should show emoji in label")
    XCTAssertTrue(emojiOutput.contains("0.50"), "Should show emoji slider value")
    XCTAssertTrue(specialOutput.contains("Value (%)"), "Should show special characters in label")
    XCTAssertTrue(specialOutput.contains("0.80"), "Should show special slider value")
  }
}
