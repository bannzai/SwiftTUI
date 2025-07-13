import Testing
@testable import SwiftTUI

@Suite struct TextTests {
    
    @Test func textBasic() {
        // Given
        let text = Text("Hello, World")
        
        // When
        let output = TestRenderer.render(text)
        
        // Then
        expectRenderedOutput(text, equals: "Hello, World")
    }
    
    @Test func textWithExclamation() {
        // Given
        let text = Text("Hello, World!")
        
        // When
        let output = TestRenderer.render(text)
        
        // Then
        expectRenderedOutput(text, equals: "Hello, World!")
    }
    
    @Test func textWithStringInterpolation() {
        // Given
        let name = "SwiftTUI"
        let text = Text("Welcome to \(name)!")
        
        // When
        let output = TestRenderer.render(text)
        
        // Then
        expectRenderedOutput(text, equals: "Welcome to SwiftTUI!")
    }
    
    @Test func textEmpty() {
        // Given
        let text = Text("")
        
        // When
        let output = TestRenderer.render(text)
        
        // Then
        expectRenderedOutput(text, equals: "")
    }
    
    @Test func textWithSpecialCharacters() {
        // Given
        let text = Text("Hello @#$%^&*()!")
        
        // When
        let output = TestRenderer.render(text)
        
        // Then
        expectRenderedOutput(text, equals: "Hello @#$%^&*()!")
    }
    
    @Test func textWithUnicode() {
        // Given
        let text = Text("こんにちは 👋")
        
        // When
        let output = TestRenderer.render(text)
        
        // Then
        expectRenderedOutput(text, equals: "こんにちは 👋")
    }
    
    @Test func textWithNewlines() {
        // Given
        let text = Text("Line 1\nLine 2")
        
        // When
        let output = TestRenderer.render(text)
        
        // Then
        // Note: Text viewは改行を含む場合、1行として表示される
        expectRenderedOutput(text, equals: "Line 1\nLine 2")
    }
}