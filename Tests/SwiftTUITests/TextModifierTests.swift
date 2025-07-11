import XCTest
@testable import SwiftTUI

final class TextModifierTests: SwiftTUITestCase {
    
    func testTextWithPadding() {
        // Given
        let text = Text("Hello").padding()
        
        // When
        let output = TestRenderer.render(text)
        
        // Then
        // paddingは周りに空白を追加するが、normalizeOutputで除去される
        assertRenderedOutput(text, equals: "Hello")
    }
    
    func testTextWithBorder() {
        // Given
        let text = Text("Hello").border()
        
        // When
        let output = TestRenderer.render(text, width: 20)
        let normalized = normalizeOutput(output)
        
        // Then
        // ボーダーは特殊文字で描画される
        XCTAssertTrue(normalized.contains("┌") && normalized.contains("┐"))
        XCTAssertTrue(normalized.contains("└") && normalized.contains("┘"))
        XCTAssertTrue(normalized.contains("Hello"))
    }
    
    func testTextWithPaddingAndBorder() {
        // Given
        let text = Text("Hello").padding().border()
        
        // When
        let output = TestRenderer.render(text, width: 20)
        
        // Then
        // パディングとボーダーが適用される
        XCTAssertTrue(output.contains("Hello"))
    }
    
    func testTextWithForegroundColor() {
        // Given
        let text = Text("Colored Text").foregroundColor(.green)
        
        // When
        let output = TestRenderer.render(text)
        
        // Then
        // ANSIエスケープシーケンスは除去されるので、テキストのみが残る
        assertRenderedOutput(text, equals: "Colored Text")
    }
    
    func testTextBold() {
        // Given
        let text = Text("Bold Text").bold()
        
        // When
        let output = TestRenderer.render(text)
        
        // Then
        // boldスタイルはANSIエスケープシーケンスで実装されるため、除去後はテキストのみ
        assertRenderedOutput(text, equals: "Bold Text")
    }
    
    func testTextChainedModifiers() {
        // Given
        let text = Text("Styled")
            .bold()
            .foregroundColor(.red)
            .padding()
        
        // When
        let output = TestRenderer.render(text)
        
        // Then
        assertRenderedOutput(text, equals: "Styled")
    }
}