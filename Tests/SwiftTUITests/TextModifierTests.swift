import Testing
@testable import SwiftTUI

@Suite struct TextModifierTests {
    
    @Test func textWithPadding() {
        // Given
        let text = Text("Hello").padding()
        
        // When
        let output = TestRenderer.render(text)
        
        // Then
        // paddingは周りに空白を追加するが、normalizeOutputで除去される
        expectRenderedOutput(text, equals: "Hello")
    }
    
    @Test func textWithBorder() {
        // Given
        let text = Text("Hello").border()
        
        // When
        let output = TestRenderer.render(text, width: 20)
        let normalized = normalizeOutput(output)
        
        // Then
        // ボーダーは特殊文字で描画される
        #expect(normalized.contains("┌") && normalized.contains("┐"))
        #expect(normalized.contains("└") && normalized.contains("┘"))
        #expect(normalized.contains("Hello"))
    }
    
    @Test func textWithPaddingAndBorder() {
        // Given
        let text = Text("Hello").padding().border()
        
        // When
        let output = TestRenderer.render(text, width: 20)
        
        // Then
        // パディングとボーダーが適用される
        #expect(output.contains("Hello"))
    }
    
    @Test func textWithForegroundColor() {
        // Given
        let text = Text("Colored Text").foregroundColor(.green)
        
        // When
        let output = TestRenderer.render(text)
        
        // Then
        // ANSIエスケープシーケンスは除去されるので、テキストのみが残る
        expectRenderedOutput(text, equals: "Colored Text")
    }
    
    @Test func textBold() {
        // Given
        let text = Text("Bold Text").bold()
        
        // When
        let output = TestRenderer.render(text)
        
        // Then
        // boldスタイルはANSIエスケープシーケンスで実装されるため、除去後はテキストのみ
        expectRenderedOutput(text, equals: "Bold Text")
    }
    
    @Test func textChainedModifiers() {
        // Given
        let text = Text("Styled")
            .bold()
            .foregroundColor(.red)
            .padding()
        
        // When
        let output = TestRenderer.render(text)
        
        // Then
        expectRenderedOutput(text, equals: "Styled")
    }
}