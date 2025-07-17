import yoga

/// Paddingを適用するLayoutView
internal final class PaddingLayoutView: LayoutView, CellLayoutView {
  let inset: Float
  let child: any LayoutView
  private var calculatedNode: YogaNode?

  init(inset: Float, child: any LayoutView) {
    self.inset = inset
    self.child = child
  }

  func makeNode() -> YogaNode {
    let node = YogaNode()
    node.setPadding(inset, .all)

    let childNode = child.makeNode()
    node.insert(child: childNode)

    self.calculatedNode = node
    return node
  }

  func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
    // Use the calculated node if available, otherwise create a new one
    let node = calculatedNode ?? makeNode()

    // If we don't have layout information, we need to calculate it
    if YGNodeLayoutGetWidth(node.rawPtr) == 0 {
      // Fallback: calculate with a default width
      node.calculate(width: 80)
    }

    // 子ノードの座標を取得
    if let raw = YGNodeGetChild(node.rawPtr, 0) {
      let dx = Int(YGNodeLayoutGetLeft(raw))
      let dy = Int(YGNodeLayoutGetTop(raw))
      child.paint(origin: (origin.x + dx, origin.y + dy), into: &buffer)
    }
  }

  func render(into buffer: inout [String]) {
    child.render(into: &buffer)
  }

  // MARK: - CellLayoutView

  func paintCells(origin: (x: Int, y: Int), into buffer: inout CellBuffer) {
    // Use the calculated node if available, otherwise create a new one
    let node = calculatedNode ?? makeNode()

    // If we don't have layout information, we need to calculate it
    if YGNodeLayoutGetWidth(node.rawPtr) == 0 {
      // Fallback: calculate with a default width
      node.calculate(width: Float(buffer.width))
    }

    // 子ノードの座標を取得
    if let raw = YGNodeGetChild(node.rawPtr, 0) {
      let dx = Int(YGNodeLayoutGetLeft(raw))
      let dy = Int(YGNodeLayoutGetTop(raw))

      if let cellChild = child as? CellLayoutView {
        cellChild.paintCells(origin: (origin.x + dx, origin.y + dy), into: &buffer)
      } else {
        // Fallback to regular paint if child doesn't support CellLayoutView
        var stringBuffer: [String] = []
        child.paint(origin: (origin.x + dx, origin.y + dy), into: &stringBuffer)
        // TODO: Convert stringBuffer to CellBuffer
      }
    }
  }
}
