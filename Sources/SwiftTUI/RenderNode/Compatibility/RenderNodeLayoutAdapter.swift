/// RenderNodeLayoutAdapter：RenderNodeをLayoutViewとして扱うアダプター
///
/// 新しいRenderNodeシステムと既存のLayoutViewシステムを橋渡しします。
/// 移行期間中、両方のシステムが共存できるようにするための重要なコンポーネントです。
///
/// 使用例：
/// ```swift
/// let renderNode = TextRenderNode(text: "Hello")
/// let layoutView = RenderNodeLayoutAdapter(renderNode: renderNode)
/// // 既存のシステムでlayoutViewを使用
/// ```

import Foundation
import yoga

/// RenderNodeをLayoutViewとして扱うアダプター
public class RenderNodeLayoutAdapter: LayoutView {
  // MARK: - Properties
  
  /// ラップするRenderNode
  private let renderNode: RenderNode
  
  /// ViewGraphの参照（レンダリング管理用）
  private weak var viewGraph: ViewGraph?
  
  /// Yogaノード（レイアウト計算用）
  private var _yogaNode: YogaNode?
  
  // MARK: - Initialization
  
  /// イニシャライザ
  ///
  /// - Parameters:
  ///   - renderNode: ラップするRenderNode
  ///   - viewGraph: 管理元のViewGraph（オプション）
  public init(renderNode: RenderNode, viewGraph: ViewGraph? = nil) {
    self.renderNode = renderNode
    self.viewGraph = viewGraph
  }
  
  // MARK: - LayoutView Protocol
  
  /// Yogaノードを作成
  public func makeNode() -> YogaNode {
    if let node = _yogaNode {
      return node
    }
    
    let node = YogaNode()
    _yogaNode = node
    
    // RenderNodeのレイアウト設定を適用
    renderNode.configureYogaNode(node)
    
    return node
  }
  
  /// 通常の描画
  public func paint(
    origin: (x: Int, y: Int),
    into buffer: inout [String]
  ) {
    // CellBufferを作成
    let width = buffer.first?.count ?? 80
    let height = buffer.count
    var cellBuffer = CellBuffer(width: width, height: height)
    
    // CellBufferに描画
    paintCells(at: origin, into: &cellBuffer)
    
    // 文字列バッファに変換
    let lines = cellBuffer.toANSILines()
    for (index, line) in lines.enumerated() {
      let targetRow = origin.y + index
      if targetRow < buffer.count {
        buffer[targetRow] = line
      }
    }
  }
  
  /// セルベースで描画（内部用）
  private func paintCells(
    at origin: (x: Int, y: Int),
    into buffer: inout CellBuffer
  ) {
    // RenderNodeのフレームを設定
    let frame = Frame(
      x: origin.x,
      y: origin.y,
      width: renderNode.frame.width,
      height: renderNode.frame.height
    )
    
    // フレームが更新された場合は反映
    if renderNode.frame != frame {
      // TODO: フレーム更新のメソッドを追加
    }
    
    // RenderNodeでレンダリング
    renderNode.render(into: &buffer)
  }
  
}

// MARK: - LayoutViewWrapper for Migration

/// 既存ViewをRenderNode経由でレンダリングするラッパー
public class RenderNodeLayoutViewWrapper<Content: View>: LayoutView {
  // MARK: - Properties
  
  /// ラップするView
  private let content: Content
  
  /// ViewGraph
  private let viewGraph: ViewGraph
  
  /// キャッシュされたRenderNode
  private var cachedRenderNode: RenderNode?
  
  // MARK: - Initialization
  
  /// イニシャライザ
  public init(content: Content) {
    self.content = content
    self.viewGraph = ViewGraph()
    self.viewGraph.setRootView(content)
  }
  
  // MARK: - LayoutView Protocol
  
  /// Yogaノードを作成
  public func makeNode() -> YogaNode {
    // ViewGraphを使用してレイアウトを計算
    return YogaNode()
  }
  
  /// 通常の描画
  public func paint(
    origin: (x: Int, y: Int),
    into buffer: inout [String]
  ) {
    // CellBufferを作成
    let width = buffer.first?.count ?? 80
    let height = buffer.count
    var cellBuffer = CellBuffer(width: width, height: height)
    
    // ViewGraphでレンダリング
    viewGraph.render(into: &cellBuffer)
    
    // 文字列バッファに変換
    let lines = cellBuffer.toANSILines()
    for (index, line) in lines.enumerated() {
      let targetRow = origin.y + index
      if targetRow < buffer.count {
        buffer[targetRow] = line
      }
    }
  }
  
}

// MARK: - Migration Helpers

/// 移行フラグ：RenderNodeシステムを使用するかどうか
public struct RenderNodeMigration {
  /// グローバル設定：RenderNodeシステムを有効化
  public static var isEnabled = false
  
  /// 特定のViewタイプでRenderNodeを使用するかどうか
  private static var enabledTypes: Set<ObjectIdentifier> = []
  
  /// 特定のViewタイプでRenderNodeを有効化
  public static func enable<T: View>(for type: T.Type) {
    enabledTypes.insert(ObjectIdentifier(type))
  }
  
  /// 特定のViewタイプでRenderNodeが有効かどうか
  public static func isEnabled<T: View>(for type: T.Type) -> Bool {
    return isEnabled || enabledTypes.contains(ObjectIdentifier(type))
  }
  
  /// すべてのタイプでRenderNodeを有効化
  public static func enableAll() {
    isEnabled = true
  }
  
  /// すべてのタイプでRenderNodeを無効化
  public static func disableAll() {
    isEnabled = false
    enabledTypes.removeAll()
  }
}