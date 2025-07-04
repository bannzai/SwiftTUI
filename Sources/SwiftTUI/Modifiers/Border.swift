import yoga

final class BorderView<Content: LayoutView>: LayoutView {

  private let inset: Float = 1
  private let child: Content

  init(_ c: Content) { child = c }

  // Yoga
  func makeNode() -> YogaNode {
    let n = YogaNode()
    n.setPadding(inset, .all)
    n.insert(child: child.makeNode())
    return n
  }

  // Paint
  func paint(origin:(x:Int,y:Int), into buf:inout [String]) {

    let n = makeNode()
    let f = n.frame                        // 子サイズ

    // ① 子ビューを描画
    if let raw = YGNodeGetChild(n.rawPtr, 0) {
      let dx = Int(YGNodeLayoutGetLeft(raw))
      let dy = Int(YGNodeLayoutGetTop (raw))
      child.paint(origin:(origin.x+dx, origin.y+dy), into:&buf)
    }

    // ② 枠線を bufferWrite だけで描く
    let horiz = String(repeating: "─", count: max(f.w, 0))
    bufferWrite(row: origin.y,
                col: origin.x,
                text: "┌" + horiz + "┐",
                into: &buf)

    bufferWrite(row: origin.y + f.h + 1,
                col: origin.x,
                text: "└" + horiz + "┘",
                into: &buf)

    if f.h > 0 {
      for dy in 1...f.h {
        bufferWrite(row: origin.y + dy,
                    col: origin.x,
                    text: "│",
                    into: &buf)
        bufferWrite(row: origin.y + dy,
                    col: origin.x + f.w + 1,
                    text: "│",
                    into: &buf)
      }
    }
  }

  // View 互換
  func render(into buffer: inout [String]) {}
}

// Modifier
public extension LayoutView {
  func border() -> some LayoutView { BorderView(self) }
}
