import XCTest
@testable import SwiftTUI

/// RenderNodeシステムの基本的なテスト
final class RenderNodeTests: XCTestCase {
  
  // MARK: - RenderNode Base Tests
  
  /// 基本的なRenderNodeの作成と初期化をテスト
  func testRenderNodeInitialization() {
    // Given
    let attributes = RenderAttributes(
      foregroundColor: .green,
      bold: true
    )
    
    // When
    let node = RenderNode(attributes: attributes)
    
    // Then
    XCTAssertNotNil(node.id)
    XCTAssertEqual(node.frame, .zero)
    XCTAssertEqual(node.children.count, 0)
    XCTAssertEqual(node.attributes.foregroundColor, .green)
    XCTAssertTrue(node.attributes.bold)
  }
  
  /// 子ノードの追加と削除をテスト
  func testChildManagement() {
    // Given
    let parent = RenderNode()
    let child1 = RenderNode()
    let child2 = RenderNode()
    
    // When - 子ノードを追加
    parent.addChild(child1)
    parent.addChild(child2)
    
    // Then
    XCTAssertEqual(parent.children.count, 2)
    XCTAssertTrue(parent.children.contains { $0.id == child1.id })
    XCTAssertTrue(parent.children.contains { $0.id == child2.id })
    
    // When - 子ノードを削除
    parent.removeChild(child1)
    
    // Then
    XCTAssertEqual(parent.children.count, 1)
    XCTAssertFalse(parent.children.contains { $0.id == child1.id })
    XCTAssertTrue(parent.children.contains { $0.id == child2.id })
    
    // When - すべての子ノードを削除
    parent.removeAllChildren()
    
    // Then
    XCTAssertEqual(parent.children.count, 0)
  }
  
  /// レイアウト計算の基本テスト
  func testLayoutCalculation() {
    // Given
    let node = RenderNode()
    let constraints = LayoutConstraints(maxWidth: 80, maxHeight: 24)
    
    // When
    node.layout(constraints: constraints)
    
    // Then
    // フレームが設定されることを確認
    XCTAssertGreaterThanOrEqual(node.frame.width, 0)
    XCTAssertGreaterThanOrEqual(node.frame.height, 0)
  }
  
  // MARK: - TextRenderNode Tests
  
  /// TextRenderNodeの基本テスト
  func testTextRenderNode() {
    // Given
    let text = "Hello, World!"
    let attributes = RenderAttributes(
      foregroundColor: .blue,
      bold: true
    )
    let textNode = TextRenderNode(text: text, attributes: attributes)
    
    // When
    let constraints = LayoutConstraints(maxWidth: 80, maxHeight: 24)
    textNode.layout(constraints: constraints)
    
    // Then
    XCTAssertEqual(textNode.text, text)
    XCTAssertEqual(textNode.attributes.foregroundColor, .blue)
    XCTAssertTrue(textNode.attributes.bold)
    XCTAssertGreaterThan(textNode.frame.width, 0)
    XCTAssertGreaterThan(textNode.frame.height, 0)
  }
  
  /// TextRenderNodeのレンダリングテスト
  func testTextRenderNodeRendering() {
    // Given
    let text = "Test"
    let textNode = TextRenderNode(text: text)
    var buffer = CellBuffer(width: 20, height: 5)
    
    // レイアウトを計算
    textNode.layout(constraints: LayoutConstraints(maxWidth: 20, maxHeight: 5))
    
    // When
    textNode.render(into: &buffer)
    
    // Then
    // バッファに文字が書き込まれていることを確認
    let renderedText = extractText(from: buffer, at: 0)
    XCTAssertTrue(renderedText.contains(text))
  }
  
  /// 日本語テキストのレンダリングテスト
  func testTextRenderNodeJapanese() {
    // Given
    let text = "こんにちは"
    let textNode = TextRenderNode(text: text)
    var buffer = CellBuffer(width: 20, height: 5)
    
    // レイアウトを計算
    textNode.layout(constraints: LayoutConstraints(maxWidth: 20, maxHeight: 5))
    
    // When
    textNode.render(into: &buffer)
    
    // Then
    let renderedText = extractText(from: buffer, at: 0)
    XCTAssertTrue(renderedText.contains(text))
  }
  
  // MARK: - Stack Tests
  
  /// VStackRenderNodeの基本テスト
  func testVStackRenderNode() {
    // Given
    let vstack = VStackRenderNode(spacing: 1, alignment: .leading)
    let text1 = TextRenderNode(text: "Line 1")
    let text2 = TextRenderNode(text: "Line 2")
    
    // When
    vstack.addChild(text1)
    vstack.addChild(text2)
    
    let constraints = LayoutConstraints(maxWidth: 80, maxHeight: 24)
    vstack.layout(constraints: constraints)
    
    // Then
    XCTAssertEqual(vstack.children.count, 2)
    XCTAssertEqual(vstack.spacing, 1)
    XCTAssertEqual(vstack.alignment, .leading)
    
    // 子要素が垂直に配置されることを確認
    XCTAssertLessThan(text1.frame.y, text2.frame.y)
  }
  
  /// HStackRenderNodeの基本テスト
  func testHStackRenderNode() {
    // Given
    let hstack = HStackRenderNode(spacing: 2, alignment: .center)
    let text1 = TextRenderNode(text: "Left")
    let text2 = TextRenderNode(text: "Right")
    
    // When
    hstack.addChild(text1)
    hstack.addChild(text2)
    
    let constraints = LayoutConstraints(maxWidth: 80, maxHeight: 24)
    hstack.layout(constraints: constraints)
    
    // Then
    XCTAssertEqual(hstack.children.count, 2)
    XCTAssertEqual(hstack.spacing, 2)
    XCTAssertEqual(hstack.alignment, .center)
    
    // 子要素が水平に配置されることを確認
    XCTAssertLessThan(text1.frame.x, text2.frame.x)
  }
  
  // MARK: - Diff Tests
  
  /// 差分計算の基本テスト
  func testRenderNodeDiff() {
    // Given
    let node1 = RenderNode()
    node1.frame = Frame(x: 0, y: 0, width: 10, height: 5)
    
    let node2 = RenderNode()
    node2.frame = Frame(x: 5, y: 5, width: 10, height: 5)
    
    // When
    let patches = node2.diff(with: node1)
    
    // Then
    XCTAssertFalse(patches.isEmpty)
    
    // フレーム変更パッチが含まれることを確認
    let hasFrameChange = patches.contains { patch in
      if case .frameChanged = patch {
        return true
      }
      return false
    }
    XCTAssertTrue(hasFrameChange)
  }
  
  /// 属性変更の差分テスト
  func testAttributesDiff() {
    // Given
    var attributes1 = RenderAttributes()
    attributes1.foregroundColor = .red
    let node1 = RenderNode(attributes: attributes1)
    
    var attributes2 = RenderAttributes()
    attributes2.foregroundColor = .blue
    let node2 = RenderNode(attributes: attributes2)
    
    // IDを同じにするためのハック（テスト用）
    // 実際の使用では同じノードの異なる状態を比較
    
    // When
    let patches = node2.diff(with: node1)
    
    // Then
    XCTAssertFalse(patches.isEmpty)
  }
  
  // MARK: - Helper Methods
  
  /// CellBufferから指定行のテキストを抽出
  private func extractText(from buffer: CellBuffer, at row: Int) -> String {
    var text = ""
    for col in 0..<buffer.width {
      if let cell = buffer.getCell(row: row, col: col) {
        text.append(cell.character)
      }
    }
    return text.trimmingCharacters(in: .whitespaces)
  }
}