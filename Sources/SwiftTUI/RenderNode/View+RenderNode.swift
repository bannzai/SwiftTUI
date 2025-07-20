/// View+RenderNode：ViewプロトコルにRenderNode生成機能を追加
///
/// このファイルには、既存のViewプロトコルに新しいrenderNodeメソッドを
/// 追加する拡張が定義されています。これにより、既存のView実装を
/// 変更することなく、新アーキテクチャへの段階的な移行が可能になります。

import Foundation

// MARK: - View Protocol Extension

/// ViewプロトコルにRenderNode生成機能を追加
extension View {
  /// RenderNodeを生成
  ///
  /// このメソッドは、ViewをRenderNodeに変換します。
  /// デフォルト実装では、互換性のためにLayoutViewを経由しますが、
  /// 各Viewは独自の実装でオーバーライドできます。
  ///
  /// - Parameter context: レンダリングコンテキスト
  /// - Returns: 生成されたRenderNode
  public func renderNode(context: RenderContext) -> RenderNode {
    // デフォルト実装：互換性レイヤーを使用
    if Body.self == Never.self {
      // プリミティブView
      return renderPrimitiveNode(context: context)
    } else {
      // コンポジットView：bodyを再帰的に処理
      return body.renderNode(context: context)
    }
  }
  
  /// プリミティブViewのRenderNode生成
  private func renderPrimitiveNode(context: RenderContext) -> RenderNode {
    // 型ベースのディスパッチ
    switch self {
    case let text as Text:
      return TextRenderNode(text: text, context: context)
      
    case let spacer as Spacer:
      return SpacerRenderNode(spacer: spacer, context: context)
      
    case is EmptyView:
      return EmptyRenderNode()
      
    default:
      // フォールバック：互換性アダプターを使用
      return CompatibilityRenderNode(view: self, context: context)
    }
  }
}

// MARK: - Primitive RenderNodes

/// Text用のRenderNode（仮実装）
class TextRenderNode: RenderNode {
  private let text: Text
  
  init(text: Text, context: RenderContext) {
    self.text = text
    super.init()
    
    // 属性の設定（将来的にはTextの内部実装から取得）
    // 現在は仮実装
  }
  
  override func renderContent(into buffer: inout CellBuffer) {
    // TODO: 実際のテキストレンダリング実装
    // 現在は互換性レイヤーを使用
  }
}

/// Spacer用のRenderNode（仮実装）
class SpacerRenderNode: RenderNode {
  private let spacer: Spacer
  
  init(spacer: Spacer, context: RenderContext) {
    self.spacer = spacer
    super.init()
  }
  
  override func configureYogaNode(_ node: YogaNode) {
    super.configureYogaNode(node)
    // Spacerは可能な限り拡張
    // TODO: YogaNodeにflexGrowメソッドを追加する必要がある
  }
  
  override func renderContent(into buffer: inout CellBuffer) {
    // Spacerは何も描画しない
  }
}

/// EmptyView用のRenderNode
class EmptyRenderNode: RenderNode {
  override func configureYogaNode(_ node: YogaNode) {
    super.configureYogaNode(node)
    // EmptyViewはサイズ0
    node.setSize(width: 0, height: 0)
  }
  
  override func renderContent(into buffer: inout CellBuffer) {
    // EmptyViewは何も描画しない
  }
}

// MARK: - Compatibility Layer

/// 互換性のためのRenderNode
///
/// 既存のLayoutViewシステムをラップして、RenderNodeとして動作させます。
/// これにより、まだ移行されていないViewも新システムで動作します。
class CompatibilityRenderNode: RenderNode {
  private let view: any View
  private let context: RenderContext
  private var layoutView: (any LayoutView)?
  
  init(view: any View, context: RenderContext) {
    self.view = view
    self.context = context
    super.init()
  }
  
  override func configureYogaNode(_ node: YogaNode) {
    super.configureYogaNode(node)
    
    // LayoutViewを取得（既存のViewRendererを使用）
    if layoutView == nil {
      layoutView = ViewRenderer.renderView(view)
    }
    
    // LayoutViewのYogaNodeを使用
    if let layoutView = layoutView {
      let layoutNode = layoutView.makeNode()
      // TODO: YogaNodeの設定をコピーする方法を実装
      // 現在はサイズ設定のみ（他のプロパティは後で追加）
    }
  }
  
  override func renderContent(into buffer: inout CellBuffer) {
    // LayoutViewの描画を使用
    if let layoutView = layoutView {
      // CellLayoutViewの場合
      if let cellLayoutView = layoutView as? CellLayoutView {
        cellLayoutView.paintCells(
          origin: (x: Int(frame.x), y: Int(frame.y)),
          into: &buffer
        )
      } else {
        // 通常のLayoutViewの場合：一時バッファを使用
        var stringBuffer: [String] = []
        layoutView.paint(
          origin: (x: 0, y: 0),
          into: &stringBuffer
        )
        
        // StringバッファをCellBufferに変換
        for (row, line) in stringBuffer.enumerated() {
          let y = Int(frame.y) + row
          if !line.isEmpty {
            bufferWriteCell(
              row: y,
              col: Int(frame.x),
              text: line,
              into: &buffer
            )
          }
        }
      }
    }
  }
}

// MARK: - ViewGraph Integration

/// ViewをRenderNodeツリーに変換するヘルパー
public struct ViewToRenderNodeConverter {
  /// ViewをRenderNodeツリーに変換
  public static func convert<V: View>(
    _ view: V,
    context: RenderContext
  ) -> RenderNode {
    return view.renderNode(context: context)
  }
  
  /// 環境値を適用してViewを変換
  public static func convert<V: View>(
    _ view: V,
    environment: EnvironmentValues = EnvironmentValues(),
    focusState: FocusState = FocusState(),
    redrawTrigger: @escaping () -> Void = {}
  ) -> RenderNode {
    let context = RenderContext(
      environment: environment,
      focusState: focusState,
      redrawTrigger: redrawTrigger
    )
    return view.renderNode(context: context)
  }
}

// MARK: - Modified Content Support

/// ModifiedContent用の特別な処理
extension View {
  /// ModifiedContentのRenderNode生成
  fileprivate func renderModifiedContent(context: RenderContext) -> RenderNode {
    // TODO: ModifiedContentの適切な処理
    // 現在は互換性レイヤーを使用
    return CompatibilityRenderNode(view: self, context: context)
  }
}

// MARK: - Container Views

/// VStackやHStackなどのコンテナView用の拡張
extension View {
  /// コンテナViewのRenderNode生成
  fileprivate func renderContainerNode(
    context: RenderContext,
    axis: Axis.Set,
    spacing: Int = 0,
    alignment: Alignment = .center
  ) -> RenderNode {
    // TODO: コンテナ固有の実装
    return CompatibilityRenderNode(view: self, context: context)
  }
}

// NOTE: AxisとAlignmentは既存の定義を使用