/// LayoutView：ターミナルに描画可能なViewの基本プロトコル
/// 
/// LayoutViewは、SwiftUI風のViewを実際にターミナルに描画するための
/// ブリッジとなるプロトコルです。
/// 
/// SwiftUIのViewとの違い：
/// - View: 宣言的なUI定義（「何を表示するか」）
/// - LayoutView: 実際の描画処理（「どう描画するか」）
/// 
/// 2つの責任：
/// 1. レイアウト計算：makeNode()でYogaノードを作成
/// 2. 描画処理：paint()で指定座標にコンテンツを描画
/// 
/// TUI初心者向け解説：
/// - YogaはFacebook製のFlexboxレイアウトエンジン
/// - WebのCSS Flexboxと同じレイアウトアルゴリズムを使用
/// - ターミナルでもWebのような柔軟なレイアウトが可能
public protocol LayoutView: LegacyView {
  /// Yogaノードを作成してレイアウト情報を定義
  /// 
  /// このメソッドで作成されたノードは：
  /// - 自身のサイズ制約を設定
  /// - 子要素の配置方法を指定
  /// - パディングやマージンを設定
  /// 
  /// 例：
  /// ```swift
  /// func makeNode() -> YogaNode {
  ///     let node = YogaNode()
  ///     node.width = 20     // 幅を20文字に固定
  ///     node.padding = 1    // 周囲に1文字の余白
  ///     return node
  /// }
  /// ```
  func makeNode() -> YogaNode
  
  /// 指定座標にコンテンツを描画
  /// 
  /// - Parameters:
  ///   - origin: 描画開始位置 (x: 列番号, y: 行番号)
  ///   - buffer: 描画先の文字列バッファ（各要素が1行に対応）
  /// 
  /// 注意点：
  /// - originはターミナルの絶対座標
  /// - bufferは画面全体を表す配列
  /// - 描画時はANSIエスケープシーケンスを含む可能性あり
  /// 
  /// 実装例：
  /// ```swift
  /// func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
  ///     let text = "Hello"
  ///     bufferWrite(row: origin.y, col: origin.x, text: text, into: &buffer)
  /// }
  /// ```
  func paint(origin: (x: Int, y: Int), into buffer: inout [String])
}

extension LayoutView {
  /// LegacyViewプロトコルの要件を満たすためのデフォルト実装
  /// 
  /// 背景：
  /// - LayoutViewはLegacyViewを継承している
  /// - LegacyViewはrender()メソッドを要求する
  /// - しかし、LayoutViewはpaint()を使うのでrender()は不要
  /// 
  /// このデフォルト実装により：
  /// - 各LayoutView実装でrender()を定義する必要がない
  /// - CellRenderLoopはpaint()メソッドを使用する
  /// - レガシーコードとの互換性を保つ
  public func render(into buffer: inout [String]) {
    // 何もしない（no-op）
    // LayoutViewはpaint()メソッドで描画を行う
  }
}
