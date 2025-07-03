import yoga

/// 汎用 Flexbox Stack
final class FlexStack: LayoutView {

  enum Axis { case column, row }
  private let axis: Axis
  private let children: [AnyView]
  private var cached: YogaNode?          // キャッシュ

  init(_ axis: Axis, @ViewBuilder _ c: () -> [AnyView]) {
    self.axis = axis
    self.children = c()
  }

  // MARK: - Yoga
  func makeNode() -> YogaNode {
    if let n = cached { return n }
    let n = YogaNode()
    n.flexDirection(axis == .column ? .column : .row)
    children.forEach { n.insert(child: $0.makeNode()) }
    cached = n
    return n
  }

  // MARK: - Paint
  func paint(origin: (x: Int, y: Int), into buf: inout [String]) {
    let node = makeNode()                 // 既に calculate 済み
    let cnt  = Int(YGNodeGetChildCount(node.rawPtr))
    for i in 0..<cnt {
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
