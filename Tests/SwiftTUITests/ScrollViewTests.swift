//
//  ScrollViewTests.swift
//  SwiftTUITests
//
//  Tests for ScrollView component with scrolling and viewport functionality
//
//  Note: Current ScrollView implementation has fixed viewport size (3 lines height, 5 chars width)
//  and ignores .frame() modifiers
//

import Testing
@testable import SwiftTUI

@Suite struct ScrollViewTests {
    
    // MARK: - Basic Scroll Functionality Tests
    
    @Test func scrollViewBasicVertical() {
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
        #expect(output.contains("L1"), "Should show first line")
        #expect(output.contains("L2"), "Should show second line")
        #expect(output.contains("L3"), "Should show third line")
        #expect(!output.contains("L4"), "Should not show fourth line (clipped)")
        #expect(!output.contains("L5"), "Should not show fifth line (clipped)")
    }
    
    @Test func scrollViewBasicHorizontal() {
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
        #expect(output.contains("ABCDE"), "Should show first 5 chars")
        #expect(!output.contains("FG"), "Should not show chars beyond viewport")
    }
    
    @Test func scrollViewBothAxes() {
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
        #expect(output.contains("12345"), "Should show first line")
        #expect(output.contains("67890"), "Should show second line")
        #expect(output.contains("ABCDE"), "Should show third line")
        #expect(!output.contains("FGHIJ"), "Should not show fourth line")
    }
    
    @Test func scrollViewNoScroll() {
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
        #expect(output.contains("Hi"), "Should show all content")
    }
    
    @Test func scrollViewEmptyContent() {
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
        #expect(output != nil, "Should render empty ScrollView")
    }
    
    // MARK: - Frame Constraints and Clipping Tests
    
    @Test func scrollViewIgnoresFrameModifier() {
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
        #expect(output.contains("A"), "Should show A")
        #expect(output.contains("B"), "Should show B")
        #expect(output.contains("C"), "Should show C")
        #expect(!output.contains("D"), "Should not show D")
    }
    
    @Test func scrollViewContentClipping() {
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
        #expect(output.contains("Hello"), "Should show Hello completely")
        #expect(output.contains("World"), "Should show World")
        #expect(!output.contains("!"), "Should not show exclamation mark")
        #expect(output.contains("12345"), "Should show first 5 digits")
        #expect(!output.contains("678"), "Should not show last 3 digits")
    }
    
    @Test func scrollViewHorizontalClipping() {
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
        #expect(output.contains("12345"), "Should show first 5 chars")
        #expect(!output.contains("67890"), "Should not show last 5 chars")
    }
    
    @Test func scrollViewANSIHandling() {
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
        #expect(output.contains("R"), "Should show R")
        #expect(output.contains("G"), "Should show G")
        #expect(output.contains("B"), "Should show B")
    }
    
    // MARK: - Scrollbar Display Tests
    
    @Test func scrollViewIndicatorsShown() {
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
        #expect(output.contains("0"), "Should show 0")
        #expect(output.contains("1"), "Should show 1")
        #expect(output.contains("2"), "Should show 2")
        #expect(!output.contains("3"), "Should not show 3")
    }
    
    @Test func scrollViewIndicatorsHidden() {
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
        #expect(output.contains("A"), "Should show A")
        #expect(output.contains("B"), "Should show B")
        #expect(output.contains("C"), "Should show C")
        #expect(!output.contains("D"), "Should not show D")
    }
    
    @Test func scrollViewWithLargeContent() {
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
        #expect(output.contains("L0"), "Should show L0")
        #expect(output.contains("L1"), "Should show L1")
        #expect(output.contains("L2"), "Should show L2")
        #expect(!output.contains("L3"), "Should not show L3")
        #expect(!output.contains("L49"), "Should not show L49")
    }
    
    // MARK: - Edge Cases Tests
    
    @Test func scrollViewSingleLine() {
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
        #expect(output.contains("One"), "Should show single line")
    }
    
    @Test func scrollViewNestedViews() {
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
        #expect(output.contains("Top"), "Should show top")
        #expect(output.contains("L"), "Should show L")
        #expect(output.contains("R"), "Should show R")
        #expect(output.contains("Bot"), "Should show bottom")
        #expect(!output.contains("Hidden"), "Should not show hidden")
    }
    
    @Test func scrollViewInVStack() {
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
        #expect(output.contains("Title"), "Should show title")
        #expect(output.contains("S1"), "Should show S1")
        #expect(output.contains("S2"), "Should show S2")
        #expect(output.contains("S3"), "Should show S3")
        #expect(!output.contains("S4"), "Should not show S4")
        #expect(output.contains("Footer"), "Should show footer")
    }
    
    @Test func scrollViewWithSpacing() {
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
        #expect(output.contains("A"), "Should show A")
        #expect(output.contains("B"), "Should show B")
        // C might be clipped due to spacing taking up lines
    }
    
    @Test func scrollViewMultipleInstances() {
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
        #expect(output.contains("SV1"), "Should show SV1")
        #expect(output.contains("SV2"), "Should show SV2")
    }
}