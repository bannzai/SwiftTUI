import yoga

final class BorderView<Content: LayoutView>: LayoutView {

  private let child: Content

  init(_ child: Content) { self.child = child }

  func makeNode() -> YogaNode {
    let n = YogaNode()
    // 枠線分 1px + 内側パディング
    n.setPadding(1, .all)
    n.insert(child: child.makeNode())
    return n
  }

  func paint(origin:(x:Int,y:Int), into buf:inout [String]) {
    let node = makeNode()
    // 1) まず子を描画
    if let raw = YGNodeGetChild(node.rawPtr, 0) {
      let dx = Int(YGNodeLayoutGetLeft(raw))
      let dy = Int(YGNodeLayoutGetTop (raw))
      child.paint(origin:(origin.x+dx,origin.y+dy), into:&buf)
    }
    // 2) 枠線を描画
    let f = node.frame
    // 水平線
    let topLine    = String(repeating: "─", count: f.w)
    let bottomLine = topLine
    drawLine(row: origin.y,              col: origin.x, text: "┌"+topLine+"┐", in:&buf)
    drawLine(row: origin.y+f.h+1,  col: origin.x, text: "└"+bottomLine+"┘", in:&buf)
    // 垂直
    for y in 1...f.h {
      drawLine(row: origin.y+y, col: origin.x,       text:"│", in:&buf)
      drawLine(row: origin.y+y, col: origin.x+f.w+1, text:"│", in:&buf)
    }
  }

  func render(into buffer: inout [String]) {}

  // helper
  private func drawLine(row:Int,col:Int,text:String,in buf:inout [String]){
    while buf.count<=row{ buf.append("") }
    if buf[row].count<col{ buf[row]+=String(repeating:" ",count:col-buf[row].count) }
    var line=buf[row]; let start=line.index(line.startIndex,offsetBy:col)
    if line.count<col+text.count{
      line+=String(repeating:" ",count:col+text.count-line.count)
    }
    line.replaceSubrange(start..<line.index(start,offsetBy:text.count), with:text)
    buf[row]=line
  }
}

// Modifier
public extension LayoutView {
  func border() -> some LayoutView { BorderView(self) }
}
