import yoga

// Sources/SwiftTUI/Primitives/FlexStack.swift

final class FlexStack: LayoutView {

  enum Axis { case column, row }
  private let axis: Axis
  private let children: [AnyView]

  // --- ここを変更 -------------------------------------------------------
  private var laidOutNode: YogaNode?   // ← 計算済みノードを保持
  // --------------------------------------------------------------------

  init(_ axis: Axis, @ViewBuilder _ c: () -> [AnyView]) {
    self.axis = axis
    self.children = c()
  }

  // MARK: YogaNode
  func makeNode() -> YogaNode {
    let n = YogaNode()
    n.flexDirection(axis == .column ? .column : .row)
    children.forEach { n.insert(child: $0.makeNode()) }
    return n
  }

  // MARK: Paint
  func paint(origin: (x: Int, y: Int), into buf: inout [String]) {

    // ① まだ計算していない or @State で無効化 → レイアウトする
    if laidOutNode == nil {
      let n = makeNode()
      n.calculate()                 // ★ この1回だけ
      laidOutNode = n
    }
    guard let node = laidOutNode else { return }

    // ② 確定座標で描画
    let cnt = Int(YGNodeGetChildCount(node.rawPtr))
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
