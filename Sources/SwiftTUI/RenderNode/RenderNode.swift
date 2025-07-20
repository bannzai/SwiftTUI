/// RenderNode：新アーキテクチャの中核となるレンダリングノード
///
/// このファイルには、SwiftTUIの新しいレンダリングアーキテクチャの基盤となる
/// RenderNodeクラスが定義されています。各Viewは最終的にRenderNodeに変換され、
/// 効率的なレイアウト計算とレンダリングを行います。
///
/// 設計思想：
/// - クラスベース：参照セマンティクスによる効率的なツリー管理
/// - Yogaレイアウトエンジンの内部統合
/// - 差分レンダリングのサポート
/// - セルベースレンダリングへの直接描画

import Foundation
import yoga

/// レンダリングノードの基底クラス
///
/// すべてのUI要素は最終的にRenderNodeまたはそのサブクラスに変換されます。
/// このクラスは、レイアウト計算、レンダリング、差分計算の基本機能を提供します。
///
/// 使用例:
/// ```swift
/// class TextRenderNode: RenderNode {
///     override func renderContent(into buffer: inout CellBuffer) {
///         // テキストの描画実装
///     }
/// }
/// ```
open class RenderNode {
  // MARK: - Properties
  
  /// ノードのユニークID
  public var id: ObjectIdentifier!
  
  /// 計算されたフレーム（レイアウト後の位置とサイズ）
  public private(set) var frame: Frame = .zero
  
  /// 子ノードのリスト
  public var children: [RenderNode] = []
  
  /// レンダリング属性
  public var attributes: RenderAttributes
  
  /// Yogaノード（レイアウト計算用）
  private var yogaNode: YogaNode?
  
  /// 前回のレンダリング結果（差分計算用）
  private var previousRender: CellBuffer?
  
  /// ノードが無効化されているかどうか
  private var needsLayout: Bool = true
  private var needsRender: Bool = true
  
  // MARK: - Initialization
  
  /// イニシャライザ
  ///
  /// - Parameter attributes: 初期レンダリング属性
  public init(attributes: RenderAttributes = RenderAttributes()) {
    self.attributes = attributes
    self.id = ObjectIdentifier(self)
  }
  
  // MARK: - Layout
  
  /// レイアウトを計算
  ///
  /// Yogaレイアウトエンジンを使用して、制約に基づいてノードとその子の
  /// 位置とサイズを計算します。
  ///
  /// - Parameter constraints: 親から渡されるレイアウト制約
  public func layout(constraints: LayoutConstraints) {
    guard needsLayout else { return }
    
    // Yogaノードの準備
    let yoga = ensureYogaNode()
    
    // 制約をYogaに適用
    yoga.setSize(width: Float(constraints.maxWidth), height: Float(constraints.maxHeight))
    
    // サブクラスでカスタマイズ
    configureYogaNode(yoga)
    
    // 子ノードのYogaノードを設定
    yoga.removeAllChildren()
    for child in children {
      let childYoga = child.ensureYogaNode()
      yoga.insert(child: childYoga)
    }
    
    // レイアウト計算
    yoga.calculate(
      width: Float(constraints.maxWidth),
      height: Float(constraints.maxHeight)
    )
    
    // 計算結果を適用
    applyYogaLayout(yoga)
    
    // 子ノードのレイアウトも適用
    for child in children {
      child.applyYogaLayout(child.ensureYogaNode())
    }
    
    needsLayout = false
  }
  
  /// Yogaノードを確実に取得
  private func ensureYogaNode() -> YogaNode {
    if let node = yogaNode {
      return node
    }
    let node = YogaNode()
    yogaNode = node
    return node
  }
  
  /// Yogaノードの設定（サブクラスでオーバーライド）
  ///
  /// サブクラスは、このメソッドをオーバーライドして
  /// 独自のレイアウト設定を行います。
  ///
  /// - Parameter node: 設定するYogaノード
  open func configureYogaNode(_ node: YogaNode) {
    // パディングの適用
    // TODO: YogaNodeに個別のパディング設定メソッドを追加する必要がある
    // 現在はpadding(all:)メソッドのみ使用可能
    let totalPadding = attributes.border != nil ? 1 : 0
    let avgPadding = (attributes.padding.top + attributes.padding.leading + 
                      attributes.padding.bottom + attributes.padding.trailing) / 4
    node.padding(all: Float(avgPadding + totalPadding))
  }
  
  /// Yogaレイアウトの結果を適用
  private func applyYogaLayout(_ node: YogaNode) {
    // frameプロパティを使用してレイアウト結果を取得
    let yogaFrame = node.frame
    frame = Frame(
      x: yogaFrame.x,
      y: yogaFrame.y,
      width: yogaFrame.w,
      height: yogaFrame.h
    )
  }
  
  // MARK: - Rendering
  
  /// セルバッファへレンダリング
  ///
  /// ノードとその子をセルバッファに描画します。
  ///
  /// - Parameter buffer: 描画先のセルバッファ
  public func render(into buffer: inout CellBuffer) {
    // 背景色の描画
    if let backgroundColor = attributes.backgroundColor {
      for y in frame.y..<frame.maxY {
        for x in frame.x..<frame.maxX {
          buffer.setCell(
            row: y,
            col: x,
            cell: Cell(
              character: " ",
              backgroundColor: backgroundColor
            )
          )
        }
      }
    }
    
    // ボーダーの描画
    if let borderStyle = attributes.border {
      drawBorder(style: borderStyle, into: &buffer)
    }
    
    // コンテンツの描画（サブクラスで実装）
    renderContent(into: &buffer)
    
    // 子ノードの描画
    for child in children {
      child.render(into: &buffer)
    }
    
    // レンダリング結果を保存（差分計算用）
    // TODO: CellBufferのコピー機能を実装
    // previousRender = buffer.copy()
    needsRender = false
  }
  
  /// コンテンツの描画（サブクラスでオーバーライド）
  ///
  /// サブクラスは、このメソッドをオーバーライドして
  /// 独自のコンテンツを描画します。
  ///
  /// - Parameter buffer: 描画先のセルバッファ
  open func renderContent(into buffer: inout CellBuffer) {
    // サブクラスで実装
  }
  
  /// ボーダーの描画
  private func drawBorder(style: BorderStyle, into buffer: inout CellBuffer) {
    let color = attributes.foregroundColor
    
    // ボーダー文字を決定
    let chars: (topLeft: Character, top: Character, topRight: Character, 
                left: Character, right: Character, 
                bottomLeft: Character, bottom: Character, bottomRight: Character)
    
    switch style {
    case .single:
      chars = ("┌", "─", "┐", "│", "│", "└", "─", "┘")
    case .double:
      chars = ("╔", "═", "╗", "║", "║", "╚", "═", "╝")
    case .rounded:
      chars = ("╭", "─", "╮", "│", "│", "╰", "─", "╯")
    case .thick:
      chars = ("┏", "━", "┓", "┃", "┃", "┗", "━", "┛")
    }
    
    // 上辺
    buffer.setCell(
      row: frame.y,
      col: frame.x,
      cell: Cell(character: chars.topLeft, foregroundColor: color)
    )
    for x in (frame.x + 1)..<(frame.maxX - 1) {
      buffer.setCell(
        row: frame.y,
        col: x,
        cell: Cell(character: chars.top, foregroundColor: color)
      )
    }
    buffer.setCell(
      row: frame.y,
      col: frame.maxX - 1,
      cell: Cell(character: chars.topRight, foregroundColor: color)
    )
    
    // 左右辺
    for y in (frame.y + 1)..<(frame.maxY - 1) {
      buffer.setCell(
        row: y,
        col: frame.x,
        cell: Cell(character: chars.left, foregroundColor: color)
      )
      buffer.setCell(
        row: y,
        col: frame.maxX - 1,
        cell: Cell(character: chars.right, foregroundColor: color)
      )
    }
    
    // 下辺
    buffer.setCell(
      row: frame.maxY - 1,
      col: frame.x,
      cell: Cell(character: chars.bottomLeft, foregroundColor: color)
    )
    for x in (frame.x + 1)..<(frame.maxX - 1) {
      buffer.setCell(
        row: frame.maxY - 1,
        col: x,
        cell: Cell(character: chars.bottom, foregroundColor: color)
      )
    }
    buffer.setCell(
      row: frame.maxY - 1,
      col: frame.maxX - 1,
      cell: Cell(character: chars.bottomRight, foregroundColor: color)
    )
  }
  
  // MARK: - Diffing
  
  /// 差分を計算
  ///
  /// 前回のレンダリング結果と比較して、変更された部分を検出します。
  ///
  /// - Parameter previous: 比較対象の前回のノード
  /// - Returns: 変更を表すパッチのリスト
  public func diff(with previous: RenderNode?) -> [RenderPatch] {
    var patches: [RenderPatch] = []
    
    // フレームの変更
    if let previous = previous, frame != previous.frame {
      patches.append(.frameChanged(id: id, from: previous.frame, to: frame))
    }
    
    // 属性の変更
    if let previous = previous, attributes != previous.attributes {
      patches.append(.attributesChanged(id: id, from: previous.attributes, to: attributes))
    }
    
    // 子ノードの差分
    let childPatches = diffChildren(with: previous?.children ?? [])
    patches.append(contentsOf: childPatches)
    
    // コンテンツの変更（レンダリング結果を比較）
    if let previous = previous,
       let prevRender = previous.previousRender,
       let currRender = previousRender {
      let contentPatches = diffContent(previous: prevRender, current: currRender)
      patches.append(contentsOf: contentPatches)
    }
    
    return patches
  }
  
  /// 子ノードの差分を計算
  private func diffChildren(with previousChildren: [RenderNode]) -> [RenderPatch] {
    var patches: [RenderPatch] = []
    
    // 簡単な実装：子ノードの数が違う場合は全て再描画
    if children.count != previousChildren.count {
      patches.append(.childrenChanged(id: id))
      return patches
    }
    
    // 各子ノードの差分を計算
    for (child, prevChild) in zip(children, previousChildren) {
      let childPatches = child.diff(with: prevChild)
      patches.append(contentsOf: childPatches)
    }
    
    return patches
  }
  
  /// コンテンツの差分を計算
  private func diffContent(previous: CellBuffer, current: CellBuffer) -> [RenderPatch] {
    var patches: [RenderPatch] = []
    
    // フレーム内のセルを比較
    for y in frame.y..<frame.maxY {
      for x in frame.x..<frame.maxX {
        if let prevCell = previous.getCell(row: y, col: x),
           let currCell = current.getCell(row: y, col: x),
           prevCell != currCell {
          patches.append(.cellChanged(x: x, y: y, from: prevCell, to: currCell))
        }
      }
    }
    
    return patches
  }
  
  // MARK: - Invalidation
  
  /// レイアウトを無効化
  ///
  /// 次回の更新時にレイアウトの再計算を強制します。
  public func invalidateLayout() {
    needsLayout = true
    // 親ノードも無効化する必要がある場合は、ここで処理
  }
  
  /// レンダリングを無効化
  ///
  /// 次回の更新時に再レンダリングを強制します。
  public func invalidateRender() {
    needsRender = true
  }
  
  // MARK: - Child Management
  
  /// 子ノードを追加
  ///
  /// - Parameter child: 追加する子ノード
  public func addChild(_ child: RenderNode) {
    children.append(child)
    invalidateLayout()
  }
  
  /// 子ノードを削除
  ///
  /// - Parameter child: 削除する子ノード
  public func removeChild(_ child: RenderNode) {
    children.removeAll { $0.id == child.id }
    invalidateLayout()
  }
  
  /// すべての子ノードを削除
  public func removeAllChildren() {
    children.removeAll()
    invalidateLayout()
  }
}