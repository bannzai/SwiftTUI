import yoga

/// セルベースのFlexStack実装
final class CellFlexStack: CellLayoutView {
  enum Axis { case column, row }

  /// アライメントタイプ
  enum Alignment {
    case start  // 上揃え（HStack）または左揃え（VStack）
    case center  // 中央揃え
    case end  // 下揃え（HStack）または右揃え（VStack）
  }

  private let axis: Axis
  private let children: [LegacyAnyView]
  private let spacing: Float
  private let alignment: Alignment
  private var calculatedNode: YogaNode?
  private var childNodes: [YogaNode] = []

  init(
    _ axis: Axis, spacing: Float = 0, alignment: Alignment = .center,
    @LegacyViewBuilder _ c: () -> [LegacyAnyView]
  ) {
    self.axis = axis
    self.spacing = spacing
    self.alignment = alignment
    self.children = c()
  }

  // MARK: YogaNode
  func makeNode() -> YogaNode {
    let n = YogaNode()
    n.flexDirection(axis == .column ? .column : .row)

    // Set gap (spacing) if specified
    if spacing > 0 {
      n.setGap(spacing, axis == .column ? .column : .row)
    }

    // Set align items based on alignment
    switch alignment {
    case .start:
      n.alignItems(.flexStart)
    case .center:
      n.alignItems(.center)
    case .end:
      n.alignItems(.flexEnd)
    }

    // DEBUG
    if CellRenderLoop.DEBUG {
      print("[CellFlexStack] makeNode called, axis: \(axis), children count: \(children.count)")
    }

    // 子ノードを作成して保持
    childNodes = children.enumerated().map { index, child in
      if CellRenderLoop.DEBUG {
        print("[CellFlexStack]   Creating child \(index), type: \(type(of: child))")
      }
      let node = child.makeNode()
      n.insert(child: node)
      
      if CellRenderLoop.DEBUG {
        print("[CellFlexStack]   Child \(index) node created: \(node.rawPtr)")
      }
      return node
    }

    self.calculatedNode = n
    return n
  }

  // MARK: Paint Cells
  func paintCells(origin: (x: Int, y: Int), into buffer: inout CellBuffer) {
    // Use the calculated node if available
    guard let node = calculatedNode else {
      // ノードが存在しない場合は何も描画しない
      if CellRenderLoop.DEBUG {
        print("[CellFlexStack] WARNING: No calculated node available")
      }
      return
    }

    // レイアウトが計算されていない場合も描画しない
    if YGNodeLayoutGetWidth(node.rawPtr) == 0 {
      if CellRenderLoop.DEBUG {
        print("[CellFlexStack] WARNING: Layout width is 0, skipping paint")
      }
      return
    }

    // Paint children at their calculated positions
    let cnt = Int(YGNodeGetChildCount(node.rawPtr))
    for i in 0..<cnt {
      guard let raw = YGNodeGetChild(node.rawPtr, Int(i)) else { continue }

      // Float値の安全な変換
      let left = YGNodeLayoutGetLeft(raw)
      let top = YGNodeLayoutGetTop(raw)

      // NaNやInfiniteのチェック
      guard left.isFinite && top.isFinite else { continue }

      let dx = Int(left.rounded())
      let dy = Int(top.rounded())
      let childOrigin = (x: origin.x + dx, y: origin.y + dy)

      // 子ビューを取得
      let child = children[i]

      // DEBUG
      if CellRenderLoop.DEBUG {
        let width = YGNodeLayoutGetWidth(raw)
        let height = YGNodeLayoutGetHeight(raw)
        print(
          "[CellFlexStack] Painting child \(i) at (\(childOrigin.x), \(childOrigin.y)), size: \(width)x\(height)"
        )
        print("[CellFlexStack]   Child type: \(type(of: child))")
      }

      // LegacyAnyViewは常にCellLayoutViewを実装している
      child.paintCells(origin: childOrigin, into: &buffer)
    }
  }

  // MARK: Legacy paint
  func paint(origin: (x: Int, y: Int), into buf: inout [String]) {
    // CellLayoutViewのデフォルト実装を使用
    var cellBuffer = CellBuffer(width: 200, height: 100)
    paintCells(origin: origin, into: &cellBuffer)

    let lines = cellBuffer.toANSILines()
    for (index, line) in lines.enumerated() {
      let row = origin.y + index
      if row >= 0 {
        while buf.count <= row { buf.append("") }
        buf[row] = line
      }
    }
  }

  // MARK: Render
  func render(into buffer: inout [String]) {
    for child in children {
      child.render(into: &buffer)
    }
  }
}
