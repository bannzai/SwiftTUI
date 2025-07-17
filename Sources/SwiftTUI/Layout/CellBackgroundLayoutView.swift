import yoga

/// セルベースの背景色レイアウトビュー
internal struct CellBackgroundLayoutView: CellLayoutView {
  let color: Color
  let child: any LayoutView

  init(color: Color, child: any LayoutView) {
    self.color = color
    self.child = child
  }

  func makeNode() -> YogaNode {
    // 子ノードのサイズをそのまま使用
    return child.makeNode()
  }

  func paintCells(origin: (x: Int, y: Int), into buffer: inout CellBuffer) {
    // 子ビューを先に描画して実際のサイズを取得
    var tempBuffer = CellBuffer(width: buffer.width, height: buffer.height)

    if let cellChild = child as? CellLayoutView {
      cellChild.paintCells(origin: (0, 0), into: &tempBuffer)
    } else {
      let adapter = CellLayoutAdapter(child)
      adapter.paintCells(origin: (0, 0), into: &tempBuffer)
    }

    // 実際に描画された範囲を計算
    var maxCol = 0
    var maxRow = 0
    for row in 0..<tempBuffer.height {
      for col in 0..<tempBuffer.width {
        if let cell = tempBuffer.getCell(row: row, col: col),
          cell.character != " " || cell.backgroundColor != nil || cell.foregroundColor != nil
        {
          maxCol = max(maxCol, col)
          maxRow = max(maxRow, row)
        }
      }
    }

    let width = maxCol + 1
    let height = maxRow + 1

    // 背景色を先に塗る
    bufferFillBackground(
      row: origin.y,
      col: origin.x,
      width: width,
      height: height,
      color: color,
      into: &buffer
    )

    // tempBufferの内容を実際の位置にコピー
    for row in 0..<height {
      for col in 0..<width {
        if let cell = tempBuffer.getCell(row: row, col: col) {
          buffer.mergeCell(row: origin.y + row, col: origin.x + col, newCell: cell)
        }
      }
    }
  }

  func render(into buffer: inout [String]) {
    child.render(into: &buffer)
  }

  func handle(event: KeyboardEvent) -> Bool {
    child.handle(event: event)
  }
}
