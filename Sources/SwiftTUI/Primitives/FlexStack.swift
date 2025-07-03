import Foundation
import yoga

struct FlexStack: LayoutView {

  enum Axis { case column, row }

  private let axis: Axis
  private let children: [AnyView]

  init(_ axis: Axis, @ViewBuilder _ content: () -> [AnyView]) {
    self.axis = axis
    self.children = content()
  }

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

  func paint(origin: (x: Int, y: Int), into buf: inout [String]) {
    var index = 0
    makeNode().rawPtr.pointee.forEachChild { rawChild in
      let childNode = YogaNodeWrapper(raw: rawChild)
      let frame = childNode.frame
      let childOrigin = (x: origin.x + frame.x,
                         y: origin.y + frame.y)

      let lv = children[index] as! LayoutView
      lv.paint(origin: childOrigin, into: &buf)
      index += 1
    }
  }
}

// Helper to walk raw pointers
private struct YogaNodeWrapper {
  let raw: YGNodeRef
  var frame: (x: Int, y: Int, w: Int, h: Int) {
    (Int(YGNodeLayoutGetLeft(raw)),
     Int(YGNodeLayoutGetTop(raw)),
     Int(YGNodeLayoutGetWidth(raw)),
     Int(YGNodeLayoutGetHeight(raw)))
  }
}

typealias HStack = FlexStack where Axis == .row
