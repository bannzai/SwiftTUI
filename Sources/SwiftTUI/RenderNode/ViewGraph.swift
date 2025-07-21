/// ViewGraph：レンダリングノードのグラフ管理システム
///
/// このクラスは、SwiftTUIの新アーキテクチャにおける中心的な役割を果たします。
/// すべてのRenderNodeを管理し、効率的な差分レンダリングを実現します。
///
/// 主な責任：
/// - RenderNodeツリーの構築と管理
/// - 状態変更の検出と差分計算
/// - レンダリングパイプラインの制御
/// - イベントの配信
///
/// 使用例：
/// ```swift
/// let graph = ViewGraph()
/// graph.setRootView(MyView())
/// graph.render(into: &buffer)
/// ```

import Foundation

/// Viewグラフ管理システム
public class ViewGraph {
  // MARK: - Properties
  
  /// ルートノード
  private var rootNode: RenderNode?
  
  /// ノードストレージ（状態の永続化）
  private let nodeStorage = NodeStorage()
  
  /// 環境値
  private var environment = EnvironmentValues()
  
  /// フォーカス管理
  private var focusState = FocusState()
  
  /// 再描画が必要かどうか
  private var needsRender = true
  
  /// 現在のCellBuffer（前回のレンダリング結果）
  private var currentBuffer: CellBuffer?
  
  /// レンダリングコンテキスト
  private var renderContext: RenderContext {
    RenderContext(
      environment: environment,
      focusState: focusState,
      animation: nil,
      redrawTrigger: { [weak self] in
        self?.setNeedsRender()
      },
      currentTime: Date().timeIntervalSinceReferenceDate,
      nodeStorage: nodeStorage
    )
  }
  
  /// ルートView（互換性のため保持）
  private var rootView: (any View)?
  
  // MARK: - Initialization
  
  /// イニシャライザ
  public init() {}
  
  // MARK: - Public Methods
  
  /// ルートViewを設定
  ///
  /// - Parameter view: ルートとなるView
  public func setRootView<V: View>(_ view: V) {
    self.rootView = view
    self.rootNode = nil // 再構築をトリガー
    setNeedsRender()
  }
  
  /// 環境値を更新
  ///
  /// - Parameter environment: 新しい環境値
  public func updateEnvironment(_ environment: EnvironmentValues) {
    self.environment = environment
    setNeedsRender()
  }
  
  /// フォーカス状態を更新
  ///
  /// - Parameter focusState: 新しいフォーカス状態
  public func updateFocusState(_ focusState: FocusState) {
    self.focusState = focusState
    setNeedsRender()
  }
  
  /// レンダリング実行
  ///
  /// - Parameter buffer: レンダリング先のCellBuffer
  public func render(into buffer: inout CellBuffer) {
    // ルートノードがない場合は構築
    if rootNode == nil {
      buildRootNode()
    }
    
    guard let rootNode = rootNode else { return }
    
    // レイアウト計算
    let constraints = LayoutConstraints(
      maxWidth: buffer.width,
      maxHeight: buffer.height
    )
    rootNode.layout(constraints: constraints)
    
    // 差分計算と適用
    if let currentBuffer = currentBuffer {
      // 差分レンダリング
      let patches = calculatePatches(from: currentBuffer, to: buffer)
      applyPatches(patches, to: &buffer)
    } else {
      // 初回レンダリング
      rootNode.render(into: &buffer)
    }
    
    // 現在のバッファを保存
    self.currentBuffer = buffer.copy()
    needsRender = false
  }
  
  /// イベントを処理
  ///
  /// - Parameter event: 処理するイベント
  /// - Returns: イベントが処理されたかどうか
  @discardableResult
  public func handleEvent(_ event: KeyboardKey) -> Bool {
    // TODO: イベント処理の実装
    // 現在は既存のシステムに委譲
    return false
  }
  
  /// 再レンダリングを要求
  public func setNeedsRender() {
    needsRender = true
  }
  
  /// 再レンダリングが必要かどうか
  public var needsRedraw: Bool {
    return needsRender
  }
  
  // MARK: - Private Methods
  
  /// ルートノードを構築
  private func buildRootNode() {
    guard let rootView = rootView else { return }
    
    // ViewからRenderNodeへ変換
    let context = renderContext
    rootNode = rootView.renderNode(context: context)
  }
  
  /// 差分パッチを計算
  private func calculatePatches(from oldBuffer: CellBuffer, to newBuffer: CellBuffer) -> [RenderPatch] {
    var patches: [RenderPatch] = []
    
    // 簡易実装：変更されたセルを検出
    for y in 0..<min(oldBuffer.height, newBuffer.height) {
      for x in 0..<min(oldBuffer.width, newBuffer.width) {
        if let oldCell = oldBuffer.getCell(row: y, col: x),
           let newCell = newBuffer.getCell(row: y, col: x),
           oldCell != newCell {
          patches.append(.cellChanged(x: x, y: y, from: oldCell, to: newCell))
        }
      }
    }
    
    return patches
  }
  
  /// パッチを適用
  private func applyPatches(_ patches: [RenderPatch], to buffer: inout CellBuffer) {
    guard let rootNode = rootNode else { return }
    
    // 最適化されたパッチを適用
    let optimizedPatches = RenderPatchOptimizer.optimize(patches)
    let nodeMap = buildNodeMap(from: rootNode)
    
    RenderPatchApplier.apply(
      patches: optimizedPatches,
      to: &buffer,
      nodeMap: nodeMap
    )
  }
  
  /// ノードマップを構築
  private func buildNodeMap(from root: RenderNode) -> [ObjectIdentifier: RenderNode] {
    var map: [ObjectIdentifier: RenderNode] = [:]
    
    func traverse(_ node: RenderNode) {
      map[node.id] = node
      for child in node.children {
        traverse(child)
      }
    }
    
    traverse(root)
    return map
  }
  
  // MARK: - Debugging
  
  /// デバッグ情報を出力
  public func debugPrint() {
    print("ViewGraph Debug Info:")
    print("  Root Node: \(rootNode != nil ? "Present" : "Nil")")
    print("  Needs Render: \(needsRender)")
    print("  Buffer Size: \(currentBuffer?.width ?? 0) x \(currentBuffer?.height ?? 0)")
    
    if let rootNode = rootNode {
      print("  Node Tree:")
      printNodeTree(rootNode, indent: 4)
    }
  }
  
  /// ノードツリーを出力
  private func printNodeTree(_ node: RenderNode, indent: Int) {
    let padding = String(repeating: " ", count: indent)
    print("\(padding)- \(type(of: node)) [\(node.frame)]")
    
    for child in node.children {
      printNodeTree(child, indent: indent + 2)
    }
  }
}

// MARK: - Integration with CellRenderLoop

extension ViewGraph {
  /// CellRenderLoopとの統合用：現在のLayoutViewを取得
  ///
  /// 移行期間中の互換性のために提供
  public func currentLayoutView() -> (any LayoutView)? {
    // 現在は既存のLayoutViewシステムを使用
    // TODO: RenderNodeからLayoutViewへのアダプターを実装
    return nil
  }
  
  /// 強制的に再構築
  public func invalidate() {
    rootNode = nil
    setNeedsRender()
  }
}