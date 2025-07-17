import Foundation
import yoga

/// SwiftUIライクなProgressView
public struct ProgressView: View {
  let value: Double?
  let total: Double
  let label: String?
  private let id = UUID().uuidString

  public init(value: Double? = nil, total: Double = 1.0, label: String? = nil) {
    self.value = value
    self.total = total
    self.label = label
  }

  public init(_ label: String) {
    self.init(value: nil, total: 1.0, label: label)
  }

  public typealias Body = Never

  internal var _layoutView: any LayoutView {
    ProgressViewLayoutView(
      value: value,
      total: total,
      label: label,
      id: id
    )
  }
}

/// ProgressViewのLayoutView実装
internal class ProgressViewLayoutView: LayoutView {
  let value: Double?
  let total: Double
  let label: String?
  let id: String
  private var spinnerFrame = 0
  private var spinnerTimer: Timer?

  private let spinnerChars = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
  private let barWidth = 20  // プログレスバーの幅

  init(value: Double?, total: Double, label: String?, id: String) {
    self.value = value
    self.total = total
    self.label = label
    self.id = id

    // 不確定進捗の場合、スピナーアニメーションを開始
    if value == nil {
      startSpinnerAnimation()
    }
  }

  deinit {
    stopSpinnerAnimation()
  }

  // MARK: - Animation

  private func startSpinnerAnimation() {
    spinnerTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
      guard let self = self else { return }
      self.spinnerFrame = (self.spinnerFrame + 1) % self.spinnerChars.count
      CellRenderLoop.scheduleRedraw()
    }
  }

  private func stopSpinnerAnimation() {
    spinnerTimer?.invalidate()
    spinnerTimer = nil
  }

  // MARK: - LayoutView

  func makeNode() -> YogaNode {
    let node = YogaNode()

    if let label = label {
      // ラベル付きの場合
      if value != nil {
        // 確定進捗: ラベル + バー + パーセント
        let width = Float(label.count + 1 + barWidth + 2 + 5)  // ラベル + スペース + [バー] + スペース + "100%"
        node.setSize(width: width, height: 1)
      } else {
        // 不確定進捗: ラベル + スピナー
        let width = Float(label.count + 2)  // ラベル + スペース + スピナー
        node.setSize(width: width, height: 1)
      }
    } else {
      // ラベルなしの場合
      if value != nil {
        // 確定進捗: バーのみ
        let width = Float(barWidth + 2 + 5)  // [バー] + スペース + "100%"
        node.setSize(width: width, height: 1)
      } else {
        // 不確定進捗: スピナーのみ
        node.setSize(width: 1, height: 1)
      }
    }

    return node
  }

  func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
    var content = ""

    // ラベルを描画
    if let label = label {
      content += label + " "
    }

    if let value = value {
      // 確定進捗バーを描画
      let progress = min(max(value / total, 0), 1)
      let filledCount = Int(Double(barWidth) * progress)
      let emptyCount = barWidth - filledCount

      content += "["
      content += String(repeating: "█", count: filledCount)
      content += String(repeating: "░", count: emptyCount)
      content += "] "
      content += String(format: "%.0f%%", progress * 100)
    } else {
      // 不確定進捗スピナーを描画
      content += spinnerChars[spinnerFrame]
    }

    bufferWrite(row: origin.y, col: origin.x, text: content, into: &buffer)
  }

  func render(into buffer: inout [String]) {
    // LayoutViewプロトコルの要件
  }
}

// CellLayoutView対応
extension ProgressViewLayoutView: CellLayoutView {
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
