import yoga

final class Padding<Content: LayoutView>: LayoutView {

  private let inset: Float
  private let content: Content

  init(inset: Float, content: Content) {
    self.inset   = inset
    self.content = content
  }

  func makeNode() -> YogaNode {
    let n = YogaNode()
    n.setPadding(inset, .all)
    n.insert(child: content.makeNode())
    return n
  }

  func paint(origin: (x: Int, y: Int), into buf: inout [String]) {
    let inner = makeNode() // 同じインスタンス保証のため
    // PaddingView 自身は何も描かず子だけ描く
    let cnt = Int(YGNodeGetChildCount(inner.rawPtr))
    for i in 0..<cnt {
      let raw = YGNodeGetChild(inner.rawPtr, Int(i))!
      let dx  = Int(YGNodeLayoutGetLeft(raw))
      let dy  = Int(YGNodeLayoutGetTop(raw))
      content.paint(origin: (origin.x+dx, origin.y+dy), into: &buf)
    }
  }

  // View プロトコル互換
  func render(into buffer: inout [String]) {}
}

/// SwiftUI 風 Modifier
public extension LayoutView {
  func padding(_ inset: Float = 1) -> some LayoutView {
    Padding(inset: inset, content: self)
  }
}
