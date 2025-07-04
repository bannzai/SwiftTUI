import yoga

// MARK: – Safe write 共通関数 ----------------------------------------------
private func safeWrite(row: Int, col: Int, text: String, into buf: inout [String]) {
  // 行確保
  while buf.count <= row { buf.append("") }

  // 行を配列化
  var line = Array(buf[row])

  // 左側スペース
  if line.count < col {
    line += Array(repeating: " ", count: col - line.count)
  }

  // 右側スペース
  let after = col + text.count
  if line.count < after {
    line += Array(repeating: " ", count: after - line.count)
  }

  // 上書き
  let t = Array(text)
  for i in 0..<t.count {
    line[col + i] = t[i]
  }
  buf[row] = String(line)
}

// MARK: – Padding + Border View --------------------------------------------
final class BorderView<Content: LayoutView>: LayoutView {

  private let inset: Float = 1          // 罫線分
  private let child: Content

  init(_ c: Content) { child = c }

  func makeNode() -> YogaNode {
    let n = YogaNode()
    n.setPadding(inset, .all)
    n.insert(child: child.makeNode())
    return n
  }

  func paint(origin:(x:Int,y:Int), into buf:inout [String]) {

    let n = makeNode()
    let f = n.frame                              // f.w, f.h は子サイズ

    // ① 子ビュー描画
    if let raw = YGNodeGetChild(n.rawPtr, 0) {
      let dx = Int(YGNodeLayoutGetLeft(raw))
      let dy = Int(YGNodeLayoutGetTop (raw))
      child.paint(origin:(origin.x+dx, origin.y+dy), into:&buf)
    }

    // ② 枠線
    let top    = String(repeating: "─", count: max(f.w,0))
    let bottom = top
    safeWrite(row: origin.y,
              col: origin.x,
              text: "┌" + top + "┐",
              into:&buf)

    safeWrite(row: origin.y + f.h + 1,
              col: origin.x,
              text: "└" + bottom + "┘",
              into:&buf)

    for y in 1...f.h {
      safeWrite(row: origin.y + y,
                col: origin.x,
                text: "│",
                into: &buf)
      safeWrite(row: origin.y + y,
                col: origin.x + f.w + 1,
                text: "│",
                into: &buf)
    }
  }

  // View プロトコル互換
  func render(into buffer: inout [String]) {}
}

// MARK: – Modifier
public extension LayoutView {
  func border() -> some LayoutView { BorderView(self) }
}
