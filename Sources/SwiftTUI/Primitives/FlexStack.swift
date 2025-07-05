import yoga

// Sources/SwiftTUI/Primitives/FlexStack.swift

final class FlexStack: LayoutView {

  enum Axis { case column, row }
  private let axis: Axis
  private let children: [LegacyAnyView]
  private var calculatedNode: YogaNode?

  init(_ axis: Axis, @LegacyViewBuilder _ c: () -> [LegacyAnyView]) {
    self.axis = axis
    self.children = c()
  }

  // MARK: YogaNode
  func makeNode() -> YogaNode {
    let n = YogaNode()
    n.flexDirection(axis == .column ? .column : .row)
    children.forEach { n.insert(child: $0.makeNode()) }
    self.calculatedNode = n
    return n
  }

  // MARK: Paint
  func paint(origin: (x: Int, y: Int), into buf: inout [String]) {
    // Use the calculated node if available, otherwise create a new one
    let node = calculatedNode ?? makeNode()
    
    // If we don't have layout information, we need to calculate it
    if YGNodeLayoutGetWidth(node.rawPtr) == 0 {
      // Fallback: calculate with a default width
      node.calculate(width: 80)
    }
    
    // Paint children at their calculated positions
    let cnt = Int(YGNodeGetChildCount(node.rawPtr))
    for i in 0..<cnt {
      guard let raw = YGNodeGetChild(node.rawPtr, Int(i)) else { continue }
      let dx = Int(YGNodeLayoutGetLeft(raw))
      let dy = Int(YGNodeLayoutGetTop(raw))
      children[i].paint(origin: (origin.x + dx, origin.y + dy), into: &buf)
    }
  }
  
  // MARK: Render
  func render(into buffer: inout [String]) {
    // Render each child
    for child in children {
      child.render(into: &buffer)
    }
  }
}


// ---------- SwiftUI 風ラッパ ----------

public struct LegacyVStack: LayoutView {
  private let stack: FlexStack
  public init(@LegacyViewBuilder _ c: () -> [LegacyAnyView]) { stack = FlexStack(.column, c) }
  public func makeNode() -> YogaNode { stack.makeNode() }
  public func paint(origin: (x: Int, y: Int), into buf: inout [String]) {
    stack.paint(origin: origin, into: &buf)
  }
  public func render(into buffer: inout [String]) {
    stack.render(into: &buffer)
  }
}

public struct LegacyHStack: LayoutView {
  private let stack: FlexStack
  public init(@LegacyViewBuilder _ c: () -> [LegacyAnyView]) { stack = FlexStack(.row, c) }
  public func makeNode() -> YogaNode { stack.makeNode() }
  public func paint(origin: (x: Int, y: Int), into buf: inout [String]) {
    stack.paint(origin: origin, into: &buf)
  }
  public func render(into buffer: inout [String]) {
    stack.render(into: &buffer)
  }
}
