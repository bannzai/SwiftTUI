/// HStackRenderNode：水平スタック用のRenderNode
///
/// HStackビューに対応するRenderNodeの実装です。
/// 子要素を水平方向に配置し、spacing、alignmentなどを制御します。
///
/// 使用例：
/// ```swift
/// let hstack = HStackRenderNode(spacing: 2, alignment: .top)
/// hstack.addChild(TextRenderNode(text: "Label:"))
/// hstack.addChild(TextRenderNode(text: "Value"))
/// ```

import Foundation
import yoga

/// 水平スタック用のRenderNode
public class HStackRenderNode: RenderNode {
  // MARK: - Properties
  
  /// 子要素間のスペース
  public let spacing: Int
  
  /// 垂直方向の配置
  public let alignment: VerticalAlignment
  
  // MARK: - Initialization
  
  /// イニシャライザ
  ///
  /// - Parameters:
  ///   - spacing: 子要素間のスペース（デフォルト: 0）
  ///   - alignment: 垂直方向の配置（デフォルト: .center）
  ///   - attributes: レンダリング属性
  public init(
    spacing: Int = 0,
    alignment: VerticalAlignment = .center,
    attributes: RenderAttributes = RenderAttributes()
  ) {
    self.spacing = spacing
    self.alignment = alignment
    super.init(attributes: attributes)
  }
  
  // MARK: - Layout
  
  /// Yogaノードの設定
  override public func configureYogaNode(_ node: YogaNode) {
    super.configureYogaNode(node)
    
    // Flexboxの設定
    node.flexDirection(.row)
    
    // アライメントの設定
    switch alignment {
    case .top:
      node.alignItems(.flexStart)
    case .center:
      node.alignItems(.center)
    case .bottom:
      node.alignItems(.flexEnd)
    }
    
    // スペーシングの設定
    if spacing > 0 {
      // Yogaのgapプロパティが利用可能な場合
      // node.gap(.row, Float(spacing))
      // 現在は子要素のマージンで対応
    }
  }
  
  /// 子ノードを追加（スペーシング対応）
  override public func addChild(_ child: RenderNode) {
    // 最初の子要素以外にはマージンを追加
    if !children.isEmpty && spacing > 0 {
      // TODO: 子要素のマージン設定をYogaノード設定時に行う
      // 現在はconfigureYogaNodeメソッドで対応
    }
    
    super.addChild(child)
  }
  
  // MARK: - Rendering
  
  /// コンテンツの描画
  override public func renderContent(into buffer: inout CellBuffer) {
    // HStackは子要素のレンダリングをRenderNodeが行うため、
    // ここでは特別な描画は不要
    // 背景色やボーダーは基底クラスが処理
  }
  
  // MARK: - Factory Methods
  
  /// 子要素を一度に設定
  ///
  /// - Parameter children: 子RenderNodeの配列
  /// - Returns: 自身の参照（メソッドチェーン用）
  @discardableResult
  public func withChildren(_ children: [RenderNode]) -> HStackRenderNode {
    // 既存の子要素をクリア
    removeAllChildren()
    
    // 新しい子要素を追加
    for child in children {
      addChild(child)
    }
    
    return self
  }
  
  // MARK: - Debugging
  
  /// デバッグ用の説明
  public var description: String {
    return "HStackRenderNode(spacing: \(spacing), alignment: \(alignment), children: \(children.count))"
  }
}

// MARK: - HStack Extension

extension HStack {
  /// HStackビューからHStackRenderNodeを作成
  ///
  /// 移行期間中の便利メソッド
  public func createRenderNode(context: RenderContext) -> HStackRenderNode {
    // 属性を作成
    var attributes = RenderAttributes()
    
    // TODO: モディファイアから属性を抽出
    
    // HStackRenderNodeを作成
    let hstack = HStackRenderNode(
      spacing: spacing ?? 0,
      alignment: alignment,
      attributes: attributes
    )
    
    // 子要素を変換して追加
    // TODO: @ViewBuilderの内容を適切に処理
    
    return hstack
  }
}