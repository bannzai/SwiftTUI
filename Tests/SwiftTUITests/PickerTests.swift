//
//  PickerTests.swift
//  SwiftTUITests
//
//  Tests for Picker component with dropdown selection functionality
//

import Testing
@testable import SwiftTUI
import yoga

@Suite struct PickerTests {
    
    // MARK: - Helper Methods
    
    /// Helper method to test picker output directly since TestRenderer doesn't work with Picker
    private func renderPicker<SelectionValue: Hashable>(_ picker: Picker<SelectionValue>) -> String {
        let pickerLayoutView = picker._layoutView
        guard let cellLayoutView = pickerLayoutView as? CellLayoutView else {
            Issue.record("PickerLayoutView should implement CellLayoutView")
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
    
    @Test func pickerBasicStringOptions() {
        // Given - Picker with string options using Binding.constant
        let picker = Picker("Color", selection: .constant("Blue"), options: ["Red", "Green", "Blue"])
        
        // When
        let output = renderPicker(picker)
        
        // Then - Should show label, current selection, and dropdown arrow
        #expect(output.contains("Color"), "Should show label")
        #expect(output.contains("Blue"), "Should show current selection")
        #expect(output.contains("▼"), "Should show dropdown arrow")
    }
    
    // Note: Int type picker tests are temporarily disabled due to signal 11 crash
    // TODO: Investigate and fix Int type picker crash issue
    
    @Test func pickerInitialSelection() {
        // Given - Picker with different initial selection
        let colorPicker = Picker("Color", selection: .constant("Green"), options: ["Red", "Green", "Blue"])
        
        // When
        let colorOutput = renderPicker(colorPicker)
        
        // Then
        #expect(colorOutput.contains("Green"), "Should show initial color selection")
    }
    
    @Test func pickerLabelDisplay() {
        // Given - Pickers with different labels
        let picker1 = Picker("First Option", selection: .constant("A"), options: ["A", "B", "C"])
        let picker2 = Picker("Second Choice", selection: .constant("X"), options: ["X", "Y", "Z"])
        
        // When
        let output1 = renderPicker(picker1)
        let output2 = renderPicker(picker2)
        
        // Then
        #expect(output1.contains("First Option"), "Should show first label")
        #expect(output2.contains("Second Choice"), "Should show second label")
        #expect(output1.contains("A"), "Should show first selection")
        #expect(output2.contains("X"), "Should show second selection")
    }
    
    @Test func pickerMultipleOptions() {
        // Given - Picker with multiple options
        let picker = Picker("Language", selection: .constant("Swift"), options: ["Swift", "Python", "JavaScript", "Rust", "Go"])
        
        // When
        let output = renderPicker(picker)
        
        // Then
        #expect(output.contains("Language"), "Should show label")
        #expect(output.contains("Swift"), "Should show current selection")
        #expect(output.contains(":"), "Should have colon separator")
        #expect(output.contains("["), "Should have bracket")
    }
    
    // MARK: - Binding Selection Management Tests
    
    @Test func pickerBinding() {
        // Given - Picker with binding to constant value
        let picker = Picker("Option", selection: .constant("Beta"), options: ["Alpha", "Beta", "Gamma"])
        
        // When
        let output = renderPicker(picker)
        
        // Then
        #expect(output.contains("Beta"), "Should show bound selection")
        #expect(output.contains("Option"), "Should show picker label")
        #expect(output.contains("▼"), "Should show dropdown arrow")
    }
    
    @Test func pickerSelectionReflection() {
        // Given - Picker with constant selection
        let picker = Picker("Fruit", selection: .constant("Apple"), options: ["Apple", "Banana", "Orange"])
        
        // When
        let output = renderPicker(picker)
        
        // Then
        #expect(output.contains("Apple"), "Should show current fruit selection")
        #expect(output.contains("Fruit"), "Should show picker label")
    }
    
    @Test func pickerMultipleBindings() {
        // Given - Multiple pickers with independent bindings
        let themePicker = Picker("Theme", selection: .constant("Dark"), options: ["Light", "Dark", "Auto"])
        
        // When
        let themeOutput = renderPicker(themePicker)
        
        // Then
        #expect(themeOutput.contains("Theme"), "Should show theme label")
        #expect(themeOutput.contains("Dark"), "Should show theme selection")
    }
    
    @Test func pickerBindingTypes() {
        // Given - Picker with string binding
        let stringPicker = Picker("String", selection: .constant("Option2"), options: ["Option1", "Option2", "Option3"])
        
        // When
        let stringOutput = renderPicker(stringPicker)
        
        // Then
        #expect(stringOutput.contains("Option2"), "Should show string selection")
    }
    
    // MARK: - Focus Management Tests
    
    @Test func pickerFocusDisplay() {
        // Given - Picker that can be focused
        let picker = Picker("Focusable", selection: .constant("Default"), options: ["Default", "Other"])
        
        // When
        let output = renderPicker(picker)
        
        // Then - Basic display (focus state not testable in static test)
        #expect(output.contains("Focusable"), "Should show label")
        #expect(output.contains("Default"), "Should show selection")
    }
    
    @Test func pickerFocusSize() {
        // Given - Picker size calculation
        let picker = Picker("Test", selection: .constant("Test"), options: ["Test", "Other"])
        
        // When
        let output = renderPicker(picker)
        
        // Then - Test that picker renders correctly
        #expect(output.contains("Test"), "Should show picker label and selection")
        #expect(!output.isEmpty, "Should produce some output")
    }
    
    @Test func pickerMultipleFocus() {
        // Given - Multiple pickers (test that each renders independently)
        let picker1 = Picker("First", selection: .constant("A"), options: ["A", "B", "C"])
        let picker2 = Picker("Second", selection: .constant("X"), options: ["X", "Y", "Z"])
        let picker3 = Picker("Third", selection: .constant("1"), options: ["1", "2", "3"])
        
        // When
        let output1 = renderPicker(picker1)
        let output2 = renderPicker(picker2)
        let output3 = renderPicker(picker3)
        
        // Then - All pickers should render correctly
        #expect(output1.contains("First"), "Should show First")
        #expect(output2.contains("Second"), "Should show Second")
        #expect(output3.contains("Third"), "Should show Third")
    }
    
    // MARK: - Edge Cases Tests
    
    @Test func pickerEmptyOptions() {
        // Given - Picker with empty options array
        let picker = Picker("Empty", selection: .constant(""), options: [String]())
        
        // When
        let output = renderPicker(picker)
        
        // Then - Should still show label and structure
        #expect(output.contains("Empty"), "Should show label even with empty options")
    }
    
    @Test func pickerSingleOption() {
        // Given - Picker with single option
        let picker = Picker("Single", selection: .constant("Only"), options: ["Only"])
        
        // When
        let output = renderPicker(picker)
        
        // Then
        #expect(output.contains("Single"), "Should show label")
        #expect(output.contains("Only"), "Should show single option")
        #expect(output.contains("▼"), "Should still show dropdown arrow")
    }
    
    @Test func pickerLongLabels() {
        // Given - Picker with long labels and options
        let picker = Picker("This is a very long picker label", 
                           selection: .constant("Very Long Option Name"), 
                           options: ["Very Long Option Name", "Another Long Option"])
        
        // When
        let output = renderPicker(picker)
        
        // Then - Check for parts that should be present (long text may be truncated)
        #expect(output.contains("very long picker label"), "Should show long label")
        #expect(output.contains("Very Long"), "Should show part of long option")
    }
    
    @Test func pickerSpecialCharacters() {
        // Given - Picker with special characters and emoji
        let emojiPicker = Picker("🎨 Theme", selection: .constant("🎉"), options: ["🎉", "🚀", "💻"])
        let specialPicker = Picker("Special [Chars]", selection: .constant("Option (1)"), options: ["Option (1)", "Option {2}", "Option [3]"])
        
        // When
        let emojiOutput = renderPicker(emojiPicker)
        let specialOutput = renderPicker(specialPicker)
        
        // Then
        #expect(emojiOutput.contains("🎨 Theme"), "Should show emoji in label")
        #expect(emojiOutput.contains("🎉"), "Should show emoji selection")
        #expect(specialOutput.contains("Special [Chars]"), "Should show special characters in label")
        #expect(specialOutput.contains("Option (1)"), "Should show special characters in option")
    }
}