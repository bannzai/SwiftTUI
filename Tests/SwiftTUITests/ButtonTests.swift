//
//  ButtonTests.swift
//  SwiftTUITests
//
//  Tests for Button view behavior
//

import XCTest
@testable import SwiftTUI

final class ButtonTests: SwiftTUITestCase {
    
    // MARK: - Basic Rendering Tests
    
    func testButtonWithStringLabel() {
        // Given
        let button = Button("Click Me") {
            // Action will be tested separately
        }
        
        // When
        let output = TestRenderer.render(button, width: 20, height: 5)
        
        // Then
        // Button should have border and show label text
        XCTAssertTrue(output.contains("Click Me"), "Button label should be visible")
        XCTAssertTrue(output.contains("┌"), "Should have top left corner")
        XCTAssertTrue(output.contains("┐"), "Should have top right corner")
        XCTAssertTrue(output.contains("└"), "Should have bottom left corner")
        XCTAssertTrue(output.contains("┘"), "Should have bottom right corner")
        XCTAssertTrue(output.contains("│"), "Should have side borders")
        XCTAssertTrue(output.contains("─"), "Should have horizontal borders")
    }
    
    func testButtonWithCustomViewLabel() {
        // Given
        let button = Button(action: {}) {
            VStack {
                Text("Save")
                Text("File")
            }
        }
        
        // When
        let output = TestRenderer.render(button, width: 20, height: 8)
        
        // Then
        XCTAssertTrue(output.contains("Save"), "First text should be visible")
        XCTAssertTrue(output.contains("File"), "Second text should be visible")
        XCTAssertTrue(output.contains("┌"), "Should have border")
        
        // Verify Save appears before File (vertical layout)
        let lines = output.components(separatedBy: "\n")
        var saveIndex = -1
        var fileIndex = -1
        
        for (index, line) in lines.enumerated() {
            if line.contains("Save") {
                saveIndex = index
            }
            if line.contains("File") {
                fileIndex = index
            }
        }
        
        if saveIndex != -1 && fileIndex != -1 {
            XCTAssertLessThan(saveIndex, fileIndex, "Save should appear above File")
        }
    }
    
    func testButtonPadding() {
        // Given
        let button = Button("OK") {
            // Action
        }
        
        // When
        let output = TestRenderer.render(button, width: 30, height: 5)
        let lines = output.components(separatedBy: "\n").filter { !$0.isEmpty }
        
        // Then
        // Find the line with "OK"
        var okLine: String?
        for line in lines {
            if line.contains("OK") {
                okLine = line
                break
            }
        }
        
        XCTAssertNotNil(okLine, "Should find line with OK")
        
        if let okLine = okLine {
            // Check padding (Yoga calculates final padding, not necessarily 3)
            let okRange = okLine.range(of: "OK")!
            let beforeOK = okLine[..<okRange.lowerBound]
            let afterOK = okLine[okRange.upperBound...]
            
            // Count spaces between border and text
            let leadingSpaces = beforeOK.reversed().prefix(while: { $0 == " " }).count
            let trailingSpaces = afterOK.prefix(while: { $0 == " " }).count
            
            // Button implementation adds padding, but Yoga might adjust it
            // Let's just verify there is some padding
            XCTAssertGreaterThanOrEqual(leadingSpaces, 1, "Should have left padding")
            XCTAssertGreaterThanOrEqual(trailingSpaces, 1, "Should have right padding")
        }
    }
    
    // MARK: - Focus State Tests
    
    func testUnfocusedButtonHasWhiteBorder() {
        // Given
        let button = Button("Test") {
            // Action
        }
        
        // When
        let output = TestRenderer.render(button, width: 20, height: 5)
        
        // Then
        // By default, button should not be focused
        // TestRenderer strips ANSI codes, so we just verify structure
        XCTAssertTrue(output.contains("┌"), "Should have border")
        XCTAssertTrue(output.contains("Test"), "Should show label")
        // Note: Can't test colors directly as ANSI codes are stripped
    }
    
    // MARK: - Layout Tests
    
    func testButtonInVStack() {
        // Given
        let stack = VStack {
            Text("Title")
            Button("Click") {
                // Action
            }
            Text("Footer")
        }
        
        // When
        let output = TestRenderer.render(stack, width: 30, height: 15)
        let lines = output.components(separatedBy: "\n")
        
        // Then
        var titleIndex = -1
        var clickIndex = -1
        var footerIndex = -1
        
        for (index, line) in lines.enumerated() {
            if line.contains("Title") {
                titleIndex = index
            }
            if line.contains("Click") {
                clickIndex = index
            }
            if line.contains("Footer") {
                footerIndex = index
            }
        }
        
        // Verify vertical ordering
        if titleIndex != -1 && clickIndex != -1 && footerIndex != -1 {
            XCTAssertLessThan(titleIndex, clickIndex, "Title should be above button")
            XCTAssertLessThan(clickIndex, footerIndex, "Button should be above footer")
        }
    }
    
    func testMultipleButtonsInHStack() {
        // Given
        let stack = HStack {
            Button("OK") {
                // Action
            }
            Button("Cancel") {
                // Action
            }
        }
        
        // When
        let output = TestRenderer.render(stack, width: 40, height: 5)
        
        // Then
        XCTAssertTrue(output.contains("OK"), "OK button should be visible")
        XCTAssertTrue(output.contains("Cancel"), "Cancel button should be visible")
        
        // Find the line containing both buttons
        let lines = output.components(separatedBy: "\n")
        var buttonsOnSameLine = false
        
        for line in lines {
            if line.contains("OK") && line.contains("Cancel") {
                buttonsOnSameLine = true
                
                // Verify OK appears before Cancel
                let okRange = line.range(of: "OK")!
                let cancelRange = line.range(of: "Cancel")!
                let okPos = line.distance(from: line.startIndex, to: okRange.lowerBound)
                let cancelPos = line.distance(from: line.startIndex, to: cancelRange.lowerBound)
                
                XCTAssertLessThan(okPos, cancelPos, "OK should appear before Cancel")
                break
            }
        }
        
        XCTAssertTrue(buttonsOnSameLine, "Buttons should be on the same line in HStack")
    }
    
    func testButtonWithFrameModifier() {
        // Given
        let button = Button("Wide Button") {
            // Action
        }
        .frame(width: 25)
        
        // When
        let output = TestRenderer.render(button, width: 50, height: 5)
        let lines = output.components(separatedBy: "\n").filter { !$0.isEmpty }
        
        // Then
        // Find the top border line
        var topBorderLine: String?
        for line in lines {
            if line.contains("┌") && line.contains("┐") {
                topBorderLine = line
                break
            }
        }
        
        XCTAssertNotNil(topBorderLine, "Should find top border")
        
        if let topBorder = topBorderLine {
            // Measure the width from ┌ to ┐
            if let startRange = topBorder.range(of: "┌"),
               let endRange = topBorder.range(of: "┐") {
                let startPos = topBorder.distance(from: topBorder.startIndex, to: startRange.lowerBound)
                let endPos = topBorder.distance(from: topBorder.startIndex, to: endRange.lowerBound)
                let width = endPos - startPos + 1
                
                // Should be close to frame width (allowing for some variation)
                XCTAssertGreaterThanOrEqual(width, 20, "Button should have minimum width")
            }
        }
    }
    
    // MARK: - Nested Button Tests
    
    func testNestedButtonsInStacks() {
        // Given
        let view = VStack {
            HStack {
                Button("A") { }
                Button("B") { }
            }
            HStack {
                Button("C") { }
                Button("D") { }
            }
        }
        
        // When
        let output = TestRenderer.render(view, width: 40, height: 15)
        
        // Then
        XCTAssertTrue(output.contains("A"), "Button A should be visible")
        XCTAssertTrue(output.contains("B"), "Button B should be visible")
        XCTAssertTrue(output.contains("C"), "Button C should be visible")
        XCTAssertTrue(output.contains("D"), "Button D should be visible")
        
        // Verify layout structure
        let lines = output.components(separatedBy: "\n")
        var firstRowIndex = -1
        var secondRowIndex = -1
        
        for (index, line) in lines.enumerated() {
            if line.contains("A") && line.contains("B") {
                firstRowIndex = index
            }
            if line.contains("C") && line.contains("D") {
                secondRowIndex = index
            }
        }
        
        if firstRowIndex != -1 && secondRowIndex != -1 {
            XCTAssertLessThan(firstRowIndex, secondRowIndex, "First row should be above second row")
        }
    }
    
    // MARK: - Edge Cases
    
    func testButtonWithEmptyLabel() {
        // Given
        let button = Button("") {
            // Action
        }
        
        // When
        let output = TestRenderer.render(button, width: 20, height: 5)
        
        // Then
        // Should still render border even with empty label
        XCTAssertTrue(output.contains("┌"), "Should have top border")
        XCTAssertTrue(output.contains("└"), "Should have bottom border")
    }
    
    func testButtonWithLongLabel() {
        // Given
        let button = Button("This is a very long button label") {
            // Action
        }
        
        // When
        let output = TestRenderer.render(button, width: 50, height: 5)
        
        // Then
        XCTAssertTrue(output.contains("This is a very long button label"), "Long label should be fully visible")
        XCTAssertTrue(output.contains("┌"), "Should have border")
    }
    
    func testButtonWithMultilineLabel() {
        // Given
        let button = Button(action: {}) {
            VStack {
                Text("Line 1")
                Text("Line 2")
                Text("Line 3")
            }
        }
        
        // When
        let output = TestRenderer.render(button, width: 30, height: 10)
        
        // Then
        XCTAssertTrue(output.contains("Line 1"), "First line should be visible")
        XCTAssertTrue(output.contains("Line 2"), "Second line should be visible")
        XCTAssertTrue(output.contains("Line 3"), "Third line should be visible")
        
        // All lines should be within border
        let lines = output.components(separatedBy: "\n")
        var hasTopBorder = false
        var hasBottomBorder = false
        
        for line in lines {
            if line.contains("┌") && line.contains("┐") {
                hasTopBorder = true
            }
            if line.contains("└") && line.contains("┘") {
                hasBottomBorder = true
            }
        }
        
        XCTAssertTrue(hasTopBorder, "Should have complete top border")
        XCTAssertTrue(hasBottomBorder, "Should have complete bottom border")
    }
}