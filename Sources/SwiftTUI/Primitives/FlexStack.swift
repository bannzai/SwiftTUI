import yoga

/// 汎用 Flexbox Stack
// Sources/SwiftTUI/Primitives/FlexStack.swift

final class FlexStack: LayoutView {

  enum Axis { case column, row }
  private let axis: Axis
  private let children: [AnyView]

  // ① キャッシュ
  private var cachedNode: YogaNode?

  init(_ axis: Axis, @ViewBuilder _ content: () -> [AnyView]) {
    self.axis = axis
    self.children = content()
  }

  // --- Yoga node --------------------------------------------------------
  func makeNode() -> YogaNode {
    if let n = cachedNode { return n }             // ② 再利用

    let n = YogaNode()
    n.flexDirection(axis == .column ? .column : .row)
    for ch in children { n.insert(child: ch.makeNode()) }

    cachedNode = n                                 // ③ 保持して返す
    return n
  }

  // --- Paint ------------------------------------------------------------
  func paint(origin: (x: Int, y: Int), into buf: inout [String]) {
    let root = makeNode()
    root.calculate()                               // ← ここで layout 確定

    let cnt = Int(YGNodeGetChildCount(root.rawPtr))
    for i in 0..<cnt {
      guard let raw = YGNodeGetChild(root.rawPtr, Int(i)) else { continue }
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
