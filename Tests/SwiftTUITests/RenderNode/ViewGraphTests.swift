import XCTest
@testable import SwiftTUI

/// ViewGraphシステムのテスト
final class ViewGraphTests: XCTestCase {
  
  // MARK: - Basic Tests
  
  /// ViewGraphの基本的な初期化テスト
  func testViewGraphInitialization() {
    // Given & When
    let graph = ViewGraph()
    
    // Then
    XCTAssertNotNil(graph)
    XCTAssertTrue(graph.needsRedraw)
  }
  
  /// ルートViewの設定テスト
  func testSetRootView() {
    // Given
    let graph = ViewGraph()
    let view = Text("Test")
    
    // When
    graph.setRootView(view)
    
    // Then
    XCTAssertTrue(graph.needsRedraw)
  }
  
  /// 環境値の更新テスト
  func testEnvironmentUpdate() {
    // Given
    let graph = ViewGraph()
    var environment = EnvironmentValues()
    
    // When
    graph.updateEnvironment(environment)
    
    // Then
    XCTAssertTrue(graph.needsRedraw)
  }
  
  /// フォーカス状態の更新テスト
  func testFocusStateUpdate() {
    // Given
    let graph = ViewGraph()
    let focusState = FocusState()
    
    // When
    graph.updateFocusState(focusState)
    
    // Then
    XCTAssertTrue(graph.needsRedraw)
  }
  
  // MARK: - Rendering Tests
  
  /// 基本的なレンダリングテスト
  func testBasicRendering() {
    // Given
    let graph = ViewGraph()
    let view = Text("Hello, ViewGraph!")
    graph.setRootView(view)
    
    var buffer = CellBuffer(width: 40, height: 10)
    
    // When
    graph.render(into: &buffer)
    
    // Then
    XCTAssertFalse(graph.needsRedraw) // レンダリング後はfalseになる
    
    // バッファに何か描画されていることを確認
    let hasContent = (0..<buffer.height).contains { row in
      (0..<buffer.width).contains { col in
        if let cell = buffer.getCell(row: row, col: col) {
          return cell.character != " "
        }
        return false
      }
    }
    XCTAssertTrue(hasContent)
  }
  
  /// 複数回のレンダリングテスト
  func testMultipleRenders() {
    // Given
    let graph = ViewGraph()
    let view = Text("Test")
    graph.setRootView(view)
    
    var buffer1 = CellBuffer(width: 20, height: 5)
    var buffer2 = CellBuffer(width: 20, height: 5)
    
    // When
    graph.render(into: &buffer1)
    graph.render(into: &buffer2) // 2回目のレンダリング
    
    // Then
    // 2回目のレンダリングでも同じ結果になることを確認
    // （状態が変わっていないため）
    XCTAssertFalse(graph.needsRedraw)
  }
  
  /// 再レンダリング要求のテスト
  func testSetNeedsRender() {
    // Given
    let graph = ViewGraph()
    let view = Text("Test")
    graph.setRootView(view)
    
    var buffer = CellBuffer(width: 20, height: 5)
    graph.render(into: &buffer)
    
    // When
    XCTAssertFalse(graph.needsRedraw) // レンダリング後はfalse
    graph.setNeedsRender()
    
    // Then
    XCTAssertTrue(graph.needsRedraw)
  }
  
  // MARK: - Integration Tests
  
  /// VStackを含むViewGraphのテスト
  func testViewGraphWithVStack() {
    // Given
    let graph = ViewGraph()
    let view = VStack {
      Text("Line 1")
      Text("Line 2")
      Text("Line 3")
    }
    graph.setRootView(view)
    
    var buffer = CellBuffer(width: 40, height: 10)
    
    // When
    graph.render(into: &buffer)
    
    // Then
    // 複数行のコンテンツが描画されることを確認
    var nonEmptyRows = 0
    for row in 0..<buffer.height {
      let rowText = extractText(from: buffer, at: row)
      if !rowText.isEmpty {
        nonEmptyRows += 1
      }
    }
    XCTAssertGreaterThan(nonEmptyRows, 1)
  }
  
  /// HStackを含むViewGraphのテスト
  func testViewGraphWithHStack() {
    // Given
    let graph = ViewGraph()
    let view = HStack(spacing: 2) {
      Text("Left")
      Text("Right")
    }
    graph.setRootView(view)
    
    var buffer = CellBuffer(width: 40, height: 10)
    
    // When
    graph.render(into: &buffer)
    
    // Then
    // 水平方向にコンテンツが配置されることを確認
    let firstRowText = extractText(from: buffer, at: 0)
    XCTAssertTrue(firstRowText.contains("Left") || firstRowText.contains("Right"))
  }
  
  // MARK: - Debug Tests
  
  /// デバッグ情報の出力テスト
  func testDebugPrint() {
    // Given
    let graph = ViewGraph()
    let view = VStack {
      Text("Debug Test")
    }
    graph.setRootView(view)
    
    var buffer = CellBuffer(width: 40, height: 10)
    graph.render(into: &buffer)
    
    // When & Then
    // デバッグ情報の出力が例外を投げないことを確認
    graph.debugPrint()
  }
  
  /// 強制再構築のテスト
  func testInvalidate() {
    // Given
    let graph = ViewGraph()
    let view = Text("Test")
    graph.setRootView(view)
    
    var buffer = CellBuffer(width: 20, height: 5)
    graph.render(into: &buffer)
    
    // When
    XCTAssertFalse(graph.needsRedraw)
    graph.invalidate()
    
    // Then
    XCTAssertTrue(graph.needsRedraw)
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