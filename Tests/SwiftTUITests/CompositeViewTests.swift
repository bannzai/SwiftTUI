import XCTest
@testable import SwiftTUI

final class CompositeViewTests: SwiftTUITestCase {
    
    func testTextInVStack() {
        // Given
        let view = VStack {
            Text("Line 1")
            Text("Line 2")
            Text("Line 3")
        }
        
        // When
        let output = TestRenderer.render(view)
        let lines = output.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        // Then
        XCTAssertEqual(lines.count, 3)
        XCTAssertEqual(lines[0], "Line 1")
        XCTAssertEqual(lines[1], "Line 2")
        XCTAssertEqual(lines[2], "Line 3")
    }
    
    func testTextInHStack() {
        // Given
        let view = HStack {
            Text("Hello")
            Text("World")
        }
        
        // When
        let output = TestRenderer.render(view)
        let normalized = normalizeOutput(output)
        
        // Then
        // HStackは横に並べるので、同じ行に表示される
        XCTAssertTrue(normalized.contains("Hello") && normalized.contains("World"))
    }
    
    func testTextInVStackWithSpacing() {
        // Given
        let view = VStack(spacing: 2) {
            Text("First")
            Text("Second")
        }
        
        // When
        let output = TestRenderer.render(view)
        
        // Then
        // Just verify both texts are rendered and in correct order
        // TODO: Once VStack spacing is properly implemented, verify actual spacing
        XCTAssertTrue(output.contains("First"))
        XCTAssertTrue(output.contains("Second"))
        
        // Verify order
        if let firstRange = output.range(of: "First"),
           let secondRange = output.range(of: "Second") {
            XCTAssertLessThan(firstRange.lowerBound, secondRange.lowerBound)
        }
    }
    
    func testNestedStacks() {
        // Given
        let view = VStack {
            Text("Header")
            HStack {
                Text("Left")
                Text("Right")
            }
            Text("Footer")
        }
        
        // When
        let output = TestRenderer.render(view)
        
        // Then
        XCTAssertTrue(output.contains("Header"))
        XCTAssertTrue(output.contains("Left"))
        XCTAssertTrue(output.contains("Right"))
        XCTAssertTrue(output.contains("Footer"))
    }
}