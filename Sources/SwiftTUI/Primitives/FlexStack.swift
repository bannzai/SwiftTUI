import yoga

/// 汎用 Flexbox Stack
final class FlexStack: LayoutView {

  enum Axis { case column, row }
  private let axis: Axis
  private let children: [AnyView]

  private var cachedNode: YogaNode?

  init(_ axis: Axis, @ViewBuilder _ content: () -> [AnyView]) {
    self.axis = axis
    self.children = content()
  }

  // MARK: Yoga
  func makeNode() -> YogaNode {
    if let n = cachedNode { return n }

    let n = YogaNode()
    n.flexDirection(axis == .column ? .column : .row)
    children.forEach { n.insert(child: $0.makeNode()) }
    cachedNode = n
    return n
  }

  // MARK: Paint
  func paint(origin: (x: Int, y: Int), into buf: inout [String]) {

    // ★ calculate() を 呼ばない  ← ここが修正点
    let node = makeNode()

    let count = Int(YGNodeGetChildCount(node.rawPtr))
    for i in 0..<count {
      guard let raw = YGNodeGetChild(node.rawPtr, Int(i)) else { continue }
      let dx = Int(YGNodeLayoutGetLeft(raw))
      let dy = Int(YGNodeLayoutGetTop(raw))
      children[i].paint(origin: (origin.x + dx, origin.y + dy), into: &buf)
    }
  }
}


// ---------- SwiftUI 風ラッパ ----------

public struct VStack: LayoutView {
  private let stack: FlexStack
  public init(@ViewBuilder _ c: () -> [AnyView]) { stack = FlexStack(.column, c) }
  public func makeNode() -> YogaNode { stack.makeNode() }
  public func paint(origin: (x: Int, y: Int), into buf: inout [String]) {
    stack.paint(origin: origin, into: &buf)
  }
}

public struct HStack: LayoutView {
  private let stack: FlexStack
  public init(@ViewBuilder _ c: () -> [AnyView]) { stack = FlexStack(.row, c) }
  public func makeNode() -> YogaNode { stack.makeNode() }
  public func paint(origin: (x: Int, y: Int), into buf: inout [String]) {
    stack.paint(origin: origin, into: &buf)
  }
}
