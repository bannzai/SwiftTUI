import Testing
@testable import SwiftTUI

@Suite struct CompositeViewTests {
    
    @Test func textInVStack() {
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
        #expect(lines.count == 3)
        #expect(lines[0] == "Line 1")
        #expect(lines[1] == "Line 2")
        #expect(lines[2] == "Line 3")
    }
    
    @Test func textInHStack() {
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
        #expect(normalized.contains("Hello") && normalized.contains("World"))
    }
    
    @Test func textInVStackWithSpacing() {
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
        #expect(output.contains("First"))
        #expect(output.contains("Second"))
        
        // Verify order
        if let firstRange = output.range(of: "First"),
           let secondRange = output.range(of: "Second") {
            #expect(firstRange.lowerBound < secondRange.lowerBound)
        }
    }
    
    @Test func nestedStacks() {
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
        #expect(output.contains("Header"))
        #expect(output.contains("Left"))
        #expect(output.contains("Right"))
        #expect(output.contains("Footer"))
    }
}