import yoga

/// 汎用 Flexbox Stack
struct FlexStack: LayoutView {

  enum Axis { case column, row }
  private let axis: Axis
  private let children: [AnyView]

  init(_ axis: Axis, @ViewBuilder _ content: () -> [AnyView]) {
    self.axis = axis
    self.children = content()
  }

  // MARK: Yoga node
  func makeNode() -> YogaNode {
    let node = YogaNode()
    node.flexDirection(axis == .column ? YGFlexDirection.column
                       : YGFlexDirection.row)
    for child in children {
      if let lv = child as? LayoutView {
        node.insert(child: lv.makeNode())
      }
    }
    return node
  }

  // MARK: Paint
  func paint(origin: (x: Int, y: Int), into buf: inout [String]) {
    let root = makeNode()
    root.calculate()                               // 必ずレイアウト

    let count = Int(YGNodeGetChildCount(root.rawPtr))
    for i in 0..<count {
      guard let childRaw = YGNodeGetChild(root.rawPtr, Int(i)),
            let lv = children[i] as? LayoutView else { continue }

      let ox = origin.x + Int(YGNodeLayoutGetLeft(childRaw))
      let oy = origin.y + Int(YGNodeLayoutGetTop(childRaw))
      lv.paint(origin: (ox, oy), into: &buf)
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
