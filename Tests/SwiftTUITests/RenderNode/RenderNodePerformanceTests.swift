import XCTest
@testable import SwiftTUI

/// RenderNodeシステムのパフォーマンステスト
final class RenderNodePerformanceTests: XCTestCase {
  
  // MARK: - Layout Performance Tests
  
  /// 大量のノードのレイアウト計算パフォーマンス
  func testLargeTreeLayoutPerformance() {
    // Given
    let rootNode = createLargeNodeTree(depth: 5, childrenPerNode: 3)
    let constraints = LayoutConstraints(maxWidth: 100, maxHeight: 100)
    
    // When & Then
    measure {
      rootNode.layout(constraints: constraints)
    }
  }
  
  /// 深いネストのレイアウト計算パフォーマンス
  func testDeepNestingLayoutPerformance() {
    // Given
    let rootNode = createDeepNestedNodes(depth: 20)
    let constraints = LayoutConstraints(maxWidth: 100, maxHeight: 100)
    
    // When & Then
    measure {
      rootNode.layout(constraints: constraints)
    }
  }
  
  // MARK: - Rendering Performance Tests
  
  /// 大量のテキストノードのレンダリングパフォーマンス
  func testManyTextNodesRenderingPerformance() {
    // Given
    let vstack = VStackRenderNode()
    for i in 0..<100 {
      vstack.addChild(TextRenderNode(text: "Line \(i): This is a test text"))
    }
    
    var buffer = CellBuffer(width: 80, height: 200)
    let constraints = LayoutConstraints(maxWidth: 80, maxHeight: 200)
    vstack.layout(constraints: constraints)
    
    // When & Then
    measure {
      vstack.render(into: &buffer)
    }
  }
  
  /// 日本語テキストのレンダリングパフォーマンス
  func testJapaneseTextRenderingPerformance() {
    // Given
    let vstack = VStackRenderNode()
    let japaneseTexts = [
      "これはテストです",
      "日本語の文字幅計算",
      "パフォーマンステスト",
      "絵文字も含む😀テスト",
      "全角半角ﾐｯｸｽのテスト"
    ]
    
    for _ in 0..<20 {
      for text in japaneseTexts {
        vstack.addChild(TextRenderNode(text: text))
      }
    }
    
    var buffer = CellBuffer(width: 80, height: 100)
    let constraints = LayoutConstraints(maxWidth: 80, maxHeight: 100)
    vstack.layout(constraints: constraints)
    
    // When & Then
    measure {
      vstack.render(into: &buffer)
    }
  }
  
  // MARK: - Diff Performance Tests
  
  /// 差分計算のパフォーマンス
  func testDiffCalculationPerformance() {
    // Given
    let oldTree = createLargeNodeTree(depth: 4, childrenPerNode: 4)
    let newTree = createLargeNodeTree(depth: 4, childrenPerNode: 4)
    
    // 一部のノードを変更
    modifyRandomNodes(in: newTree, changeRatio: 0.3)
    
    // When & Then
    measure {
      _ = newTree.diff(with: oldTree)
    }
  }
  
  /// パッチ適用のパフォーマンス
  func testPatchApplicationPerformance() {
    // Given
    var buffer = CellBuffer(width: 100, height: 100)
    let patches = createManyPatches(count: 1000)
    let nodeMap: [ObjectIdentifier: RenderNode] = [:]
    
    // When & Then
    measure {
      RenderPatchApplier.apply(patches: patches, to: &buffer, nodeMap: nodeMap)
    }
  }
  
  /// パッチ最適化のパフォーマンス
  func testPatchOptimizationPerformance() {
    // Given
    let patches = createManyPatches(count: 5000)
    
    // When & Then
    measure {
      _ = RenderPatchOptimizer.optimize(patches)
    }
  }
  
  // MARK: - ViewGraph Performance Tests
  
  /// ViewGraphの完全レンダリングパフォーマンス
  func testViewGraphFullRenderPerformance() {
    // Given
    let graph = ViewGraph()
    let complexView = createComplexView()
    graph.setRootView(complexView)
    
    var buffer = CellBuffer(width: 120, height: 50)
    
    // When & Then
    measure {
      graph.render(into: &buffer)
    }
  }
  
  /// ViewGraphの差分レンダリングパフォーマンス
  func testViewGraphDiffRenderPerformance() {
    // Given
    let graph = ViewGraph()
    let view = createComplexView()
    graph.setRootView(view)
    
    var buffer = CellBuffer(width: 120, height: 50)
    
    // 初回レンダリング
    graph.render(into: &buffer)
    
    // When & Then - 2回目以降のレンダリング（差分適用）
    measure {
      graph.setNeedsRender()
      graph.render(into: &buffer)
    }
  }
  
  // MARK: - Helper Methods
  
  /// 大きなノードツリーを作成
  private func createLargeNodeTree(depth: Int, childrenPerNode: Int) -> RenderNode {
    func createSubtree(currentDepth: Int) -> RenderNode {
      if currentDepth >= depth {
        return TextRenderNode(text: "Leaf \(currentDepth)")
      }
      
      let node = VStackRenderNode()
      for i in 0..<childrenPerNode {
        node.addChild(createSubtree(currentDepth: currentDepth + 1))
      }
      return node
    }
    
    return createSubtree(currentDepth: 0)
  }
  
  /// 深くネストされたノードを作成
  private func createDeepNestedNodes(depth: Int) -> RenderNode {
    var current: RenderNode = TextRenderNode(text: "Deepest")
    
    for i in 0..<depth {
      let parent = VStackRenderNode()
      parent.addChild(current)
      current = parent
    }
    
    return current
  }
  
  /// ランダムにノードを変更
  private func modifyRandomNodes(in node: RenderNode, changeRatio: Double) {
    if Double.random(in: 0...1) < changeRatio {
      // 属性を変更
      node.attributes.foregroundColor = [.red, .green, .blue, .yellow].randomElement()
      node.attributes.bold = Bool.random()
    }
    
    // 子ノードも再帰的に変更
    for child in node.children {
      modifyRandomNodes(in: child, changeRatio: changeRatio)
    }
  }
  
  /// 多数のパッチを作成
  private func createManyPatches(count: Int) -> [RenderPatch] {
    var patches: [RenderPatch] = []
    
    for i in 0..<count {
      let x = i % 100
      let y = i / 100
      
      switch i % 5 {
      case 0:
        patches.append(.cellChanged(
          x: x,
          y: y,
          from: Cell(character: " "),
          to: Cell(character: "X")
        ))
      case 1:
        let id = ObjectIdentifier(NSObject()) // ダミーID
        patches.append(.frameChanged(
          id: id,
          from: Frame(x: 0, y: 0, width: 10, height: 10),
          to: Frame(x: 5, y: 5, width: 15, height: 15)
        ))
      case 2:
        let id = ObjectIdentifier(NSObject())
        patches.append(.attributesChanged(
          id: id,
          from: RenderAttributes(),
          to: RenderAttributes(foregroundColor: .red)
        ))
      case 3:
        let id = ObjectIdentifier(NSObject())
        patches.append(.childrenChanged(id: id))
      default:
        let id = ObjectIdentifier(NSObject())
        patches.append(.contentChanged(id: id))
      }
    }
    
    return patches
  }
  
  /// 複雑なViewを作成
  private func createComplexView() -> some View {
    VStack(spacing: 1) {
      Text("Header").bold()
      
      HStack(spacing: 2) {
        Text("Label:")
        Text("Value").foregroundColor(.green)
      }
      
      VStack {
        ForEach(0..<10) { i in
          HStack {
            Text("Item \(i)")
            Spacer()
            Text("Status").foregroundColor(.yellow)
          }
        }
      }
      
      Text("Footer").padding()
    }
  }
}