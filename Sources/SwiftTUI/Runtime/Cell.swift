/// Cell：ターミナルの1文字分の描画情報を表す構造体
///
/// セルベースレンダリングの核心となる型です。
/// ターミナルの各文字位置（セル）における：
/// - 表示する文字
/// - 文字の色（前景色）
/// - 背景色
/// - スタイル（太字、下線など）
/// を管理します。
///
/// TUI初心者向け解説：
/// - ターミナルはグリッド状に文字を配置
/// - 各グリッドのマスが「セル」
/// - Excelのセルと同じようなイメージ
///
/// なぜセル単位の管理が重要か：
/// - 文字列単位では背景色の制御が困難
/// - 部分的な更新が効率的に行える
/// - 複雑なレイアウトでも正確な描画
public struct Cell: Equatable {
  /// 表示する文字
  ///
  /// ターミナルに表示される1文字。
  /// 空白の場合はスペース文字（' '）を使用。
  public var character: Character

  /// 前景色（文字色）
  ///
  /// nilの場合はターミナルのデフォルト色を使用。
  /// SwiftTUIのColor型で指定。
  public var foregroundColor: Color?

  /// 背景色
  ///
  /// nilの場合は透明（ターミナルのデフォルト背景）。
  /// セル単位で背景色を管理できるのが大きなメリット。
  public var backgroundColor: Color?

  /// テキストスタイル
  ///
  /// TextStyleはOptionSetで、複数のスタイルを組み合わせ可能。
  /// 例：[.bold, .underline]
  public var style: TextStyle

  /// 空のセル（スペース）を作成
  ///
  /// デフォルトの空白セル。
  /// CellBufferの初期化時や、クリア時に使用される。
  ///
  /// 特徴：
  /// - 文字: スペース' '
  /// - 色: なし（デフォルト）
  /// - スタイル: なし
  public static var empty: Cell {
    Cell(character: " ", style: [])
  }

  /// Cellのイニシャライザ
  ///
  /// - Parameters:
  ///   - character: 表示する文字
  ///   - foregroundColor: 文字色（オプション）
  ///   - backgroundColor: 背景色（オプション）
  ///   - style: テキストスタイル（デフォルトは空）
  public init(
    character: Character,
    foregroundColor: Color? = nil,
    backgroundColor: Color? = nil,
    style: TextStyle = []
  ) {
    self.character = character
    self.foregroundColor = foregroundColor
    self.backgroundColor = backgroundColor
    self.style = style
  }

  /// ANSIエスケープシーケンス付きの文字列に変換
  ///
  /// セルの情報をターミナルが理解できるANSIコードに変換します。
  ///
  /// ANSIエスケープシーケンスとは：
  /// - \u{1B}[で始まる特殊な文字列
  /// - ターミナルに色やスタイルを指示
  /// - 例: \u{1B}[31m = 赤色、\u{1B}[1m = 太字
  ///
  /// 処理の流れ：
  /// 1. スタイル（太字、下線）を適用
  /// 2. 色（前景、背景）を適用
  /// 3. 文字を追加
  /// 4. スタイルをリセット（\u{1B}[0m）
  public func toANSI() -> String {
    var result = ""
    var hasStyle = false

    // ステップ1: スタイルの適用
    if style.contains(.bold) {
      result += "\u{1B}[1m"  // 1 = 太字
      hasStyle = true
    }
    if style.contains(.underline) {
      result += "\u{1B}[4m"  // 4 = 下線
      hasStyle = true
    }

    // ステップ2: 色の適用
    if let fg = foregroundColor {
      // fgプロパティは前景色用のANSIコードを返す
      // 例: .red.fg = "31"
      result += "\u{1B}[\(fg.fg)m"
      hasStyle = true
    }
    if let bg = backgroundColor {
      // bgプロパティは背景色用のANSIコードを返す
      // 例: .blue.bg = "44"
      result += "\u{1B}[\(bg.bg)m"
      hasStyle = true
    }

    // ステップ3: 文字を追加
    result += String(character)

    // ステップ4: スタイルのリセット
    // スタイルを適用した場合は、必ずリセット
    // これを忘れると、後続のテキストに影響が波及
    if hasStyle {
      result += "\u{1B}[0m"  // 0 = すべてのスタイルをリセット
    }

    return result
  }
}

/// CellBuffer：セルベースの画面バッファ
///
/// ターミナル画面全体をCellの2次元配列として管理します。
/// 各セルは独立して文字、色、スタイル情報を保持します。
///
/// 主な機能：
/// - セル単位での読み書き
/// - 文字列の一括書き込み
/// - セルのマージ（合成）
/// - ANSIエスケープ付き文字列への変換
///
/// TUI初心者向け解説：
/// - ターミナル画面をグリッド状に管理
/// - Excelのシートと同じような構造
/// - cells[row][col]で各セルにアクセス
public struct CellBuffer {
  /// 2次元配列でセルを管理
  ///
  /// cells[row][col]の形式でアクセス。
  /// - row: 上から下への行番号（0ベース）
  /// - col: 左から右への列番号（0ベース）
  private var cells: [[Cell]]

  /// バッファの幅（列数）
  ///
  /// 初期化時に固定され、変更できない。
  public let width: Int

  /// バッファの高さ（行数）
  ///
  /// 必要に応じて動的に拡張される。
  public var height: Int {
    return cells.count
  }

  /// 指定サイズで初期化
  ///
  /// - Parameters:
  ///   - width: バッファの幅（通常はターミナルの幅）
  ///   - height: バッファの初期高さ
  ///
  /// すべてのセルは.empty（空白）で初期化される。
  public init(width: Int, height: Int) {
    self.width = width
    // SwiftのArray(repeating:count:)を使って2次元配列を作成
    self.cells = Array(repeating: Array(repeating: .empty, count: width), count: height)
  }

  /// 行数を確保（必要に応じて拡張）
  ///
  /// 指定された高さまでバッファを拡張します。
  /// 新しい行は.emptyセルで埋められます。
  ///
  /// - Parameter height: 必要な最小高さ
  ///
  /// mutatingの意味：
  /// - 構造体の内容を変更するメソッド
  /// - Swiftの値型（struct）では明示的に必要
  public mutating func ensureHeight(_ height: Int) {
    while cells.count < height {
      // 空白行を追加
      cells.append(Array(repeating: .empty, count: width))
    }
  }

  /// セルを取得
  ///
  /// 指定位置のセルを取得します。
  /// 範囲外の場合はnilを返します。
  ///
  /// - Parameters:
  ///   - row: 行番号（0ベース）
  ///   - col: 列番号（0ベース）
  /// - Returns: 指定位置のセル、またはnil
  ///
  /// guard文の説明：
  /// - Swiftの早期リターン構文
  /// - 条件が満たされない場合、elseブロックを実行
  public func getCell(row: Int, col: Int) -> Cell? {
    guard row >= 0 && row < height && col >= 0 && col < width else {
      return nil
    }
    return cells[row][col]
  }

  /// セルを設定
  ///
  /// 指定位置にセルを設定します。
  /// 必要に応じてバッファを自動拡張します。
  ///
  /// - Parameters:
  ///   - row: 行番号（0ベース）
  ///   - col: 列番号（0ベース）
  ///   - cell: 設定するセル
  ///
  /// 注意点：
  /// - 列番号が幅を超える場合は無視
  /// - 行番号が高さを超える場合は自動拡張
  public mutating func setCell(row: Int, col: Int, cell: Cell) {
    guard row >= 0 && col >= 0 && col < width else { return }

    // 行数が不足している場合は拡張
    ensureHeight(row + 1)
    cells[row][col] = cell
  }

  /// 文字列を指定位置に書き込み
  ///
  /// 文字列全体を同じスタイルで書き込みます。
  /// 各文字が1つのセルに対応します。
  ///
  /// - Parameters:
  ///   - row: 開始行番号
  ///   - col: 開始列番号
  ///   - text: 書き込む文字列
  ///   - foregroundColor: 文字色（オプション）
  ///   - backgroundColor: 背景色（オプション）
  ///   - style: テキストスタイル
  ///
  /// 使用例：
  /// ```swift
  /// buffer.writeText(
  ///     row: 0, col: 0,
  ///     text: "Hello",
  ///     foregroundColor: .green,
  ///     style: [.bold]
  /// )
  /// ```
  public mutating func writeText(
    row: Int,
    col: Int,
    text: String,
    foregroundColor: Color? = nil,
    backgroundColor: Color? = nil,
    style: TextStyle = []
  ) {
    var currentCol = col

    // 文字列の各文字を1セルずつ書き込み
    for char in text {
      // バッファの右端を超えたら終了
      if currentCol >= width { break }

      // 各文字をセルに変換
      let cell = Cell(
        character: char,
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
        style: style
      )

      // セルを設定して次の列へ
      setCell(row: row, col: currentCol, cell: cell)
      currentCol += 1
    }
  }

  /// セルをマージ（既存のセルと新しいセルを合成）
  ///
  /// 複数のViewが同じ位置に描画しようとした場合の処理です。
  /// 背景色の上に文字を重ねる場合などに使用されます。
  ///
  /// - Parameters:
  ///   - row: 行番号
  ///   - col: 列番号
  ///   - newCell: マージする新しいセル
  public mutating func mergeCell(row: Int, col: Int, newCell: Cell) {
    guard let existingCell = getCell(row: row, col: col) else {
      // 既存のセルがない場合はそのまま設定
      setCell(row: row, col: col, cell: newCell)
      return
    }

    // マージルール（重要）：
    // 1. 文字：空白以外は新しい文字を優先
    //    → 背景の上に文字が表示される
    // 2. 前景色：新しい色があれば上書き
    //    → 最後に設定された色が有効
    // 3. 背景色：新しい色があれば上書き
    //    → 最後に設定された背景色が有効
    // 4. スタイル：OR演算で結合
    //    → 複数のスタイルが累積される

    var mergedCell = existingCell

    // 文字のマージ：空白以外は上書き
    if newCell.character != " " {
      mergedCell.character = newCell.character
    }

    // 前景色のマージ：新しい色があれば上書き
    if let newFg = newCell.foregroundColor {
      mergedCell.foregroundColor = newFg
    }

    // 背景色のマージ：新しい色があれば上書き
    if let newBg = newCell.backgroundColor {
      mergedCell.backgroundColor = newBg
    }

    // スタイルのマージ：OptionSetのunionで結合
    mergedCell.style = mergedCell.style.union(newCell.style)

    // マージしたセルを設定
    setCell(row: row, col: col, cell: mergedCell)
  }

  /// ANSIエスケープシーケンス付きの文字列配列に変換
  ///
  /// CellBufferをターミナルに表示可能な形式に変換します。
  /// 各セルの情報がANSIコード付き文字列に変換されます。
  ///
  /// 最適化：
  /// - 同じ背景色が続く場合はエスケープシーケンスを省略
  /// - 行末の空白は削除
  /// - 末尾の空行は削除
  ///
  /// - Returns: 各行がANSIコード付き文字列の配列
  public func toANSILines() -> [String] {
    var lines: [String] = []

    for (rowIndex, row) in cells.enumerated() {
      var line = ""
      var lastBg: Color? = nil  // 背景色の最適化用
      var hasContent = false  // 行に内容があるか

      // ステップ1: 行の最後の非空白文字を探す
      // 行末の不要な空白を削除するため
      var lastNonSpaceIndex = -1
      for (colIndex, cell) in row.enumerated() {
        if cell.character != " " {
          lastNonSpaceIndex = colIndex
          hasContent = true
        }
      }

      // ステップ2: 内容がある行のみ処理
      if hasContent || rowIndex < height {
        for (colIndex, cell) in row.enumerated() {
          // 行末の空白セルはスキップ
          // ただし、背景色がある場合は出力が必要
          if colIndex > lastNonSpaceIndex && cell.character == " " && cell.backgroundColor == nil {
            break
          }

          // ステップ3: 背景色の最適化
          // 同じ背景色が続く場合、エスケープシーケンスを省略
          if cell.backgroundColor != lastBg {
            // 背景色が変わった場合は完全なANSIコードを出力
            line += cell.toANSI()
            lastBg = cell.backgroundColor
          } else {
            // 背景色が同じ場合は省略版を出力
            var optimizedCell = cell
            optimizedCell.backgroundColor = nil  // 背景色を一時的にクリア
            line += optimizedCell.toANSI()
          }
        }
      }

      lines.append(line)
    }

    // ステップ4: 末尾の空行を削除
    // 不要なスクロールを避けるため
    while lines.count > 0 && lines[lines.count - 1].isEmpty {
      lines.removeLast()
    }

    return lines
  }
}
