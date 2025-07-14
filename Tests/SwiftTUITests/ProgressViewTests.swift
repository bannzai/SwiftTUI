//
//  ProgressViewTests.swift
//  SwiftTUITests
//
//  Tests for ProgressView component with determinate and indeterminate progress display
//

import Testing
@testable import SwiftTUI
import yoga

@Suite struct ProgressViewTests {
    
    // MARK: - Helper Methods
    
    /// Helper method to test progress view output directly since TestRenderer might not work with animations
    private func renderProgressView(_ progressView: ProgressView) -> String {
        let progressLayoutView = progressView._layoutView
        guard let cellLayoutView = progressLayoutView as? CellLayoutView else {
            Issue.record("ProgressViewLayoutView should implement CellLayoutView")
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
    
    @Test func progressViewIndeterminateBasic() {
        // Given - Indeterminate progress without label
        let progressView = ProgressView()
        
        // When
        let output = renderProgressView(progressView)
        
        // Then - Should show spinner character
        let spinnerChars = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
        let containsSpinner = spinnerChars.contains { output.contains($0) }
        #expect(containsSpinner, "Should show one of the spinner characters")
        #expect(!output.contains("["), "Should not show progress bar")
        #expect(!output.contains("%"), "Should not show percentage")
    }
    
    @Test func progressViewIndeterminateWithLabel() {
        // Given - Indeterminate progress with label
        let progressView = ProgressView("Loading...")
        
        // When
        let output = renderProgressView(progressView)
        
        // Then - Should show label and spinner
        #expect(output.contains("Loading..."), "Should show label")
        let spinnerChars = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
        let containsSpinner = spinnerChars.contains { output.contains($0) }
        #expect(containsSpinner, "Should show spinner character after label")
    }
    
    @Test func progressViewDeterminateBasic() {
        // Given - Determinate progress without label (50%)
        let progressView = ProgressView(value: 0.5, total: 1.0)
        
        // When
        let output = renderProgressView(progressView)
        
        // Then - Should show progress bar and percentage
        #expect(output.contains("["), "Should show progress bar start")
        #expect(output.contains("]"), "Should show progress bar end")
        #expect(output.contains("█"), "Should show filled portion")
        #expect(output.contains("░"), "Should show empty portion")
        #expect(output.contains("50%"), "Should show 50% progress")
    }
    
    @Test func progressViewDeterminateWithLabel() {
        // Given - Determinate progress with label
        let progressView = ProgressView(value: 0.75, total: 1.0, label: "Download")
        
        // When
        let output = renderProgressView(progressView)
        
        // Then - Should show label, progress bar, and percentage
        #expect(output.contains("Download"), "Should show label")
        #expect(output.contains("["), "Should show progress bar")
        #expect(output.contains("]"), "Should show progress bar")
        #expect(output.contains("75%"), "Should show 75% progress")
    }
    
    @Test func progressViewSpinnerAnimation() {
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
        #expect(foundCount == 1, "Should contain exactly one spinner character")
    }
    
    // MARK: - Progress Value Tests
    
    @Test func progressViewValueRange() {
        // Given - Different progress values
        let progress0 = ProgressView(value: 0.0, label: "Start")
        let progress50 = ProgressView(value: 0.5, label: "Half")
        let progress100 = ProgressView(value: 1.0, label: "Done")
        
        // When
        let output0 = renderProgressView(progress0)
        let output50 = renderProgressView(progress50)
        let output100 = renderProgressView(progress100)
        
        // Then
        #expect(output0.contains("0%"), "Should show 0%")
        #expect(output50.contains("50%"), "Should show 50%")
        #expect(output100.contains("100%"), "Should show 100%")
    }
    
    @Test func progressViewValueClamping() {
        // Given - Values outside 0-1 range
        let progressNegative = ProgressView(value: -0.5, label: "Negative")
        let progressOverflow = ProgressView(value: 1.5, label: "Overflow")
        
        // When
        let outputNegative = renderProgressView(progressNegative)
        let outputOverflow = renderProgressView(progressOverflow)
        
        // Then - Should clamp to 0% and 100%
        #expect(outputNegative.contains("0%"), "Should clamp negative to 0%")
        #expect(outputOverflow.contains("100%"), "Should clamp overflow to 100%")
        
        // Check bar rendering
        let negativeBar = outputNegative.components(separatedBy: "[").last?.components(separatedBy: "]").first ?? ""
        #expect(!negativeBar.contains("█"), "Negative progress should have empty bar")
        
        let overflowBar = outputOverflow.components(separatedBy: "[").last?.components(separatedBy: "]").first ?? ""
        #expect(!overflowBar.contains("░"), "Overflow progress should have full bar")
    }
    
    @Test func progressViewCustomTotal() {
        // Given - Custom total values
        let progress1 = ProgressView(value: 50, total: 100, label: "Steps")
        let progress2 = ProgressView(value: 3, total: 10, label: "Items")
        
        // When
        let output1 = renderProgressView(progress1)
        let output2 = renderProgressView(progress2)
        
        // Then
        #expect(output1.contains("50%"), "Should calculate 50/100 = 50%")
        #expect(output2.contains("30%"), "Should calculate 3/10 = 30%")
    }
    
    @Test func progressViewProgressCalculation() {
        // Given - Various progress calculations
        let progress1 = ProgressView(value: 1, total: 3) // 33.33...%
        let progress2 = ProgressView(value: 2, total: 3) // 66.66...%
        let progress3 = ProgressView(value: 1, total: 8) // 12.5%
        
        // When
        let output1 = renderProgressView(progress1)
        let output2 = renderProgressView(progress2)
        let output3 = renderProgressView(progress3)
        
        // Then - Should round to nearest percent
        #expect(output1.contains("33%"), "Should show 33% for 1/3")
        #expect(output2.contains("67%"), "Should show 67% for 2/3")
        // 1/8 = 0.125 = 12.5%, which rounds to 12% with %.0f format
        #expect(output3.contains("12%") || output3.contains("13%"), "Should show 12% or 13% for 1/8")
    }
    
    // MARK: - Style and Layout Tests
    
    @Test func progressViewBarRendering() {
        // Given - Progress at 25% (5 filled, 15 empty out of 20)
        let progressView = ProgressView(value: 0.25, label: "Quarter")
        
        // When
        let output = renderProgressView(progressView)
        
        // Then - Check bar composition
        if let barContent = output.components(separatedBy: "[").last?.components(separatedBy: "]").first {
            let filledCount = barContent.filter { $0 == "█" }.count
            let emptyCount = barContent.filter { $0 == "░" }.count
            #expect(filledCount == 5, "Should have 5 filled blocks for 25%")
            #expect(emptyCount == 15, "Should have 15 empty blocks for 25%")
            #expect(filledCount + emptyCount == 20, "Should have total 20 blocks")
        }
    }
    
    @Test func progressViewWidthCalculation() {
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
        #expect(output1.count > 0, "Indeterminate should render something")
        #expect(output2.contains("Test "), "Should show label with space before spinner")
        #expect(output3.contains("[") && output3.contains("]"), "Should show progress bar")
        #expect(output4.contains("Test ["), "Should show label before progress bar")
        
        // Verify relative sizes
        #expect(output2.count > output1.count, "Label version should be longer")
        #expect(output4.count > output3.count, "Label version should be longer")
    }
    
    @Test func progressViewLabelSpacing() {
        // Given - Progress with label
        let progressView = ProgressView(value: 0.5, label: "Progress")
        
        // When
        let output = renderProgressView(progressView)
        
        // Then - Check spacing
        #expect(output.contains("Progress ["), "Should have space between label and bar")
        #expect(output.contains("] 50%"), "Should have space between bar and percentage")
    }
    
    // MARK: - Edge Cases Tests
    
    @Test func progressViewZeroProgress() {
        // Given - 0% progress
        let progressView = ProgressView(value: 0.0, label: "Empty")
        
        // When
        let output = renderProgressView(progressView)
        
        // Then
        #expect(output.contains("0%"), "Should show 0%")
        if let barContent = output.components(separatedBy: "[").last?.components(separatedBy: "]").first {
            #expect(!barContent.contains("█"), "Should have no filled blocks")
            #expect(barContent.filter { $0 == "░" }.count == 20, "Should have all 20 empty blocks")
        }
    }
    
    @Test func progressViewFullProgress() {
        // Given - 100% progress
        let progressView = ProgressView(value: 1.0, label: "Complete")
        
        // When
        let output = renderProgressView(progressView)
        
        // Then
        #expect(output.contains("100%"), "Should show 100%")
        if let barContent = output.components(separatedBy: "[").last?.components(separatedBy: "]").first {
            #expect(!barContent.contains("░"), "Should have no empty blocks")
            #expect(barContent.filter { $0 == "█" }.count == 20, "Should have all 20 filled blocks")
        }
    }
    
    @Test func progressViewSpecialCharacters() {
        // Given - Special characters in labels
        let progressEmoji = ProgressView(value: 0.8, label: "📦 Package")
        let progressSpecial = ProgressView("⚡️ Lightning <Fast>")
        
        // When
        let outputEmoji = renderProgressView(progressEmoji)
        let outputSpecial = renderProgressView(progressSpecial)
        
        // Then
        #expect(outputEmoji.contains("📦 Package"), "Should show emoji in label")
        #expect(outputEmoji.contains("80%"), "Should show percentage with emoji label")
        #expect(outputSpecial.contains("⚡️ Lightning <Fast>"), "Should show special characters")
        let spinnerChars = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
        let containsSpinner = spinnerChars.contains { outputSpecial.contains($0) }
        #expect(containsSpinner, "Should show spinner with special label")
    }
}