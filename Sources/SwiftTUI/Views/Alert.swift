import Foundation
import yoga

/// シンプルなAlert表示（モーダルではなく、画面全体を置き換える）
public struct Alert: View {
  let title: String
  let message: String?
  let dismissAction: () -> Void
  private let id = UUID().uuidString

  public init(title: String, message: String? = nil, dismiss: @escaping () -> Void) {
    self.title = title
    self.message = message
    self.dismissAction = dismiss
  }

  public typealias Body = Never

  internal var _layoutView: any LayoutView {
    AlertLayoutView(
      title: title,
      message: message,
      dismissAction: dismissAction,
      id: id
    )
  }
}

/// AlertのLayoutView実装
internal class AlertLayoutView: LayoutView, FocusableView {
  let title: String
  let message: String?
  let dismissAction: () -> Void
  let id: String
  private var isFocused = true  // Alertは常にフォーカスを持つ

  init(title: String, message: String?, dismissAction: @escaping () -> Void, id: String) {
    self.title = title
    self.message = message
    self.dismissAction = dismissAction
    self.id = "Alert-\(id)"

    // FocusManagerに登録
    FocusManager.shared.register(self, id: self.id)
  }

  deinit {
    // FocusManagerから削除
    FocusManager.shared.unregister(id: id)
  }

  // MARK: - LayoutView

  func makeNode() -> YogaNode {
    let node = YogaNode()

    // アラートボックスのサイズを計算
    let titleWidth = stringWidth(title)
    let messageWidth = message.map { stringWidth($0) } ?? 0
    let maxWidth = max(titleWidth, messageWidth, 20) + 4  // パディング込み
    var height = 7  // タイトル + 枠線 + ボタン + パディング
    if message != nil {
      height += 2  // メッセージ分
    }

    node.setSize(width: Float(maxWidth), height: Float(height))
    return node
  }

  func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
    let borderColor = "\u{1B}[91m"  // 赤（警告色）
    let resetColor = "\u{1B}[0m"
    let boldStart = "\u{1B}[1m"
    let boldEnd = "\u{1B}[22m"

    let titleWidth = stringWidth(title)
    let messageWidth = message.map { stringWidth($0) } ?? 0
    let maxWidth = max(titleWidth, messageWidth, 20)

    var currentRow = origin.y

    // 上の枠線
    let topBorder =
      borderColor + "╔" + String(repeating: "═", count: maxWidth + 2) + "╗" + resetColor
    bufferWrite(row: currentRow, col: origin.x, text: topBorder, into: &buffer)
    currentRow += 1

    // タイトル行（中央寄せ）
    let titlePadding = (maxWidth - titleWidth) / 2
    let titleLine =
      borderColor + "║" + resetColor + String(repeating: " ", count: titlePadding + 1) + boldStart
      + title + boldEnd + String(repeating: " ", count: maxWidth - titleWidth - titlePadding + 1)
      + borderColor + "║" + resetColor
    bufferWrite(row: currentRow, col: origin.x, text: titleLine, into: &buffer)
    currentRow += 1

    // 区切り線
    let separator =
      borderColor + "╟" + String(repeating: "─", count: maxWidth + 2) + "╢" + resetColor
    bufferWrite(row: currentRow, col: origin.x, text: separator, into: &buffer)
    currentRow += 1

    // メッセージ行
    if let message = message {
      let messagePadding = (maxWidth - messageWidth) / 2
      let messageLine =
        borderColor + "║" + resetColor + String(repeating: " ", count: messagePadding + 1) + message
        + String(repeating: " ", count: maxWidth - messageWidth - messagePadding + 1) + borderColor
        + "║" + resetColor
      bufferWrite(row: currentRow, col: origin.x, text: messageLine, into: &buffer)
      currentRow += 1

      // メッセージ後の空行
      let emptyLine =
        borderColor + "║" + resetColor + String(repeating: " ", count: maxWidth + 2) + borderColor
        + "║" + resetColor
      bufferWrite(row: currentRow, col: origin.x, text: emptyLine, into: &buffer)
      currentRow += 1
    }

    // OKボタン（中央寄せ、フォーカス表示）
    let buttonText = "[ OK ]"
    let buttonTextWidth = stringWidth(buttonText)
    let buttonPadding = (maxWidth - buttonTextWidth) / 2
    let buttonBg = "\u{1B}[44m"  // 青背景
    let buttonLine =
      borderColor + "║" + resetColor + String(repeating: " ", count: buttonPadding + 1) + buttonBg
      + buttonText + resetColor
      + String(repeating: " ", count: maxWidth - buttonTextWidth - buttonPadding + 1) + borderColor
      + "║" + resetColor
    bufferWrite(row: currentRow, col: origin.x, text: buttonLine, into: &buffer)
    currentRow += 1

    // 下の枠線
    let bottomBorder =
      borderColor + "╚" + String(repeating: "═", count: maxWidth + 2) + "╝" + resetColor
    bufferWrite(row: currentRow, col: origin.x, text: bottomBorder, into: &buffer)
  }

  func render(into buffer: inout [String]) {
    // LayoutViewプロトコルの要件
  }

  // MARK: - FocusableView

  func setFocused(_ focused: Bool) {
    isFocused = focused
  }

  func handleKeyEvent(_ event: KeyboardEvent) -> Bool {
    switch event.key {
    case .enter, .space, .escape:
      // Enter、Space、ESCキーでアラートを閉じる
      dismissAction()
      return true
    default:
      return false
    }
  }
}

// CellLayoutView対応
extension AlertLayoutView: CellLayoutView {
  func paintCells(origin: (x: Int, y: Int), into buffer: inout CellBuffer) {
    // 一時的なString配列に描画してから変換
    var stringBuffer: [String] = []
    paint(origin: (0, 0), into: &stringBuffer)

    // String配列からCellBufferに変換
    for (row, line) in stringBuffer.enumerated() {
      if !line.isEmpty {
        bufferWriteCell(
          row: origin.y + row,
          col: origin.x,
          text: line,
          into: &buffer
        )
      }
    }
  }
}
