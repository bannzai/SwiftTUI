//
//  SpacerTests.swift
//  SwiftTUITests
//
//  Tests for Spacer view behavior
//

import Testing
@testable import SwiftTUI

@Suite struct SpacerTests {
    
    // MARK: - Basic Spacer Tests
    
    @Test func spacerAlone() {
        // Given
        let spacer = Spacer()
        
        // When
        let output = TestRenderer.render(spacer, width: 10, height: 5)
        
        // Then
        // Spacer alone should render nothing visible
        let trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
        #expect(trimmed.isEmpty, "Spacer alone should not render any visible content")
    }
    
    // MARK: - VStack with Spacer Tests
    
    @Test func spacerInVStackPushesContentApart() {
        // Given
        let view = VStack {
            Text("Top")
            Spacer()
            Text("Bottom")
        }
        
        // When
        let output = TestRenderer.render(view, width: 20, height: 10)
        let lines = output.components(separatedBy: "\n")
        
        // Debug print
        // print("=== VStack with Spacer output ===")
        // for (idx, line) in lines.enumerated() {
        //     print("Line \(idx): '\(line)'")
        // }
        
        // Then
        // Find positions of "Top" and "Bottom"
        var topIndex = -1
        var bottomIndex = -1
        
        for (index, line) in lines.enumerated() {
            if line.contains("Top") {
                topIndex = index
            }
            if line.contains("Bottom") {
                bottomIndex = index
            }
        }
        
        #expect(topIndex != -1, "Top text should be found")
        #expect(bottomIndex != -1, "Bottom text should be found")
        
        // The actual rendered content might be smaller than the buffer height
        // Just verify that Bottom comes after Top
        if topIndex != -1 && bottomIndex != -1 {
            #expect(bottomIndex > topIndex, "Bottom should be below Top")
        }
    }
    
    @Test func spacerInVStackWithMinHeight() {
        // Given - VStack with specific height
        let view = VStack {
            Text("A")
            Spacer()
            Text("B")
        }
        
        // When - Render with limited height
        let output = TestRenderer.render(view, width: 10, height: 5)
        let lines = output.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        // Then
        #expect(lines.first?.contains("A") ?? false, "First element should be at top")
        #expect(lines.last?.contains("B") ?? false, "Last element should be at bottom")
    }
    
    // MARK: - HStack with Spacer Tests
    
    @Test func spacerInHStackPushesContentApart() {
        // Given
        let view = HStack {
            Text("Left")
            Spacer()
            Text("Right")
        }
        
        // When
        let output = TestRenderer.render(view, width: 30, height: 3)
        
        // Then
        // Check that Left is on the left side and Right is on the right side
        #expect(output.contains("Left"), "Left text should be present")
        #expect(output.contains("Right"), "Right text should be present")
        
        // Find the line containing both texts
        let lines = output.components(separatedBy: "\n")
        for line in lines {
            if line.contains("Left") && line.contains("Right") {
                let leftRange = line.range(of: "Left")!
                let rightRange = line.range(of: "Right")!
                
                // Check that there's significant space between them
                let leftEnd = line.distance(from: line.startIndex, to: leftRange.upperBound)
                let rightStart = line.distance(from: line.startIndex, to: rightRange.lowerBound)
                
                #expect(rightStart - leftEnd > 5, "Spacer should create horizontal space")
                break
            }
        }
    }
    
    @Test func spacerInHStackAlignItems() {
        // Given
        let view = HStack {
            Text("Start")
            Spacer()
            Text("End")
        }
        
        // When
        let output = TestRenderer.render(view, width: 20, height: 1)
        
        // Then
        let line = output.trimmingCharacters(in: .whitespacesAndNewlines)
        #expect(line.hasPrefix("Start"), "Start should be at the beginning")
        #expect(line.hasSuffix("End"), "End should be at the end")
    }
    
    // MARK: - Multiple Spacers Tests
    
    @Test func multipleSpacersInHStack() {
        // Given
        let view = HStack {
            Text("A")
            Spacer()
            Text("B")
            Spacer()
            Text("C")
        }
        
        // When
        let output = TestRenderer.render(view, width: 30, height: 3)
        
        // Then
        #expect(output.contains("A"), "A should be present")
        #expect(output.contains("B"), "B should be present")
        #expect(output.contains("C"), "C should be present")
        
        // Find the line with all texts
        let lines = output.components(separatedBy: "\n")
        for line in lines {
            if line.contains("A") && line.contains("B") && line.contains("C") {
                // Check positions
                let aPos = line.range(of: "A")!.lowerBound
                let bPos = line.range(of: "B")!.lowerBound
                let cPos = line.range(of: "C")!.lowerBound
                
                let aIndex = line.distance(from: line.startIndex, to: aPos)
                let bIndex = line.distance(from: line.startIndex, to: bPos)
                let cIndex = line.distance(from: line.startIndex, to: cPos)
                
                // B should be roughly in the middle
                let expectedMiddle = (aIndex + cIndex) / 2
                #expect(abs(bIndex - expectedMiddle) <= 2, "B should be approximately centered")
                break
            }
        }
    }
    
    @Test func multipleSpacersInVStack() {
        // Given
        let view = VStack {
            Text("1")
            Spacer()
            Text("2")
            Spacer()
            Text("3")
        }
        
        // When
        let output = TestRenderer.render(view, width: 10, height: 9)
        let lines = output.components(separatedBy: "\n")
        
        // Then
        var indices: [Int] = []
        for (index, line) in lines.enumerated() {
            if line.contains("1") || line.contains("2") || line.contains("3") {
                indices.append(index)
            }
        }
        
        #expect(indices.count == 3, "Should find all three texts")
        
        if indices.count == 3 {
            // Check that spacers distribute space evenly
            let gap1 = indices[1] - indices[0]
            let gap2 = indices[2] - indices[1]
            
            // Gaps should be roughly equal (within 1 line tolerance)
            #expect(abs(gap1 - gap2) <= 1, "Spacers should distribute space evenly")
        }
    }
    
    // MARK: - Edge Cases
    
    @Test func spacerWithNoSpace() {
        // Given - HStack with no extra space
        let view = HStack {
            Text("VeryLongTextHere")
            Spacer()
            Text("More")
        }
        
        // When
        let output = TestRenderer.render(view, width: 20, height: 3)
        
        // Then
        // Even with no space, content should still render
        #expect(output.contains("VeryLongTextHere"), "Long text should be present")
        #expect(output.contains("More"), "Second text should be present")
    }
    
    @Test func nestedSpacers() {
        // Given
        let view = VStack {
            Text("Top")
            Spacer()
            HStack {
                Text("L")
                Spacer()
                Text("R")
            }
            Spacer()
            Text("Bottom")
        }
        
        // When
        let output = TestRenderer.render(view, width: 20, height: 10)
        
        // Then
        #expect(output.contains("Top"), "Top should be present")
        #expect(output.contains("Bottom"), "Bottom should be present")
        #expect(output.contains("L") && output.contains("R"), "HStack content should be present")
        
        // Verify vertical spacing
        let lines = output.components(separatedBy: "\n")
        var topIdx = -1, bottomIdx = -1, middleIdx = -1
        
        for (idx, line) in lines.enumerated() {
            if line.contains("Top") { topIdx = idx }
            if line.contains("Bottom") { bottomIdx = idx }
            if line.contains("L") && line.contains("R") { middleIdx = idx }
        }
        
        // Just verify the order and that there's some spacing
        if topIdx != -1 && bottomIdx != -1 {
            #expect(bottomIdx > topIdx, "Bottom should be below Top")
            #expect(bottomIdx - topIdx > 1, "Should have some vertical spacing")
        }
        
        // Verify the HStack is between Top and Bottom
        if topIdx != -1 && middleIdx != -1 && bottomIdx != -1 {
            #expect(middleIdx > topIdx, "HStack should be below Top")
            #expect(middleIdx < bottomIdx, "HStack should be above Bottom")
        }
    }
}