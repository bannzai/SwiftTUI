import Foundation
import yoga

/// SwiftUIライクなSlider
public struct Slider<V: BinaryFloatingPoint>: View where V.Stride: BinaryFloatingPoint {
  @Binding var value: V
  let bounds: ClosedRange<V>
  let step: V.Stride?
  let label: String?
  private let id = UUID().uuidString

  public init(
    value: Binding<V>, in bounds: ClosedRange<V> = 0...1, step: V.Stride? = nil,
    label: String? = nil
  ) {
    self._value = value
    self.bounds = bounds
    self.step = step
    self.label = label
  }

  public typealias Body = Never

  internal var _layoutView: any LayoutView {
    SliderLayoutView(
      value: _value,
      bounds: bounds,
      step: step,
      label: label,
      id: id
    )
  }
}

// Double用の便利初期化
extension Slider where V == Double {
  public init(value: Binding<Double>, in bounds: ClosedRange<Double> = 0...1, label: String? = nil)
  {
    self.init(value: value, in: bounds, step: nil, label: label)
  }
}

/// SliderのLayoutView実装
internal class SliderLayoutView<V: BinaryFloatingPoint>: LayoutView, FocusableView
where V.Stride: BinaryFloatingPoint {
  let value: Binding<V>
  let bounds: ClosedRange<V>
  let step: V.Stride?
  let label: String?
  let id: String
  private var isFocused = false
  private let sliderWidth = 20  // スライダーバーの幅

  init(value: Binding<V>, bounds: ClosedRange<V>, step: V.Stride?, label: String?, id: String) {
    self.value = value
    self.bounds = bounds
    self.step = step
    self.label = label
    self.id = "Slider-\(label ?? id)"

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

    // ラベル + スライダー + 値表示
    let labelWidth = label?.count ?? 0
    let valueWidth = 8  // 値表示の最大幅（例: "100.00"）
    let totalWidth = labelWidth + (labelWidth > 0 ? 2 : 0) + sliderWidth + 2 + 1 + valueWidth
    let height: Float = isFocused ? 3 : 1

    node.setSize(width: Float(totalWidth), height: height)
    return node
  }

  func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
    // 色設定
    let borderColor = isFocused ? "\u{1B}[94m" : ""  // 青（フォーカス時）
    let resetColor = "\u{1B}[0m"

    // 値を0-1の範囲に正規化
    let normalizedValue = Double(
      (value.wrappedValue - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound))
    let clampedValue = min(max(normalizedValue, 0), 1)
    let filledCount = Int(Double(sliderWidth) * clampedValue)
    let emptyCount = sliderWidth - filledCount

    // スライダーバーを作成
    let sliderBar =
      "[" + String(repeating: "█", count: filledCount) + String(repeating: "░", count: emptyCount)
      + "]"

    // 値の表示（小数点以下の桁数を調整）
    let valueString: String
    if V.self == Double.self || V.self == Float.self {
      valueString = String(format: "%.2f", Double(value.wrappedValue))
    } else {
      valueString = String(describing: value.wrappedValue)
    }

    if isFocused {
      // フォーカス時は枠線付き
      var contentWidth = sliderWidth + 2 + 1 + valueString.count
      if let label = label {
        contentWidth += label.count + 2
      }

      // 上の枠線
      let topBorder =
        borderColor + "┌" + String(repeating: "─", count: contentWidth) + "┐" + resetColor
      bufferWrite(row: origin.y, col: origin.x, text: topBorder, into: &buffer)

      // コンテンツ行
      var content = borderColor + "│" + resetColor
      if let label = label {
        content += label + ": "
      }
      content += borderColor + sliderBar + resetColor + " " + valueString
      content += borderColor + "│" + resetColor
      bufferWrite(row: origin.y + 1, col: origin.x, text: content, into: &buffer)

      // 下の枠線
      let bottomBorder =
        borderColor + "└" + String(repeating: "─", count: contentWidth) + "┘" + resetColor
      bufferWrite(row: origin.y + 2, col: origin.x, text: bottomBorder, into: &buffer)
    } else {
      // 通常時
      var content = ""
      if let label = label {
        content += label + ": "
      }
      content += borderColor + sliderBar + resetColor + " " + valueString
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
    case .left:
      // 値を減少
      adjustValue(by: -1)
      return true

    case .right:
      // 値を増加
      adjustValue(by: 1)
      return true

    case .home:
      // 最小値に設定
      value.wrappedValue = bounds.lowerBound
      return true

    case .end:
      // 最大値に設定
      value.wrappedValue = bounds.upperBound
      return true

    default:
      return false
    }
  }

  private func adjustValue(by direction: Int) {
    let range = bounds.upperBound - bounds.lowerBound

    if let step = step {
      // ステップが指定されている場合
      let stepValue = V(step)
      let newValue = value.wrappedValue + stepValue * V(direction)
      value.wrappedValue = min(max(newValue, bounds.lowerBound), bounds.upperBound)
    } else {
      // ステップが指定されていない場合は、範囲の1%を使用
      let increment = range * V(0.01)
      let newValue = value.wrappedValue + increment * V(direction)
      value.wrappedValue = min(max(newValue, bounds.lowerBound), bounds.upperBound)
    }
  }
}

// CellLayoutView対応
extension SliderLayoutView: CellLayoutView {
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
