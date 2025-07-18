/// TextField：TUIのテキスト入力フィールドコンポーネント
///
/// キーボードでテキストを入力できるフィールドです。
/// SwiftUIと同様の@Bindingを使用して値を管理します。
///
/// 使用例：
/// ```swift
/// @State private var name = ""
///
/// TextField("名前を入力", text: $name)
/// ```
///
/// TUI初心者向け解説：
/// - GUIと違いマウスクリックではなくTabキーでフォーカス
/// - カーソルは反転表示（背景色を白に）で示す
/// - 矢印キーでカーソル移動、Backspace/Deleteで削除
///
/// 実装の特徴：
/// - @Bindingで親ビューと値を同期
/// - プレースホルダー（ヒントテキスト）表示
/// - カーソル位置の管理と表示

import Foundation

/// SwiftUIライクなTextField
public struct TextField: View {
  /// 入力が空のときに表示されるヒントテキスト
  private let placeholder: String

  /// 入力されたテキストのバインディング
  /// @Bindingの説明：
  /// - 親ビューの@State変数への参照
  /// - 値の変更が即座に親に伝わる
  /// - $記号でバインディングを作成
  @Binding var text: String

  /// フィールドを一意に識別するID
  private let id = UUID().uuidString

  /// TextFieldのイニシャライザ
  ///
  /// - Parameters:
  ///   - placeholder: プレースホルダーテキスト
  ///   - text: テキストのバインディング
  ///
  /// _textの説明：
  /// - @Bindingプロパティラッパーの内部プロパティ
  /// - アンダースコア付きでアクセス
  public init(_ placeholder: String, text: Binding<String>) {
    self.placeholder = placeholder
    self._text = text
  }

  /// TextFieldはプリミティブView
  /// bodyプロパティを持たず、直接LayoutViewに変換される
  public typealias Body = Never

  /// ViewRendererが使用する内部プロパティ
  /// TextFieldLayoutViewを直接作成して返す
  internal var _layoutView: any LayoutView {
    TextFieldLayoutView(
      placeholder: placeholder,
      text: _text,
      id: id
    )
  }
}

/// TextFieldのLayoutView実装
///
/// テキストフィールドの実際の描画と入力処理を担当するクラス。
/// 複数のプロトコルを実装：
/// - LayoutView: レイアウト計算
/// - CellLayoutView: セルベース描画
/// - FocusableView: フォーカス管理とキー入力
///
/// TUI初心者向け解説：
/// - カーソル位置の管理が重要
/// - 文字の挿入・削除でStringのindex操作
/// - フォーカス時に枠線の色が変わる
internal class TextFieldLayoutView: LayoutView, CellLayoutView, FocusableView {
  /// プレースホルダーテキスト
  let placeholder: String

  /// 入力テキストのバインディング
  let text: Binding<String>

  /// フィールドの一意識別子
  let id: String

  /// 現在のフォーカス状態
  /// trueのとき青い枠で表示
  private var isFocused = false

  /// カーソル位置（文字数での位置）
  /// 0 = 先頭、text.count = 末尾
  private var cursorPosition = 0

  /// TextFieldLayoutViewのイニシャライザ
  ///
  /// テキストフィールドの表示と入力に必要な情報を初期化します。
  ///
  /// - Parameters:
  ///   - placeholder: プレースホルダーテキスト
  ///   - text: テキストのバインディング
  ///   - id: フィールドの一意識別子
  init(placeholder: String, text: Binding<String>, id: String) {
    self.placeholder = placeholder
    self.text = text
    self.id = id

    // カーソル位置を文字列の最後に設定
    // ユーザーがすぐに入力を続けられるように
    self.cursorPosition = text.wrappedValue.count

    // FocusManagerに登録
    // acceptsInput: true = キーボード入力を受け付ける
    // これによりTabキーでフォーカス可能になる
    FocusManager.shared.register(self, id: id, acceptsInput: true)
  }

  /// デイニシャライザ
  ///
  /// フィールドが破棄されるときにクリーンアップを実行。
  /// FocusManagerから登録を解除してメモリリークを防ぐ。
  deinit {
    // FocusManagerから削除
    FocusManager.shared.unregister(id: id)
  }

  // MARK: - LayoutView

  /// Yogaノードの作成
  ///
  /// テキストフィールドのサイズを計算して設定します。
  /// テキストの長さに応じて幅が動的に変わります。
  ///
  /// サイズ計算の説明：
  /// - 幅: テキストの長さ + 4（枠線2 + パディング2）
  /// - 高さ: 3行（上枠 + テキスト + 下枠）
  func makeNode() -> YogaNode {
    let node = YogaNode()

    // 表示テキストの決定
    // 入力が空の場合はプレースホルダーを表示
    let displayText = text.wrappedValue.isEmpty ? placeholder : text.wrappedValue

    // フィールドの幅を計算
    // +4 = 左枠(1) + 左パディング(1) + 右パディング(1) + 右枠(1)
    // stringWidth()で実際の表示幅を計算（日本語文字は2幅）
    let width = Float(stringWidth(displayText) + 4)

    // サイズを設定
    node.setSize(width: width, height: 3)  // 枠線含めて3行
    node.setMinHeight(3)  // 最小高さを3行に固定

    return node
  }

  func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
    let displayText = text.wrappedValue.isEmpty ? placeholder : text.wrappedValue
    let displayWidth = stringWidth(displayText)  // 実際の表示幅を計算
    let isPlaceholder = text.wrappedValue.isEmpty

    // 枠線の色（フォーカス時は青、非フォーカス時はグレー）
    let borderColor = isFocused ? "\u{1B}[94m" : "\u{1B}[90m"  // 青 or グレー
    let resetColor = "\u{1B}[0m"

    // テキストの色（プレースホルダーはグレー）
    let textColor = isPlaceholder ? "\u{1B}[90m" : ""

    // 上の枠線
    let topBorder =
      borderColor + "┌" + String(repeating: "─", count: displayWidth + 2) + "┐" + resetColor
    bufferWrite(row: origin.y, col: origin.x, text: topBorder, into: &buffer)

    // テキスト行
    var textLine = borderColor + "│" + resetColor + " "

    if isFocused && !isPlaceholder {
      // カーソル位置でテキストを分割
      let beforeCursor = String(text.wrappedValue.prefix(cursorPosition))
      let atCursor =
        cursorPosition < text.wrappedValue.count
        ? String(
          text.wrappedValue[
            text.wrappedValue.index(text.wrappedValue.startIndex, offsetBy: cursorPosition)])
        : " "
      let afterCursor =
        cursorPosition < text.wrappedValue.count - 1
        ? String(text.wrappedValue.suffix(text.wrappedValue.count - cursorPosition - 1))
        : ""

      // カーソル位置を反転表示
      textLine +=
        textColor + beforeCursor + "\u{1B}[7m" + atCursor + "\u{1B}[0m" + textColor + afterCursor
    } else {
      textLine += textColor + displayText + resetColor
    }

    // パディングを追加
    let actualTextWidth = stringWidth(text.wrappedValue)
    let remainingSpace = displayWidth - actualTextWidth
    if remainingSpace > 0 {
      textLine += String(repeating: " ", count: remainingSpace)
    }

    textLine += " " + borderColor + "│" + resetColor
    bufferWrite(row: origin.y + 1, col: origin.x, text: textLine, into: &buffer)

    // 下の枠線
    let bottomBorder =
      borderColor + "└" + String(repeating: "─", count: displayWidth + 2) + "┘" + resetColor
    bufferWrite(row: origin.y + 2, col: origin.x, text: bottomBorder, into: &buffer)
  }

  func render(into buffer: inout [String]) {
    // LayoutViewプロトコルの要件
  }

  // MARK: - CellLayoutView

  /// 文字インデックスから実際の表示位置を計算
  ///
  /// 日本語文字は2幅として計算する必要があるため、
  /// 文字インデックスと実際の画面座標は異なる
  ///
  /// - Parameter index: 文字列内のインデックス
  /// - Returns: 実際の表示位置（列数）
  private func getDisplayPosition(upTo index: Int) -> Int {
    let prefix = String(text.wrappedValue.prefix(index))
    return stringWidth(prefix)
  }

  /// セルバッファへの描画（メインの描画メソッド）
  ///
  /// テキストフィールドの枠線、テキスト、カーソルを描画します。
  ///
  /// 描画の流れ：
  /// 1. 枠線の描画（┌───┐
  ///              │   │
  ///              └───┘）
  /// 2. テキストの描画（プレースホルダーまたは入力値）
  /// 3. カーソルの描画（反転表示）
  func paintCells(origin: (x: Int, y: Int), into buffer: inout CellBuffer) {
    // 表示テキストの決定
    let displayText = text.wrappedValue.isEmpty ? placeholder : text.wrappedValue
    let displayWidth = stringWidth(displayText)  // 実際の表示幅を計算
    let isPlaceholder = text.wrappedValue.isEmpty

    // 枠線の色（フォーカス時は青、非フォーカス時は白）
    // フォーカスがあることを視覚的に示す
    let borderColor = isFocused ? Color.blue : Color.white

    // テキストの色（プレースホルダーは白）
    // プレースホルダーを薄く表示して区別
    let textColor = isPlaceholder ? Color.white : nil

    // 上の枠線
    buffer.setCell(
      row: origin.y, col: origin.x, cell: Cell(character: "┌", foregroundColor: borderColor))
    for i in 1...(displayWidth + 2) {
      buffer.setCell(
        row: origin.y, col: origin.x + i, cell: Cell(character: "─", foregroundColor: borderColor))
    }
    buffer.setCell(
      row: origin.y, col: origin.x + displayWidth + 3,
      cell: Cell(character: "┐", foregroundColor: borderColor))

    // テキスト行
    buffer.setCell(
      row: origin.y + 1, col: origin.x, cell: Cell(character: "│", foregroundColor: borderColor))
    buffer.setCell(row: origin.y + 1, col: origin.x + 1, cell: Cell(character: " "))

    if isFocused && !isPlaceholder {
      // フォーカスあり、かつ入力ありの場合
      // カーソル位置を反転表示で示す

      // カーソル位置でテキストを分割して表示
      var currentCol = origin.x + 2
      for (index, char) in text.wrappedValue.enumerated() {
        let charWidth = scalarWidth(char.unicodeScalars.first!)
        if index == cursorPosition {
          // カーソル位置は反転表示
          // 背景色を白、文字色を黒にして目立たせる
          buffer.setCell(
            row: origin.y + 1, col: currentCol,
            cell: Cell(
              character: char,
              foregroundColor: Color.black,
              backgroundColor: Color.white))
        } else {
          // 通常の文字表示
          buffer.setCell(
            row: origin.y + 1, col: currentCol,
            cell: Cell(
              character: char,
              foregroundColor: textColor))
        }
        currentCol += charWidth
      }

      // カーソルが文字列の最後にある場合
      // 空白を反転表示してカーソルを示す
      if cursorPosition == text.wrappedValue.count {
        let cursorDisplayPos = getDisplayPosition(upTo: cursorPosition)
        buffer.setCell(
          row: origin.y + 1, col: origin.x + 2 + cursorDisplayPos,
          cell: Cell(
            character: " ",
            foregroundColor: Color.black,
            backgroundColor: Color.white))
      }
    } else {
      // 通常のテキスト表示（プレースホルダーまたは非フォーカス時）
      var currentCol = origin.x + 2
      for char in displayText {
        let charWidth = scalarWidth(char.unicodeScalars.first!)
        buffer.setCell(
          row: origin.y + 1, col: currentCol,
          cell: Cell(
            character: char,
            foregroundColor: textColor))
        currentCol += charWidth
      }
    }

    buffer.setCell(
      row: origin.y + 1, col: origin.x + displayWidth + 2, cell: Cell(character: " "))
    buffer.setCell(
      row: origin.y + 1, col: origin.x + displayWidth + 3,
      cell: Cell(character: "│", foregroundColor: borderColor))

    // 下の枠線
    buffer.setCell(
      row: origin.y + 2, col: origin.x, cell: Cell(character: "└", foregroundColor: borderColor))
    for i in 1...(displayWidth + 2) {
      buffer.setCell(
        row: origin.y + 2, col: origin.x + i,
        cell: Cell(character: "─", foregroundColor: borderColor))
    }
    buffer.setCell(
      row: origin.y + 2, col: origin.x + displayWidth + 3,
      cell: Cell(character: "┘", foregroundColor: borderColor))
  }

  // MARK: - FocusableView

  /// フォーカス状態の設定
  ///
  /// FocusManagerから呼ばれ、フォーカス状態を更新します。
  func setFocused(_ focused: Bool) {
    isFocused = focused
  }

  /// キーボードイベントの処理
  ///
  /// フォーカスがあるときのみキーイベントを処理します。
  /// 文字入力、削除、カーソル移動などをサポートします。
  ///
  /// - Parameter event: キーボードイベント
  /// - Returns: イベントを処理したかtrue
  ///
  /// TUI初心者向け解説：
  /// - 文字入力: カーソル位置に挿入
  /// - Backspace: カーソルの前を削除
  /// - Delete: カーソル位置を削除
  /// - 矢印キー: カーソル移動
  func handleKeyEvent(_ event: KeyboardEvent) -> Bool {
    guard isFocused else { return false }

    switch event.key {
    case .char(let c), .character(let c):
      // 文字を挿入
      // String.Indexの説明：
      // - SwiftのStringは文字列の位置をIndexで管理
      // - offsetByで先頭からのオフセットを指定
      let index = text.wrappedValue.index(text.wrappedValue.startIndex, offsetBy: cursorPosition)
      text.wrappedValue.insert(c, at: index)
      cursorPosition += 1
      return true

    case .backspace:
      // カーソル位置の前の文字を削除
      // カーソルが先頭にある場合は何もしない
      if cursorPosition > 0 {
        let index = text.wrappedValue.index(
          text.wrappedValue.startIndex, offsetBy: cursorPosition - 1)
        text.wrappedValue.remove(at: index)
        cursorPosition -= 1  // カーソルも左に移動
      }
      return true

    case .delete:
      // カーソル位置の文字を削除
      // カーソルが末尾にある場合は何もしない
      if cursorPosition < text.wrappedValue.count {
        let index = text.wrappedValue.index(text.wrappedValue.startIndex, offsetBy: cursorPosition)
        text.wrappedValue.remove(at: index)
        // カーソル位置は変わらない
      }
      return true

    case .left:
      // カーソルを左に移動
      // 先頭で停止
      if cursorPosition > 0 {
        cursorPosition -= 1
      }
      return true

    case .right:
      // カーソルを右に移動
      // 末尾で停止
      if cursorPosition < text.wrappedValue.count {
        cursorPosition += 1
      }
      return true

    case .home:
      // カーソルを行頭に移動
      // ショートカットキー
      cursorPosition = 0
      return true

    case .end:
      // カーソルを行末に移動
      // ショートカットキー
      cursorPosition = text.wrappedValue.count
      return true

    default:
      return false
    }
  }
}
