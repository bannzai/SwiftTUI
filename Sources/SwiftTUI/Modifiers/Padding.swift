import yoga

final class PaddingView<Content: LayoutView>: LayoutView {

  private let inset: Float
  private let child: Content

  init(_ inset: Float, _ child: Content) {
    self.inset = inset
    self.child = child
  }

  func makeNode() -> YogaNode {
    let n = YogaNode()
    n.setPadding(inset, .all)
    n.insert(child: child.makeNode())
    return n
  }

  func paint(origin: (x: Int, y: Int), into buf: inout [String]) {
    let n = makeNode()  // 座標取得用
    if let raw = YGNodeGetChild(n.rawPtr, 0) {
      let dx = Int(YGNodeLayoutGetLeft(raw))
      let dy = Int(YGNodeLayoutGetTop(raw))
      child.paint(origin: (origin.x + dx, origin.y + dy), into: &buf)
    }
  }

  func render(into buffer: inout [String]) {}
}

// Modifier
extension LayoutView {
  public func padding(_ inset: Float = 1) -> some LayoutView {
    PaddingView(inset, self)
  }
}
