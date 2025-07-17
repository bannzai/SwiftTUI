import Foundation
import yoga

/// SwiftUIライクなToggle
public struct Toggle: View {
  @Binding var isOn: Bool
  let label: String
  private let id = UUID().uuidString

  public init(_ label: String, isOn: Binding<Bool>) {
    self.label = label
    self._isOn = isOn
  }

  public typealias Body = Never

  internal var _layoutView: any LayoutView {
    ToggleLayoutView(
      isOn: _isOn,
      label: label,
      id: id
    )
  }
}

/// ToggleのLayoutView実装
internal class ToggleLayoutView: LayoutView, FocusableView {
  let isOn: Binding<Bool>
  let label: String
  let id: String
  private var isFocused = false

  init(isOn: Binding<Bool>, label: String, id: String) {
    self.isOn = isOn
    self.label = label
    self.id = "Toggle-\(label)"

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
    // チェックボックス + スペース + ラベル + フォーカス時の枠線分
    let width = Float(3 + 1 + label.count + (isFocused ? 2 : 0))
    let height: Float = isFocused ? 3 : 1
    node.setSize(width: width, height: height)
    return node
  }

  func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
    // 色設定
    let checkboxColor = isFocused ? "\u{1B}[94m" : ""  // 青（フォーカス時）
    let checkmark = isOn.wrappedValue ? "✓" : " "
    let resetColor = "\u{1B}[0m"

    if isFocused {
      // フォーカス時は枠線付き
      let borderColor = "\u{1B}[94m"  // 青
      let contentWidth = 3 + 1 + label.count

      // 上の枠線
      let topBorder =
        borderColor + "┌" + String(repeating: "─", count: contentWidth) + "┐" + resetColor
      bufferWrite(row: origin.y, col: origin.x, text: topBorder, into: &buffer)

      // コンテンツ行
      let content =
        borderColor + "│" + resetColor + checkboxColor + "[" + checkmark + "]" + resetColor + " "
        + label + borderColor + "│" + resetColor
      bufferWrite(row: origin.y + 1, col: origin.x, text: content, into: &buffer)

      // 下の枠線
      let bottomBorder =
        borderColor + "└" + String(repeating: "─", count: contentWidth) + "┘" + resetColor
      bufferWrite(row: origin.y + 2, col: origin.x, text: bottomBorder, into: &buffer)
    } else {
      // 通常時
      let content = checkboxColor + "[" + checkmark + "]" + resetColor + " " + label
      bufferWrite(row: origin.y, col: origin.x, text: content, into: &buffer)
    }
  }

  func render(into buffer: inout [String]) {
    // LayoutViewプロトコルの要件
  }

  // MARK: - FocusableView

  func setFocused(_ focused: Bool) {
    isFocused = focused
  }

  func handleKeyEvent(_ event: KeyboardEvent) -> Bool {
    guard isFocused else { return false }

    switch event.key {
    case .enter, .space:
      // EnterまたはSpaceキーで値を切り替え
      isOn.wrappedValue.toggle()
      return true
    default:
      return false
    }
  }
}

// CellLayoutView対応
extension ToggleLayoutView: CellLayoutView {
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
