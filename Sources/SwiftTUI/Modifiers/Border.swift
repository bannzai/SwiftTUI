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
  /// row 行 col 列に `text` を埋め込む（UTF-8 セーフ & 境界安全）
  private func drawLine(row: Int, col: Int, text: String, in buf: inout [String]) {

    // ① 対象行を確保
    while buf.count <= row { buf.append("") }

    // ② 行を取得し必要分スペース拡張
    var line = buf[row]
    if line.count < col {                       // 左側が足りない
      line += String(repeating: " ", count: col - line.count)
    }
    let after = col + text.count
    if line.count < after {                     // 右側が足りない
      line += String(repeating: " ", count: after - line.count)
    }

    // ③ 文字列 → Character 配列へ
    var chars = Array(line)
    let txtChars = Array(text)

    // ④ text を上書き
    for (i, ch) in txtChars.enumerated() {
      chars[col + i] = ch
    }

    // ⑤ 行を戻す
    buf[row] = String(chars)
  }
}

// Modifier
public extension LayoutView {
  func border() -> some LayoutView { BorderView(self) }
}
