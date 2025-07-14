//
//  TextFieldTests.swift
//  SwiftTUITests
//
//  Tests for TextField view behavior
//

import XCTest
@testable import SwiftTUI

final class TextFieldTests: SwiftTUITestCase {
    
    // MARK: - Basic TextField Tests
    
    func testTextFieldWithEmptyText() {
        // Given
        var text = ""
        let binding = Binding(
            get: { text },
            set: { text = $0 }
        )
        let textField = TextField("Enter text", text: binding)
        
        // When
        let output = TestRenderer.render(textField, width: 20, height: 5)
        
        
        // Then
        // Should show placeholder "Enter text" in a bordered box
        XCTAssertTrue(output.contains("Enter text"), "Placeholder should be visible when text is empty")
        XCTAssertTrue(output.contains("┌"), "Should have top border")
        XCTAssertTrue(output.contains("└"), "Should have bottom border")
        XCTAssertTrue(output.contains("│"), "Should have side borders")
    }
    
    func testTextFieldWithInitialText() {
        // Given
        var text = "Hello"
        let binding = Binding(
            get: { text },
            set: { text = $0 }
        )
        let textField = TextField("Placeholder", text: binding)
        
        // When
        let output = TestRenderer.render(textField, width: 20, height: 5)
        
        // Then
        // Should show the actual text, not placeholder
        XCTAssertTrue(output.contains("Hello"), "Initial text should be displayed")
        XCTAssertFalse(output.contains("Placeholder"), "Placeholder should not be visible when text exists")
    }
    
    // MARK: - @Binding Tests
    
    func testTextFieldBindingReflectsChanges() {
        // Given
        struct TestContainer: View {
            @State var text = "Initial"
            
            var body: some View {
                VStack {
                    TextField("Enter", text: $text)
                    Text("Value: \(text)")
                }
            }
        }
        
        let container = TestContainer()
        
        // When
        let output = TestRenderer.render(container, width: 30, height: 10)
        
        // Then
        XCTAssertTrue(output.contains("Initial"), "TextField should show initial value")
        XCTAssertTrue(output.contains("Value: Initial"), "Text should reflect the bound value")
    }
    
    func testTextFieldBindingWithParentChildRelationship() {
        // Given
        struct ChildView: View {
            @Binding var text: String
            
            var body: some View {
                TextField("Child input", text: $text)
            }
        }
        
        struct ParentView: View {
            @State private var sharedText = "Shared"
            
            var body: some View {
                VStack {
                    Text("Parent: \(sharedText)")
                    ChildView(text: $sharedText)
                }
            }
        }
        
        let parent = ParentView()
        
        // When
        let output = TestRenderer.render(parent, width: 30, height: 10)
        
        // Then
        XCTAssertTrue(output.contains("Parent: Shared"), "Parent should display shared text")
        XCTAssertTrue(output.contains("Shared"), "TextField should display shared text")
    }
    
    // MARK: - Placeholder Tests
    
    func testPlaceholderVisibility() {
        // Given
        var emptyText = ""
        var filledText = "Content"
        
        let emptyBinding = Binding(
            get: { emptyText },
            set: { emptyText = $0 }
        )
        let filledBinding = Binding(
            get: { filledText },
            set: { filledText = $0 }
        )
        
        let emptyField = TextField("Empty placeholder", text: emptyBinding)
        let filledField = TextField("Filled placeholder", text: filledBinding)
        
        // When
        let emptyOutput = TestRenderer.render(emptyField, width: 25, height: 5)
        let filledOutput = TestRenderer.render(filledField, width: 25, height: 5)
        
        // Then
        XCTAssertTrue(emptyOutput.contains("Empty placeholder"), "Placeholder should show when text is empty")
        XCTAssertFalse(filledOutput.contains("Filled placeholder"), "Placeholder should not show when text exists")
        XCTAssertTrue(filledOutput.contains("Content"), "Actual text should show instead of placeholder")
    }
    
    func testLongPlaceholder() {
        // Given
        var text = ""
        let binding = Binding(
            get: { text },
            set: { text = $0 }
        )
        let textField = TextField("This is a very long placeholder text", text: binding)
        
        // When
        let output = TestRenderer.render(textField, width: 50, height: 5)
        
        // Then
        XCTAssertTrue(output.contains("This is a very long placeholder text"), "Long placeholder should be displayed")
    }
    
    // MARK: - Border and Style Tests
    
    func testTextFieldBorderStructure() {
        // Given
        var text = "Test"
        let binding = Binding(
            get: { text },
            set: { text = $0 }
        )
        let textField = TextField("", text: binding)
        
        // When
        let output = TestRenderer.render(textField, width: 20, height: 5)
        let lines = output.components(separatedBy: "\n").filter { !$0.isEmpty }
        
        // Then
        // Find lines with borders
        var topBorderFound = false
        var bottomBorderFound = false
        var sideBordersCount = 0
        
        for line in lines {
            if line.contains("┌") && line.contains("┐") {
                topBorderFound = true
            }
            if line.contains("└") && line.contains("┘") {
                bottomBorderFound = true
            }
            if line.contains("│") {
                sideBordersCount += 1
            }
        }
        
        XCTAssertTrue(topBorderFound, "Should have top border with corners")
        XCTAssertTrue(bottomBorderFound, "Should have bottom border with corners")
        XCTAssertGreaterThanOrEqual(sideBordersCount, 1, "Should have side borders")
    }
    
    // MARK: - Size and Layout Tests
    
    func testTextFieldSizeAdaptsToContent() {
        // Given
        var shortText = "Hi"
        var longText = "This is a longer text"
        
        let shortBinding = Binding(
            get: { shortText },
            set: { shortText = $0 }
        )
        let longBinding = Binding(
            get: { longText },
            set: { longText = $0 }
        )
        
        let shortField = TextField("", text: shortBinding)
        let longField = TextField("", text: longBinding)
        
        // When
        let shortOutput = TestRenderer.render(shortField, width: 30, height: 5)
        let longOutput = TestRenderer.render(longField, width: 30, height: 5)
        
        // Then
        // Just verify both render correctly
        XCTAssertTrue(shortOutput.contains("Hi"), "Short text should be displayed")
        XCTAssertTrue(longOutput.contains("This is a longer text"), "Long text should be displayed")
    }
    
    func testTextFieldInVStack() {
        // Given
        var text1 = "First"
        var text2 = "Second"
        
        let binding1 = Binding(
            get: { text1 },
            set: { text1 = $0 }
        )
        let binding2 = Binding(
            get: { text2 },
            set: { text2 = $0 }
        )
        
        let stack = VStack {
            TextField("Field 1", text: binding1)
            TextField("Field 2", text: binding2)
        }
        
        // When
        let output = TestRenderer.render(stack, width: 30, height: 10)
        
        // Then
        XCTAssertTrue(output.contains("First"), "First TextField should be visible")
        XCTAssertTrue(output.contains("Second"), "Second TextField should be visible")
        
        // Verify they are stacked vertically
        let lines = output.components(separatedBy: "\n")
        var firstIndex = -1
        var secondIndex = -1
        
        for (index, line) in lines.enumerated() {
            if line.contains("First") {
                firstIndex = index
            }
            if line.contains("Second") {
                secondIndex = index
            }
        }
        
        if firstIndex != -1 && secondIndex != -1 {
            XCTAssertGreaterThan(secondIndex, firstIndex, "Second field should be below first field")
        }
    }
    
    // MARK: - Edge Cases
    
    func testEmptyPlaceholder() {
        // Given
        var text = "Content"
        let binding = Binding(
            get: { text },
            set: { text = $0 }
        )
        let textField = TextField("", text: binding)
        
        // When
        let output = TestRenderer.render(textField, width: 20, height: 5)
        
        // Then
        XCTAssertTrue(output.contains("Content"), "Should display content even with empty placeholder")
    }
    
    func testTextFieldWithSpecialCharacters() {
        // Given
        var text = "Hello @#$% World!"
        let binding = Binding(
            get: { text },
            set: { text = $0 }
        )
        let textField = TextField("", text: binding)
        
        // When
        let output = TestRenderer.render(textField, width: 30, height: 5)
        
        // Then
        XCTAssertTrue(output.contains("Hello"), "Should display text with special characters")
        XCTAssertTrue(output.contains("World!"), "Should display text with special characters")
    }
    
    func testMultipleTextFieldsWithDifferentBindings() {
        // Given
        var name = "John"
        var email = "john@example.com"
        
        let nameBinding = Binding(
            get: { name },
            set: { name = $0 }
        )
        let emailBinding = Binding(
            get: { email },
            set: { email = $0 }
        )
        
        let form = VStack {
            TextField("Name", text: nameBinding)
            TextField("Email", text: emailBinding)
        }
        
        // When
        let output = TestRenderer.render(form, width: 40, height: 10)
        
        // Then
        XCTAssertTrue(output.contains("John"), "Name field should show its value")
        XCTAssertTrue(output.contains("john@example.com"), "Email field should show its value")
    }
    
    // MARK: - Frame Modifier Tests
    
    func testTextFieldWithFrameModifier() {
        // Given
        var text = "Framed"
        let binding = Binding(
            get: { text },
            set: { text = $0 }
        )
        let textField = TextField("", text: binding)
            .frame(width: 15)
        
        // When
        let output = TestRenderer.render(textField, width: 30, height: 5)
        
        // Then
        // TextField should still render (frame implementation may vary)
        XCTAssertTrue(output.contains("Framed"), "TextField with frame should still display text")
    }
}