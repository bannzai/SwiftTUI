import Foundation
import yoga

/// Pickerで使用する選択肢を表すプロトコル
public protocol PickerOption {
  var label: String { get }
}

/// String用のPickerOption実装
extension String: PickerOption {
  public var label: String { self }
}

/// SwiftUIライクなPicker（簡易版）
public struct Picker<SelectionValue: Hashable>: View {
  @Binding var selection: SelectionValue
  let label: String
  let options: [(value: SelectionValue, label: String)]
  private let id = UUID().uuidString

  public init(
    _ label: String, selection: Binding<SelectionValue>,
    options: [(value: SelectionValue, label: String)]
  ) {
    self.label = label
    self._selection = selection
    self.options = options
  }

  public typealias Body = Never

  internal var _layoutView: any LayoutView {
    PickerLayoutView(
      selection: _selection,
      label: label,
      options: options,
      id: id
    )
  }
}

// String配列用の便利初期化
extension Picker where SelectionValue == String {
  public init(_ label: String, selection: Binding<String>, options: [String]) {
    self.init(label, selection: selection, options: options.map { ($0, $0) })
  }
}

// Int用の初期化は基本のinitで十分なので削除

/// PickerのLayoutView実装
internal class PickerLayoutView<SelectionValue: Hashable>: LayoutView, FocusableView {
  let selection: Binding<SelectionValue>
  let label: String
  let options: [(value: SelectionValue, label: String)]
  let id: String
  private var isFocused = false
  private var isExpanded = false
  private var highlightedIndex = 0

  init(
    selection: Binding<SelectionValue>, label: String,
    options: [(value: SelectionValue, label: String)], id: String
  ) {
    self.selection = selection
    self.label = label
    self.options = options
    self.id = "Picker-\(label)"

    // 現在の選択値のインデックスを見つける
    if let currentIndex = options.firstIndex(where: { $0.value == selection.wrappedValue }) {
      self.highlightedIndex = currentIndex
    }

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

    if isExpanded {
      // 展開時：ラベル + ドロップダウン + オプションリスト
      let maxOptionLength = options.map { stringWidth($0.label) }.max() ?? 0
      let width = Float(max(stringWidth(label) + 3 + maxOptionLength + 4, maxOptionLength + 4))
      let height = Float(1 + options.count + 2)  // ラベル行 + オプション数 + 枠線
      node.setSize(width: width, height: height)
    } else {
      // 折り畳み時：ラベル + 現在の選択値
      let currentLabel = options.first(where: { $0.value == selection.wrappedValue })?.label ?? ""
      let width = Float(stringWidth(label) + 3 + stringWidth(currentLabel) + 4)
      let height: Float = isFocused ? 3 : 1
      node.setSize(width: width, height: height)
    }

    return node
  }

  func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
    let currentLabel = options.first(where: { $0.value == selection.wrappedValue })?.label ?? ""
    let borderColor = isFocused ? "\u{1B}[94m" : "\u{1B}[90m"  // 青（フォーカス時）またはグレー
    let resetColor = "\u{1B}[0m"
    let arrow = isExpanded ? "▲" : "▼"

    if isExpanded {
      // 展開時の描画
      let labelLine =
        label + ": " + borderColor + "[" + currentLabel + " " + arrow + "]" + resetColor
      bufferWrite(row: origin.y, col: origin.x, text: labelLine, into: &buffer)

      // オプションリスト
      let maxWidth = options.map { stringWidth($0.label) }.max() ?? 0

      // 上枠線
      let topBorder =
        borderColor + "┌" + String(repeating: "─", count: maxWidth + 2) + "┐" + resetColor
      bufferWrite(
        row: origin.y + 1, col: origin.x + stringWidth(label) + 3, text: topBorder, into: &buffer)

      // オプション
      for (index, option) in options.enumerated() {
        let isHighlighted = index == highlightedIndex
        let highlightColor = isHighlighted ? "\u{1B}[7m" : ""  // 反転表示
        let optionText = option.label.padding(toLength: maxWidth, withPad: " ", startingAt: 0)
        let line =
          borderColor + "│" + resetColor + highlightColor + " " + optionText + " " + resetColor
          + borderColor + "│" + resetColor
        bufferWrite(
          row: origin.y + 2 + index, col: origin.x + stringWidth(label) + 3, text: line,
          into: &buffer)
      }

      // 下枠線
      let bottomBorder =
        borderColor + "└" + String(repeating: "─", count: maxWidth + 2) + "┘" + resetColor
      bufferWrite(
        row: origin.y + 2 + options.count, col: origin.x + stringWidth(label) + 3,
        text: bottomBorder,
        into: &buffer)
    } else if isFocused {
      // フォーカス時（折り畳み）
      let contentWidth = stringWidth(label) + 3 + stringWidth(currentLabel) + 3

      // 上の枠線
      let topBorder =
        borderColor + "┌" + String(repeating: "─", count: contentWidth) + "┐" + resetColor
      bufferWrite(row: origin.y, col: origin.x, text: topBorder, into: &buffer)

      // コンテンツ行
      let content =
        borderColor + "│" + resetColor + label + ": [" + currentLabel + " " + arrow + "]"
        + borderColor + "│" + resetColor
      bufferWrite(row: origin.y + 1, col: origin.x, text: content, into: &buffer)

      // 下の枠線
      let bottomBorder =
        borderColor + "└" + String(repeating: "─", count: contentWidth) + "┘" + resetColor
      bufferWrite(row: origin.y + 2, col: origin.x, text: bottomBorder, into: &buffer)
    } else {
      // 通常時
      let content = label + ": [" + currentLabel + " " + arrow + "]"
      bufferWrite(row: origin.y, col: origin.x, text: content, into: &buffer)
    }
  }

  func render(into buffer: inout [String]) {
    // LayoutViewプロトコルの要件
  }

  // MARK: - FocusableView

  func setFocused(_ focused: Bool) {
    isFocused = focused
    if !focused {
      isExpanded = false
    }
  }

  func handleKeyEvent(_ event: KeyboardEvent) -> Bool {
    guard isFocused else { return false }

    switch event.key {
    case .enter, .space:
      if isExpanded {
        // 選択を確定
        if highlightedIndex < options.count {
          selection.wrappedValue = options[highlightedIndex].value
        }
        isExpanded = false
      } else {
        // ドロップダウンを開く
        isExpanded = true
        // 現在の選択値をハイライト
        if let currentIndex = options.firstIndex(where: { $0.value == selection.wrappedValue }) {
          highlightedIndex = currentIndex
        }
      }
      return true

    case .up:
      if isExpanded && highlightedIndex > 0 {
        highlightedIndex -= 1
      }
      return true

    case .down:
      if isExpanded && highlightedIndex < options.count - 1 {
        highlightedIndex += 1
      }
      return true

    case .escape:
      if isExpanded {
        isExpanded = false
        return true
      }
      return false

    default:
      return false
    }
  }
}

// CellLayoutView対応
extension PickerLayoutView: CellLayoutView {
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
