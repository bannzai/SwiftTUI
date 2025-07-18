import yoga

/// セルベースのText実装
internal struct CellText: CellLayoutView {
  let content: String
  var fgColor: Color? = nil
  var bgColor: Color? = nil
  var style: TextStyle = []

  init(_ content: String) {
    self.content = content
  }

  // SwiftUI-like modifiers
  func color(_ c: Color) -> Self {
    var s = self
    s.fgColor = c
    return s
  }

  func background(_ c: Color) -> Self {
    var s = self
    s.bgColor = c
    return s
  }

  func bold() -> Self {
    var s = self
    s.style.insert(.bold)
    return s
  }

  // MARK: YogaNode
  func makeNode() -> YogaNode {
    let n = YogaNode()
    n.setSize(width: Float(displayWidth()), height: 1)
    n.setMinHeight(1)
    return n
  }

  // MARK: CellLayoutView
  func paintCells(origin: (x: Int, y: Int), into buffer: inout CellBuffer) {
    // セルバッファに直接書き込み
    bufferWriteCell(
      row: origin.y,
      col: origin.x,
      text: content,
      foregroundColor: fgColor,
      backgroundColor: bgColor,
      style: style,
      into: &buffer
    )
  }

  // MARK: Legacy paint (CellLayoutViewのデフォルト実装を使用)
  func paint(origin: (x: Int, y: Int), into buf: inout [String]) {
    // CellLayoutViewのデフォルト実装が自動的に使われる
    var cellBuffer = CellBuffer(width: 200, height: 100)
    paintCells(origin: origin, into: &cellBuffer)

    let lines = cellBuffer.toANSILines()
    for (index, line) in lines.enumerated() {
      let row = origin.y + index
      if row >= 0 {
        while buf.count <= row { buf.append("") }
        bufferWrite(row: row, col: origin.x, text: line, into: &buf)
      }
    }
  }

  // MARK: Helpers
  private func displayWidth() -> Int {
    // StringWidth.swiftの正確な文字幅計算関数を使用
    return stringWidth(content)
  }
}
