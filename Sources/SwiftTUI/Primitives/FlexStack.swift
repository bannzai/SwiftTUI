import yoga

/// 汎用 Flexbox Stack
// Sources/SwiftTUI/Primitives/FlexStack.swift

struct FlexStack: LayoutView {

  enum Axis { case column, row }
  private let axis: Axis
  private let children: [AnyView]

  init(_ axis: Axis, @ViewBuilder _ content: () -> [AnyView]) {
    self.axis = axis
    self.children = content()
  }

  // --- Yoga node --------------------------------------------------------
  func makeNode() -> YogaNode {
    let node = YogaNode()
    node.flexDirection(axis == .column ? .column : .row)

    for child in children {
      node.insert(child: child.makeNode())
    }
    return node
  }

  // --- Paint ------------------------------------------------------------
  func paint(origin: (x: Int, y: Int), into buf: inout [String]) {

    let root = makeNode()
    root.calculate()                              // ① レイアウト確定

    let count = Int(YGNodeGetChildCount(root.rawPtr))
    for i in 0..<count {
      guard let childRaw = YGNodeGetChild(root.rawPtr, Int(i)) else { continue }

      // 子のレイアウト結果を取得
      let cx = Int(YGNodeLayoutGetLeft(childRaw))
      let cy = Int(YGNodeLayoutGetTop(childRaw))

      // 同じ index の AnyView へ paint
      children[i].paint(origin: (origin.x + cx, origin.y + cy), into: &buf)
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
