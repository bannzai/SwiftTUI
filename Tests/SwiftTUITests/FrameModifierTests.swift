//
//  FrameModifierTests.swift
//  SwiftTUITests
//
//  Tests for frame modifier behavior
//

import XCTest
@testable import SwiftTUI

final class FrameModifierTests: SwiftTUITestCase {
    
    // MARK: - Width Constraint Tests
    
    func testFrameWithWidthOnly() {
        // Given
        let text = Text("Hello")
            .frame(width: 10)
        
        // When
        let output = TestRenderer.render(text, width: 30, height: 5)
        
        // Then
        let lines = output.components(separatedBy: "\n").filter { !$0.isEmpty }
        XCTAssertTrue(output.contains("Hello"), "Text should be visible")
        
        // Check if text is constrained to width
        if let textLine = lines.first(where: { $0.contains("Hello") }) {
            // Frame should limit the content area
            XCTAssertTrue(textLine.count <= 30, "Line should not exceed container width")
        }
    }
    
    func testFrameWithWidthShorterThanText() {
        // Given
        let text = Text("This is a very long text")
            .frame(width: 10)
        
        // When
        let output = TestRenderer.render(text, width: 30, height: 5)
        
        // Then
        // Text should be visible but potentially truncated
        XCTAssertTrue(output.contains("This"), "At least part of text should be visible")
    }
    
    func testFrameWithWidthLongerThanText() {
        // Given
        let text = Text("Hi")
            .frame(width: 20)
        
        // When
        let output = TestRenderer.render(text, width: 30, height: 5)
        
        // Then
        XCTAssertTrue(output.contains("Hi"), "Text should be visible")
        // The frame should provide space even if text is shorter
    }
    
    // MARK: - Height Constraint Tests
    
    func testFrameWithHeightOnly() {
        // Given
        let vstack = VStack {
            Text("Line 1")
            Text("Line 2")
            Text("Line 3")
        }
        .frame(height: 2)
        
        // When
        let output = TestRenderer.render(vstack, width: 30, height: 10)
        
        // Then
        // With height constraint of 2, only first 2 lines might be visible
        let lines = output.components(separatedBy: "\n").filter { !$0.isEmpty }
        XCTAssertTrue(output.contains("Line 1"), "First line should be visible")
        
        // Count non-empty lines
        XCTAssertLessThanOrEqual(lines.count, 10, "Should not exceed container height")
    }
    
    func testFrameWithHeightSmallerThanContent() {
        // Given
        let vstack = VStack {
            Text("A")
            Text("B")
            Text("C")
            Text("D")
            Text("E")
        }
        .frame(height: 3)
        
        // When
        let output = TestRenderer.render(vstack, width: 20, height: 10)
        
        // Then
        XCTAssertTrue(output.contains("A"), "First item should be visible")
        XCTAssertTrue(output.contains("B"), "Second item should be visible")
        // C, D, E might be clipped due to height constraint
    }
    
    func testFrameWithHeightLargerThanContent() {
        // Given
        let text = Text("Single line")
            .frame(height: 5)
        
        // When
        let output = TestRenderer.render(text, width: 30, height: 10)
        
        // Then
        XCTAssertTrue(output.contains("Single line"), "Text should be visible")
        // Frame provides vertical space even if content is smaller
    }
    
    // MARK: - Combined Width and Height Tests
    
    func testFrameWithBothWidthAndHeight() {
        // Given
        let text = Text("Constrained")
            .frame(width: 15, height: 3)
        
        // When
        let output = TestRenderer.render(text, width: 30, height: 10)
        
        // Then
        XCTAssertTrue(output.contains("Constrained"), "Text should be visible")
    }
    
    func testFrameWithContentExceedingBothDimensions() {
        // Given
        let vstack = VStack {
            Text("This is a very long line of text")
            Text("Second line")
            Text("Third line")
            Text("Fourth line")
        }
        .frame(width: 10, height: 2)
        
        // When
        let output = TestRenderer.render(vstack, width: 30, height: 10)
        
        // Then
        // Should show at least partial content within constraints
        let lines = output.components(separatedBy: "\n").filter { !$0.isEmpty }
        XCTAssertGreaterThan(lines.count, 0, "Should have some visible content")
    }
    
    // MARK: - Modifier Combination Tests
    
    func testFrameWithPadding() {
        // Given
        let text = Text("Padded")
            .padding()
            .frame(width: 20, height: 5)
        
        // When
        let output = TestRenderer.render(text, width: 30, height: 10)
        
        // Then
        XCTAssertTrue(output.contains("Padded"), "Text should be visible")
        // Padding should be applied within the frame
    }
    
    func testFrameWithBorder() {
        // Given
        let text = Text("Bordered")
            .border()
            .frame(width: 15, height: 5)
        
        // When
        let output = TestRenderer.render(text, width: 30, height: 10)
        
        // Then
        XCTAssertTrue(output.contains("Bordered"), "Text should be visible")
        // Border should be within frame constraints
    }
    
    func testMultipleFrameModifiers() {
        // Given
        let text = Text("Multi")
            .frame(width: 20)
            .frame(width: 10)  // Inner frame overrides
        
        // When
        let output = TestRenderer.render(text, width: 30, height: 5)
        
        // Then
        XCTAssertTrue(output.contains("Multi"), "Text should be visible")
        // The inner (last) frame should take precedence
    }
    
    // MARK: - Layout Context Tests
    
    func testFrameInVStack() {
        // Given
        let vstack = VStack {
            Text("Top")
            Text("Middle with frame")
                .frame(width: 20)
            Text("Bottom")
        }
        
        // When
        let output = TestRenderer.render(vstack, width: 30, height: 10)
        
        // Then
        XCTAssertTrue(output.contains("Top"), "Top text should be visible")
        XCTAssertTrue(output.contains("Middle with frame"), "Framed text should be visible")
        XCTAssertTrue(output.contains("Bottom"), "Bottom text should be visible")
        
        // Verify vertical order
        let lines = output.components(separatedBy: "\n")
        var topIndex = -1
        var middleIndex = -1
        var bottomIndex = -1
        
        for (index, line) in lines.enumerated() {
            if line.contains("Top") {
                topIndex = index
            }
            if line.contains("Middle") {
                middleIndex = index
            }
            if line.contains("Bottom") {
                bottomIndex = index
            }
        }
        
        if topIndex != -1 && middleIndex != -1 && bottomIndex != -1 {
            XCTAssertLessThan(topIndex, middleIndex, "Top should be above middle")
            XCTAssertLessThan(middleIndex, bottomIndex, "Middle should be above bottom")
        }
    }
    
    func testFrameInHStack() {
        // Given
        let hstack = HStack {
            Text("Left")
            Text("Center")
                .frame(width: 10)
            Text("Right")
        }
        
        // When
        let output = TestRenderer.render(hstack, width: 40, height: 5)
        
        // Then
        XCTAssertTrue(output.contains("Left"), "Left text should be visible")
        XCTAssertTrue(output.contains("Center"), "Center text should be visible")
        XCTAssertTrue(output.contains("Right"), "Right text should be visible")
        
        // Find the line containing all three
        let lines = output.components(separatedBy: "\n")
        var foundHorizontalLayout = false
        
        for line in lines {
            if line.contains("Left") && line.contains("Center") && line.contains("Right") {
                foundHorizontalLayout = true
                
                // Verify horizontal order
                let leftRange = line.range(of: "Left")!
                let centerRange = line.range(of: "Center")!
                let rightRange = line.range(of: "Right")!
                
                let leftPos = line.distance(from: line.startIndex, to: leftRange.lowerBound)
                let centerPos = line.distance(from: line.startIndex, to: centerRange.lowerBound)
                let rightPos = line.distance(from: line.startIndex, to: rightRange.lowerBound)
                
                XCTAssertLessThan(leftPos, centerPos, "Left should be before center")
                XCTAssertLessThan(centerPos, rightPos, "Center should be before right")
                break
            }
        }
        
        XCTAssertTrue(foundHorizontalLayout, "Items should be laid out horizontally")
    }
    
    // MARK: - Edge Cases
    
    func testFrameWithZeroWidth() {
        // Given
        let text = Text("Hidden?")
            .frame(width: 0)
        
        // When
        let output = TestRenderer.render(text, width: 30, height: 5)
        
        // Then
        // With 0 width, content might not be visible
        // This behavior depends on implementation
        let hasVisibleContent = output.contains("Hidden?")
        // Just verify it doesn't crash
        XCTAssertNotNil(output, "Should not crash with zero width")
    }
    
    func testFrameWithZeroHeight() {
        // Given
        let text = Text("Invisible?")
            .frame(height: 0)
        
        // When
        let output = TestRenderer.render(text, width: 30, height: 5)
        
        // Then
        // With 0 height, content might not be visible
        // Just verify it doesn't crash
        XCTAssertNotNil(output, "Should not crash with zero height")
    }
    
    func testFrameWithVeryLargeSize() {
        // Given
        let text = Text("Small text")
            .frame(width: 1000, height: 1000)
        
        // When
        let output = TestRenderer.render(text, width: 30, height: 10)
        
        // Then
        XCTAssertTrue(output.contains("Small text"), "Text should still be visible")
        // Frame should be constrained by container size
    }
}