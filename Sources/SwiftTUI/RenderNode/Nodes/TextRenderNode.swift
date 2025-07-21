/// TextRenderNode：テキスト表示用のRenderNode
///
/// Textビューに対応するRenderNodeの実装です。
/// テキストの描画、スタイル適用、日本語文字幅の計算などを行います。
///
/// 使用例：
/// ```swift
/// let textNode = TextRenderNode(text: "Hello, World!")
/// textNode.attributes.foregroundColor = .green
/// textNode.attributes.bold = true
/// ```

import Foundation

/// テキスト表示用のRenderNode
public class TextRenderNode: RenderNode {
  // MARK: - Properties
  
  /// 表示するテキスト
  public let text: String
  
  /// テキストの実際の幅（文字数ではなく表示幅）
  private var textWidth: Int {
    return stringWidth(text)
  }
  
  /// テキストの高さ（行数）
  private var textHeight: Int {
    // 改行を考慮
    return text.split(separator: "\n", omittingEmptySubsequences: false).count
  }
  
  // MARK: - Initialization
  
  /// イニシャライザ
  ///
  /// - Parameters:
  ///   - text: 表示するテキスト
  ///   - attributes: レンダリング属性
  public init(text: String, attributes: RenderAttributes = RenderAttributes()) {
    self.text = text
    super.init(attributes: attributes)
  }
  
  // MARK: - Layout
  
  /// Yogaノードの設定
  override public func configureYogaNode(_ node: YogaNode) {
    super.configureYogaNode(node)
    
    // テキストの固有サイズを設定
    node.setSize(width: Float(textWidth), height: Float(textHeight))
    
    // パディングを考慮
    let padding = attributes.padding
    let totalPadding = padding.horizontal + padding.vertical
    if totalPadding > 0 {
      // 平均パディングを設定（YogaNodeの制限のため）
      let avgPadding = Float(totalPadding) / 4.0
      node.padding(all: avgPadding)
    }
  }
  
  // MARK: - Rendering
  
  /// コンテンツの描画
  override public func renderContent(into buffer: inout CellBuffer) {
    // フレーム内の描画領域を計算
    let padding = attributes.padding
    let contentX = frame.x + padding.leading
    let contentY = frame.y + padding.top
    let contentWidth = frame.width - padding.horizontal
    let contentHeight = frame.height - padding.vertical
    
    // テキストを行に分割
    let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
      .map { String($0) }
    
    // 各行を描画
    for (lineIndex, line) in lines.enumerated() {
      let y = contentY + lineIndex
      
      // 描画範囲外の場合はスキップ
      if y >= contentY + contentHeight { break }
      
      // 行を描画
      drawLine(
        line,
        at: (x: contentX, y: y),
        maxWidth: contentWidth,
        into: &buffer
      )
    }
  }
  
  /// 1行のテキストを描画
  private func drawLine(
    _ text: String,
    at position: (x: Int, y: Int),
    maxWidth: Int,
    into buffer: inout CellBuffer
  ) {
    var currentX = position.x
    let y = position.y
    
    // テキストスタイルを作成
    var style = TextStyle()
    if attributes.bold {
      style.insert(.bold)
    }
    if attributes.underline {
      style.insert(.underline)
    }
    
    // 各文字を描画
    for char in text {
      let charWidth = stringWidth(String(char))
      
      // 描画範囲を超える場合は終了
      if currentX + charWidth > position.x + maxWidth {
        break
      }
      
      // セルを作成して設定
      let cell = Cell(
        character: char,
        foregroundColor: attributes.foregroundColor,
        backgroundColor: attributes.backgroundColor,
        style: style
      )
      
      buffer.setCell(row: y, col: currentX, cell: cell)
      
      // 2幅文字の場合は継続セルを設定
      if charWidth == 2 {
        let continuationCell = Cell(
          character: " ",
          foregroundColor: attributes.foregroundColor,
          backgroundColor: attributes.backgroundColor,
          style: style,
          isContinuation: true
        )
        buffer.setCell(row: y, col: currentX + 1, cell: continuationCell)
      }
      
      currentX += charWidth
    }
  }
  
  // MARK: - Diffing
  
  /// カスタム差分計算
  override public func diff(with previous: RenderNode?) -> [RenderPatch] {
    var patches = super.diff(with: previous)
    
    // TextRenderNode固有の差分チェック
    if let previousText = previous as? TextRenderNode {
      if text != previousText.text {
        // テキストが変更された場合はコンテンツ変更パッチを追加
        patches.append(.contentChanged(id: id))
      }
    }
    
    return patches
  }
  
  // MARK: - Debugging
  
  /// デバッグ用の説明
  public var description: String {
    return "TextRenderNode(\"\(text.prefix(20))\(text.count > 20 ? "..." : "")\")"
  }
}

// MARK: - Factory Extension

extension Text {
  /// TextビューからTextRenderNodeを作成
  ///
  /// 移行期間中の便利メソッド
  public func createRenderNode(context: RenderContext) -> TextRenderNode {
    // 文字列を取得
    let textContent = extractText()
    
    // 属性を作成
    var attributes = RenderAttributes()
    
    // モディファイアから属性を抽出
    // TODO: モディファイアチェーンから属性を抽出する仕組みが必要
    
    return TextRenderNode(text: textContent, attributes: attributes)
  }
  
  /// Textビューから文字列を抽出
  private func extractText() -> String {
    // TODO: より適切な実装が必要
    // 現在は単純な文字列表現を返す
    return String(describing: self)
  }
}