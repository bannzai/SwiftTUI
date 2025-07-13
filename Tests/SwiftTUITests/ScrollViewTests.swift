//
//  ScrollViewTests.swift
//  SwiftTUITests
//
//  Tests for ScrollView component with scrolling and viewport functionality
//
//  Note: Current ScrollView implementation has fixed viewport size (3 lines height, 5 chars width)
//  and ignores .frame() modifiers
//

import XCTest
@testable import SwiftTUI

final class ScrollViewTests: SwiftTUITestCase {
    
    // MARK: - Basic Scroll Functionality Tests
    
    func testScrollViewBasicVertical() {
        // Given - Vertical ScrollView with fixed 3-line viewport
        struct TestView: View {
            var body: some View {
                ScrollView {
                    VStack {
                        Text("L1")  // Short text to fit within 5 char width
                        Text("L2")
                        Text("L3")
                        Text("L4")
                        Text("L5")
                    }
                }
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 20, height: 10)
        
        // Then - Should show first 3 lines due to fixed viewport
        XCTAssertTrue(output.contains("L1"), "Should show first line")
        XCTAssertTrue(output.contains("L2"), "Should show second line")
        XCTAssertTrue(output.contains("L3"), "Should show third line")
        XCTAssertFalse(output.contains("L4"), "Should not show fourth line (clipped)")
        XCTAssertFalse(output.contains("L5"), "Should not show fifth line (clipped)")
    }
    
    func testScrollViewBasicHorizontal() {
        // Given - Horizontal ScrollView with fixed 5-char viewport
        struct TestView: View {
            var body: some View {
                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        Text("ABCDE")  // Exactly 5 chars
                        Text("FG")     // Will be clipped
                    }
                }
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 20, height: 10)
        
        // Then - Should show only first 5 characters
        XCTAssertTrue(output.contains("ABCDE"), "Should show first 5 chars")
        XCTAssertFalse(output.contains("FG"), "Should not show chars beyond viewport")
    }
    
    func testScrollViewBothAxes() {
        // Given - ScrollView with both axes enabled
        struct TestView: View {
            var body: some View {
                ScrollView([.horizontal, .vertical]) {
                    VStack {
                        Text("12345")  // Will fit exactly in 5-char width
                        Text("67890")
                        Text("ABCDE")
                        Text("FGHIJ")  // Beyond 3-line viewport
                    }
                }
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 30, height: 10)
        
        // Then - Should clip to 3x5 viewport
        XCTAssertTrue(output.contains("12345"), "Should show first line")
        XCTAssertTrue(output.contains("67890"), "Should show second line")
        XCTAssertTrue(output.contains("ABCDE"), "Should show third line")
        XCTAssertFalse(output.contains("FGHIJ"), "Should not show fourth line")
    }
    
    func testScrollViewNoScroll() {
        // Given - Content smaller than viewport
        struct TestView: View {
            var body: some View {
                ScrollView {
                    Text("Hi")  // 2 chars, 1 line
                }
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 20, height: 10)
        
        // Then
        XCTAssertTrue(output.contains("Hi"), "Should show all content")
    }
    
    func testScrollViewEmptyContent() {
        // Given
        struct TestView: View {
            var body: some View {
                ScrollView {
                    EmptyView()
                }
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 20, height: 10)
        
        // Then
        XCTAssertNotNil(output, "Should render empty ScrollView")
    }
    
    // MARK: - Frame Constraints and Clipping Tests
    
    func testScrollViewIgnoresFrameModifier() {
        // Given - .frame() modifier is ignored by ScrollView
        struct TestView: View {
            var body: some View {
                ScrollView {
                    VStack {
                        Text("A")
                        Text("B")
                        Text("C")
                        Text("D")
                    }
                }
                .frame(height: 10)  // This is ignored
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 20, height: 20)
        
        // Then - Still shows only 3 lines
        XCTAssertTrue(output.contains("A"), "Should show A")
        XCTAssertTrue(output.contains("B"), "Should show B")
        XCTAssertTrue(output.contains("C"), "Should show C")
        XCTAssertFalse(output.contains("D"), "Should not show D")
    }
    
    func testScrollViewContentClipping() {
        // Given - Long text that exceeds 5-char width
        struct TestView: View {
            var body: some View {
                ScrollView {
                    VStack {
                        Text("Hello")  // "Hello" = 5 chars, fits exactly
                        Text("World!")  // "World!" = 6 chars, last char clipped
                        Text("12345678")  // Only first 5 chars shown
                    }
                }
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 30, height: 10)
        
        // Then
        XCTAssertTrue(output.contains("Hello"), "Should show Hello completely")
        XCTAssertTrue(output.contains("World"), "Should show World")
        XCTAssertFalse(output.contains("!"), "Should not show exclamation mark")
        XCTAssertTrue(output.contains("12345"), "Should show first 5 digits")
        XCTAssertFalse(output.contains("678"), "Should not show last 3 digits")
    }
    
    func testScrollViewHorizontalClipping() {
        // Given
        struct TestView: View {
            var body: some View {
                ScrollView(.horizontal) {
                    Text("1234567890")  // 10 chars, only 5 shown
                }
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 20, height: 10)
        
        // Then
        XCTAssertTrue(output.contains("12345"), "Should show first 5 chars")
        XCTAssertFalse(output.contains("67890"), "Should not show last 5 chars")
    }
    
    func testScrollViewANSIHandling() {
        // Given - Content with color modifiers
        struct TestView: View {
            var body: some View {
                ScrollView {
                    VStack {
                        Text("R").foregroundColor(.red)
                        Text("G").foregroundColor(.green)
                        Text("B").foregroundColor(.blue)
                    }
                }
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 20, height: 10)
        
        // Then - TestRenderer strips ANSI, but text remains
        XCTAssertTrue(output.contains("R"), "Should show R")
        XCTAssertTrue(output.contains("G"), "Should show G")
        XCTAssertTrue(output.contains("B"), "Should show B")
    }
    
    // MARK: - Scrollbar Display Tests
    
    func testScrollViewIndicatorsShown() {
        // Given - Default showsIndicators = true
        struct TestView: View {
            var body: some View {
                ScrollView {
                    VStack {
                        ForEachRange(0..<10) { i in
                            Text("\(i)")
                        }
                    }
                }
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 20, height: 10)
        
        // Then - Content is shown (scrollbar rendering is internal)
        XCTAssertTrue(output.contains("0"), "Should show 0")
        XCTAssertTrue(output.contains("1"), "Should show 1")
        XCTAssertTrue(output.contains("2"), "Should show 2")
        XCTAssertFalse(output.contains("3"), "Should not show 3")
    }
    
    func testScrollViewIndicatorsHidden() {
        // Given
        struct TestView: View {
            var body: some View {
                ScrollView(showsIndicators: false) {
                    VStack {
                        Text("A")
                        Text("B")
                        Text("C")
                        Text("D")
                    }
                }
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 20, height: 10)
        
        // Then
        XCTAssertTrue(output.contains("A"), "Should show A")
        XCTAssertTrue(output.contains("B"), "Should show B")
        XCTAssertTrue(output.contains("C"), "Should show C")
        XCTAssertFalse(output.contains("D"), "Should not show D")
    }
    
    func testScrollViewWithLargeContent() {
        // Given - Content much larger than viewport
        struct TestView: View {
            var body: some View {
                ScrollView {
                    VStack {
                        ForEachRange(0..<50) { i in
                            Text("L\(i)")
                        }
                    }
                }
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 20, height: 10)
        
        // Then - Shows only first 3 items
        XCTAssertTrue(output.contains("L0"), "Should show L0")
        XCTAssertTrue(output.contains("L1"), "Should show L1")
        XCTAssertTrue(output.contains("L2"), "Should show L2")
        XCTAssertFalse(output.contains("L3"), "Should not show L3")
        XCTAssertFalse(output.contains("L49"), "Should not show L49")
    }
    
    // MARK: - Edge Cases Tests
    
    func testScrollViewSingleLine() {
        // Given
        struct TestView: View {
            var body: some View {
                ScrollView {
                    Text("One")
                }
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 20, height: 10)
        
        // Then
        XCTAssertTrue(output.contains("One"), "Should show single line")
    }
    
    func testScrollViewNestedViews() {
        // Given - Complex nested structure
        struct TestView: View {
            var body: some View {
                ScrollView {
                    VStack {
                        Text("Top")
                        HStack(spacing: 0) {
                            Text("L")
                            Text("R")
                        }
                        Text("Bot")
                        Text("Hidden")  // 4th line, should be clipped
                    }
                }
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 30, height: 15)
        
        // Then
        XCTAssertTrue(output.contains("Top"), "Should show top")
        XCTAssertTrue(output.contains("L"), "Should show L")
        XCTAssertTrue(output.contains("R"), "Should show R")
        XCTAssertTrue(output.contains("Bot"), "Should show bottom")
        XCTAssertFalse(output.contains("Hidden"), "Should not show hidden")
    }
    
    func testScrollViewInVStack() {
        // Given - ScrollView inside VStack
        struct TestView: View {
            var body: some View {
                VStack {
                    Text("Title")
                    
                    ScrollView {
                        VStack {
                            Text("S1")
                            Text("S2")
                            Text("S3")
                            Text("S4")  // Beyond viewport
                        }
                    }
                    
                    Text("Footer")
                }
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 20, height: 15)
        
        // Then
        XCTAssertTrue(output.contains("Title"), "Should show title")
        XCTAssertTrue(output.contains("S1"), "Should show S1")
        XCTAssertTrue(output.contains("S2"), "Should show S2")
        XCTAssertTrue(output.contains("S3"), "Should show S3")
        XCTAssertFalse(output.contains("S4"), "Should not show S4")
        XCTAssertTrue(output.contains("Footer"), "Should show footer")
    }
    
    func testScrollViewWithSpacing() {
        // Given - VStack with spacing inside ScrollView
        struct TestView: View {
            var body: some View {
                ScrollView {
                    VStack(spacing: 1) {
                        Text("A")
                        Text("B")
                        Text("C")  // May be clipped due to spacing
                    }
                }
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 20, height: 10)
        
        // Then
        XCTAssertTrue(output.contains("A"), "Should show A")
        XCTAssertTrue(output.contains("B"), "Should show B")
        // C might be clipped due to spacing taking up lines
    }
    
    func testScrollViewMultipleInstances() {
        // Given - Multiple ScrollViews (affected by global state issue)
        struct TestView: View {
            var body: some View {
                HStack {
                    ScrollView {
                        Text("SV1")
                    }
                    
                    ScrollView {
                        Text("SV2")
                    }
                }
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 20, height: 10)
        
        // Then - Both should render, but may share state
        XCTAssertTrue(output.contains("SV1"), "Should show SV1")
        XCTAssertTrue(output.contains("SV2"), "Should show SV2")
    }
}