import yoga

final class BorderView<Content: LayoutView>: LayoutView {

  private let inset: Float = 1
  private let child: Content
  
  init(_ c: Content) { child = c }

  func makeNode() -> YogaNode {
    let n = YogaNode()
    n.setPadding(inset, .all)
    n.insert(child: child.makeNode())
    return n
  }

  func paint(origin:(x:Int,y:Int), into buf:inout [String]) {
    // Get node for layout information (already calculated by RenderLoop)
    let node = makeNode()
    let f = node.frame
    
    // Paint child with padding offset
    if let raw = YGNodeGetChild(node.rawPtr, 0) {
      let dx = Int(YGNodeLayoutGetLeft(raw))
      let dy = Int(YGNodeLayoutGetTop(raw))
      child.paint(origin:(origin.x + dx, origin.y + dy), into:&buf)
    }
    
    // Draw border using the calculated frame dimensions
    let horiz = String(repeating: "─", count: max(f.w, 0))
    bufferWrite(row: origin.y,           col: origin.x, text: "┌" + horiz + "┐", into:&buf)
    bufferWrite(row: origin.y + f.h + 1, col: origin.x, text: "└" + horiz + "┘", into:&buf)
    
    if f.h > 0 {
      for dy in 1...f.h {
        bufferWrite(row: origin.y + dy, col: origin.x,           text: "│", into:&buf)
        bufferWrite(row: origin.y + dy, col: origin.x + f.w + 1, text: "│", into:&buf)
      }
    }
  }

  func render(into buffer: inout [String]) {}
}

public extension LayoutView {
  func border() -> some LayoutView { BorderView(self) }
}