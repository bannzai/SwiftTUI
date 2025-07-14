//
//  SliderTests.swift
//  SwiftTUITests
//
//  Tests for Slider component with value adjustment and binding functionality
//

import Testing
@testable import SwiftTUI
import yoga

@Suite struct SliderTests {
    
    // MARK: - Helper Methods
    
    /// Helper method to test slider output directly since TestRenderer doesn't work with Slider
    private func renderSlider<V: BinaryFloatingPoint>(_ slider: Slider<V>) -> String where V.Stride: BinaryFloatingPoint {
        let sliderLayoutView = slider._layoutView
        guard let cellLayoutView = sliderLayoutView as? CellLayoutView else {
            Issue.record("SliderLayoutView should implement CellLayoutView")
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
    
    @Test func sliderBasicDisplay() {
        // Given - Slider with basic configuration
        let slider = Slider(value: .constant(0.5), in: 0...1, label: "Volume")
        
        // When
        let output = renderSlider(slider)
        
        // Then - Should show label, slider bar, and value
        #expect(output.contains("Volume"), "Should show label")
        #expect(output.contains("["), "Should show slider start bracket")
        #expect(output.contains("]"), "Should show slider end bracket")
        #expect(output.contains("0.50"), "Should show current value")
    }
    
    @Test func sliderValueRange() {
        // Given - Slider with different ranges
        let slider1 = Slider(value: .constant(5.0), in: 0...10, label: "Test")
        let slider2 = Slider(value: .constant(-5.0), in: -10...10, label: "Range")
        
        // When
        let output1 = renderSlider(slider1)
        let output2 = renderSlider(slider2)
        
        // Then
        #expect(output1.contains("5.00"), "Should show value 5.00")
        #expect(output2.contains("-5.00"), "Should show negative value")
        #expect(output1.contains("Test"), "Should show first label")
        #expect(output2.contains("Range"), "Should show second label")
    }
    
    @Test func sliderInitialValue() {
        // Given - Sliders with different initial values
        let sliderMin = Slider(value: .constant(0.0), in: 0...1, label: "Min")
        let sliderMid = Slider(value: .constant(0.5), in: 0...1, label: "Mid")
        let sliderMax = Slider(value: .constant(1.0), in: 0...1, label: "Max")
        
        // When
        let outputMin = renderSlider(sliderMin)
        let outputMid = renderSlider(sliderMid)
        let outputMax = renderSlider(sliderMax)
        
        // Then
        #expect(outputMin.contains("0.00"), "Should show minimum value")
        #expect(outputMid.contains("0.50"), "Should show middle value")
        #expect(outputMax.contains("1.00"), "Should show maximum value")
    }
    
    @Test func sliderNoLabel() {
        // Given - Slider without label
        let slider = Slider(value: .constant(0.7), in: 0...1)
        
        // When
        let output = renderSlider(slider)
        
        // Then - Should show slider and value without label
        #expect(output.contains("["), "Should show slider brackets")
        #expect(output.contains("0.70"), "Should show current value")
        #expect(!output.contains(":"), "Should not contain colon from label")
    }
    
    @Test func sliderDifferentTypes() {
        // Given - Sliders with Double and Float types
        let doubleSlider = Slider(value: .constant(0.33), in: 0.0...1.0, label: "Double")
        let floatSlider = Slider(value: .constant(Float(0.66)), in: Float(0)...Float(1), label: "Float")
        
        // When
        let doubleOutput = renderSlider(doubleSlider)
        let floatOutput = renderSlider(floatSlider)
        
        // Then
        #expect(doubleOutput.contains("0.33"), "Should show double value")
        #expect(floatOutput.contains("0.66"), "Should show float value")
        #expect(doubleOutput.contains("Double"), "Should show double label")
        #expect(floatOutput.contains("Float"), "Should show float label")
    }
    
    // MARK: - Binding Value Management Tests
    
    @Test func sliderBinding() {
        // Given - Slider with binding to constant value
        let slider = Slider(value: .constant(0.3), in: 0...1, label: "Binding")
        
        // When
        let output = renderSlider(slider)
        
        // Then
        #expect(output.contains("0.30"), "Should show bound value")
        #expect(output.contains("Binding"), "Should show slider label")
        #expect(output.contains("["), "Should show slider structure")
    }
    
    @Test func sliderValueReflection() {
        // Given - Sliders with different bound values
        let slider1 = Slider(value: .constant(0.25), in: 0...1, label: "Quarter")
        let slider2 = Slider(value: .constant(0.75), in: 0...1, label: "ThreeQuarter")
        
        // When
        let output1 = renderSlider(slider1)
        let output2 = renderSlider(slider2)
        
        // Then
        #expect(output1.contains("0.25"), "Should show quarter value")
        #expect(output2.contains("0.75"), "Should show three-quarter value")
        #expect(output1.contains("Quarter"), "Should show first label")
        #expect(output2.contains("ThreeQuarter"), "Should show second label")
    }
    
    @Test func sliderMultipleBindings() {
        // Given - Multiple sliders with independent bindings
        let volumeSlider = Slider(value: .constant(0.8), in: 0...1, label: "Volume")
        let brightnessSlider = Slider(value: .constant(0.4), in: 0...1, label: "Brightness")
        
        // When
        let volumeOutput = renderSlider(volumeSlider)
        let brightnessOutput = renderSlider(brightnessSlider)
        
        // Then
        #expect(volumeOutput.contains("Volume"), "Should show volume label")
        #expect(brightnessOutput.contains("Brightness"), "Should show brightness label")
        #expect(volumeOutput.contains("0.80"), "Should show volume value")
        #expect(brightnessOutput.contains("0.40"), "Should show brightness value")
    }
    
    @Test func sliderBindingTypes() {
        // Given - Sliders with different binding types
        let doubleSlider = Slider(value: .constant(50.0), in: 0...100, label: "Double")
        let floatSlider = Slider(value: .constant(Float(25.5)), in: Float(0)...Float(50), label: "Float")
        
        // When
        let doubleOutput = renderSlider(doubleSlider)
        let floatOutput = renderSlider(floatSlider)
        
        // Then
        #expect(doubleOutput.contains("50.00"), "Should show double value")
        #expect(floatOutput.contains("25.50"), "Should show float value")
    }
    
    // MARK: - Range and Step Tests
    
    @Test func sliderCustomRange() {
        // Given - Sliders with custom ranges
        let temperatureSlider = Slider(value: .constant(20.0), in: -10...40, label: "Temperature")
        let percentSlider = Slider(value: .constant(85.0), in: 0...100, label: "Progress")
        
        // When
        let tempOutput = renderSlider(temperatureSlider)
        let progressOutput = renderSlider(percentSlider)
        
        // Then
        #expect(tempOutput.contains("20.00"), "Should show temperature value")
        #expect(progressOutput.contains("85.00"), "Should show progress value")
        #expect(tempOutput.contains("Temperature"), "Should show temperature label")
        #expect(progressOutput.contains("Progress"), "Should show progress label")
    }
    
    @Test func sliderWithStep() {
        // Given - Slider with step specification
        let slider = Slider(value: .constant(5.0), in: 0...10, step: 1.0, label: "Stepped")
        
        // When
        let output = renderSlider(slider)
        
        // Then
        #expect(output.contains("5.00"), "Should show current value")
        #expect(output.contains("Stepped"), "Should show label")
        #expect(output.contains("["), "Should show slider structure")
    }
    
    @Test func sliderBoundaryValues() {
        // Given - Sliders at boundary values
        let minSlider = Slider(value: .constant(0.0), in: 0...10, label: "Minimum")
        let maxSlider = Slider(value: .constant(10.0), in: 0...10, label: "Maximum")
        
        // When
        let minOutput = renderSlider(minSlider)
        let maxOutput = renderSlider(maxSlider)
        
        // Then
        #expect(minOutput.contains("0.00"), "Should show minimum value")
        #expect(maxOutput.contains("10.00"), "Should show maximum value")
        #expect(minOutput.contains("Minimum"), "Should show minimum label")
        #expect(maxOutput.contains("Maximum"), "Should show maximum label")
    }
    
    // MARK: - Focus Management Tests
    
    @Test func sliderFocusDisplay() {
        // Given - Slider that can be focused
        let slider = Slider(value: .constant(0.6), in: 0...1, label: "Focusable")
        
        // When
        let output = renderSlider(slider)
        
        // Then - Basic display (focus state not testable in static test)
        #expect(output.contains("Focusable"), "Should show label")
        #expect(output.contains("0.60"), "Should show value")
        #expect(output.contains("["), "Should show slider structure")
    }
    
    @Test func sliderFocusSize() {
        // Given - Slider size calculation
        let slider = Slider(value: .constant(0.5), in: 0...1, label: "Test")
        
        // When
        let output = renderSlider(slider)
        
        // Then - Test that slider renders correctly
        #expect(output.contains("Test"), "Should show slider label")
        #expect(!output.isEmpty, "Should produce some output")
        #expect(output.contains("0.50"), "Should show value")
    }
    
    @Test func sliderMultipleFocus() {
        // Given - Multiple sliders (test that each renders independently)
        let slider1 = Slider(value: .constant(0.1), in: 0...1, label: "First")
        let slider2 = Slider(value: .constant(0.5), in: 0...1, label: "Second")
        let slider3 = Slider(value: .constant(0.9), in: 0...1, label: "Third")
        
        // When
        let output1 = renderSlider(slider1)
        let output2 = renderSlider(slider2)
        let output3 = renderSlider(slider3)
        
        // Then - All sliders should render correctly
        #expect(output1.contains("First"), "Should show First")
        #expect(output2.contains("Second"), "Should show Second")
        #expect(output3.contains("Third"), "Should show Third")
        #expect(output1.contains("0.10"), "Should show first value")
        #expect(output2.contains("0.50"), "Should show second value")
        #expect(output3.contains("0.90"), "Should show third value")
    }
    
    // MARK: - Edge Cases Tests
    
    @Test func sliderMinMaxValues() {
        // Given - Sliders at extreme values
        let verySmallSlider = Slider(value: .constant(0.001), in: 0...1, label: "Small")
        let veryLargeSlider = Slider(value: .constant(999.99), in: 0...1000, label: "Large")
        
        // When
        let smallOutput = renderSlider(verySmallSlider)
        let largeOutput = renderSlider(veryLargeSlider)
        
        // Then
        #expect(smallOutput.contains("0.00"), "Should show small value (rounded)")
        #expect(largeOutput.contains("999.99"), "Should show large value")
        #expect(smallOutput.contains("Small"), "Should show small label")
        #expect(largeOutput.contains("Large"), "Should show large label")
    }
    
    @Test func sliderZeroRange() {
        // Given - Slider with very small range (to avoid division by zero)
        let smallRangeSlider = Slider(value: .constant(5.0), in: 4.99...5.01, label: "Small")
        
        // When
        let output = renderSlider(smallRangeSlider)
        
        // Then - Should still show structure
        #expect(output.contains("Small"), "Should show label even with small range")
        #expect(output.contains("5.00"), "Should show the value")
        #expect(output.contains("["), "Should show slider structure")
    }
    
    @Test func sliderLongLabels() {
        // Given - Slider with long label
        let slider = Slider(value: .constant(0.5), in: 0...1, label: "This is a very long slider label")
        
        // When
        let output = renderSlider(slider)
        
        // Then - Check for parts that should be present (long text may be truncated in display)
        #expect(output.contains("very long slider label"), "Should show long label")
        #expect(output.contains("["), "Should show slider structure")
        #expect(output.contains("█"), "Should show slider bar")
        // Note: Value might be truncated due to display width constraints
    }
    
    @Test func sliderSpecialValues() {
        // Given - Sliders with special characters in labels
        let emojiSlider = Slider(value: .constant(0.5), in: 0...1, label: "🎵 Volume")
        let specialSlider = Slider(value: .constant(0.8), in: 0...1, label: "Value (%)");
        
        // When
        let emojiOutput = renderSlider(emojiSlider)
        let specialOutput = renderSlider(specialSlider)
        
        // Then
        #expect(emojiOutput.contains("🎵 Volume"), "Should show emoji in label")
        #expect(emojiOutput.contains("0.50"), "Should show emoji slider value")
        #expect(specialOutput.contains("Value (%)"), "Should show special characters in label")
        #expect(specialOutput.contains("0.80"), "Should show special slider value")
    }
}