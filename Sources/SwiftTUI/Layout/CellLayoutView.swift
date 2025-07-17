/// CellLayoutView：セルベースレンダリングをサポートするプロトコル
///
/// セルベースレンダリングとは：
/// - ターミナルの各文字位置（セル）を個別に管理
/// - 各セルに文字、前景色、背景色を設定可能
/// - 差分更新による高速な再描画
///
/// 従来の文字列ベース描画との違い：
/// - 文字列ベース: 行単位で文字列を管理
/// - セルベース: 文字単位で情報を管理
///
/// メリット：
/// - 背景色が正確に描画される
/// - 部分的な更新が効率的
/// - 複雑なレイアウトでも正確な描画

import yoga

public protocol CellLayoutView: LayoutView {
  /// セルバッファに描画するメソッド
  ///
  /// paint()メソッドのセルベース版です。
  /// CellBufferを使用することで、より精密な描画制御が可能です。
  ///
  /// - Parameters:
  ///   - origin: 描画開始位置 (x: 列番号, y: 行番号)
  ///   - buffer: 描画先のCellBuffer
  ///
  /// 実装例：
  /// ```swift
  /// func paintCells(origin: (x: Int, y: Int), into buffer: inout CellBuffer) {
  ///     let text = "Hello"
  ///     for (index, char) in text.enumerated() {
  ///         buffer.setCell(
  ///             x: origin.x + index,
  ///             y: origin.y,
  ///             cell: Cell(character: char, foreground: .green)
  ///         )
  ///     }
  /// }
  /// ```
  func paintCells(origin: (x: Int, y: Int), into buffer: inout CellBuffer)
}

/// CellLayoutViewのデフォルト実装
extension CellLayoutView {
  /// 従来のString配列への描画メソッド（互換性のため）
  ///
  /// このデフォルト実装により：
  /// - CellLayoutViewも既存のLayoutViewとして動作
  /// - paintCells()の実装だけでpaint()も自動的に機能
  /// - 段階的な移行が可能
  ///
  /// 処理の流れ：
  /// 1. 一時的なCellBufferを作成
  /// 2. paintCells()でCellBufferに描画
  /// 3. CellBufferをANSI文字列に変換
  /// 4. Stringバッファにマージ
  public func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
    // ステップ1: 一時的なCellBufferを作成
    // 十分大きなサイズを確保（200×100セル）
    var cellBuffer = CellBuffer(width: 200, height: 100)

    // ステップ2: CellBufferに描画
    // 注意：ここでは(0,0)を原点として描画
    // 後で正しい位置にコピーする
    paintCells(origin: (0, 0), into: &cellBuffer)

    // ステップ3: CellBufferをANSIエスケープ付き文字列に変換
    // 各セルの情報（文字、色）がANSIコードに変換される
    let lines = cellBuffer.toANSILines()

    // ステップ4: Stringバッファにマージ
    for (index, line) in lines.enumerated() {
      let row = origin.y + index  // 実際の描画行位置

      // 画面範囲内のチェック
      if row >= 0 {
        // 必要ならバッファを拡張（行を追加）
        while buffer.count <= row {
          buffer.append("")
        }

        // 空白のみの行はスキップ（最適化）
        if !line.trimmingCharacters(in: .whitespaces).isEmpty {
          // bufferWrite関数で正しい位置に描画
          // ANSIエスケープシーケンスも正しく処理される
          bufferWrite(row: row, col: origin.x, text: line, into: &buffer)
        }
      }
    }
  }
}

/// セルベースレンダリングへの移行を容易にするアダプター
///
/// CellLayoutAdapterの役割：
/// - 既存のLayoutViewをCellLayoutViewに変換
/// - 既存コードを変更せずにセルベース描画を利用可能
/// - 段階的な移行をサポート
///
/// 使用例：
/// ```swift
/// let oldView: LayoutView = TextLayoutView("Hello")
/// let cellView = CellLayoutAdapter(oldView)
/// // cellViewはセルベース描画が可能に
/// ```
///
/// TUI初心者向け解説：
/// - アダプターパターンの一種
/// - 既存のインターフェースを新しいインターフェースに適合
public struct CellLayoutAdapter: CellLayoutView {
  /// ラップする元のLayoutView
  let wrapped: any LayoutView

  public init(_ layoutView: any LayoutView) {
    self.wrapped = layoutView
  }

  /// Yogaノードの作成は元のLayoutViewに委譲
  public func makeNode() -> YogaNode {
    wrapped.makeNode()
  }

  /// 既存のpaint()メソッドをCellBuffer用に変換
  ///
  /// 処理の流れ：
  /// 1. 元のLayoutViewのpaint()を呼び出し
  /// 2. Stringバッファに描画させる
  /// 3. StringバッファをCellBufferに変換
  ///
  /// 注意点：
  /// - 元のLayoutViewはpaint()で絶対座標を期待する可能性
  /// - そのため、一旦(0,0)で描画してからコピー
  public func paintCells(origin: (x: Int, y: Int), into buffer: inout CellBuffer) {
    // ステップ1: Stringバッファに描画
    var stringBuffer: [String] = []
    wrapped.paint(origin: (0, 0), into: &stringBuffer)

    // ステップ2: StringからCellBufferに変換
    for (row, line) in stringBuffer.enumerated() {
      if !line.isEmpty {
        // bufferWriteCellはANSIエスケープを解析して
        // 各セルに適切な文字と色を設定
        bufferWriteCell(
          row: origin.y + row,  // 正しい行位置
          col: origin.x,  // 正しい列位置
          text: line,
          into: &buffer
        )
      }
    }
  }

  /// キーボードイベント処理も元のLayoutViewに委譲
  public func handle(event: KeyboardEvent) -> Bool {
    wrapped.handle(event: event)
  }
}
