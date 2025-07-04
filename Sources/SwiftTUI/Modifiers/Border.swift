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
    // 1. 子ビューを描画（padding分のオフセット付き）
    child.paint(origin:(origin.x + 1, origin.y + 1), into:&buf)
    
    // 2. 描画されたコンテンツのサイズを推定
    // バッファを走査して実際に描画された範囲を検出
    var maxWidth = 0
    var contentLines = 0
    
    for y in (origin.y + 1)..<buf.count {
      let line = buf[y]
      if line.count > origin.x + 1 {
        // この行に実際のコンテンツがあるかチェック
        let lineContent = String(line.dropFirst(origin.x + 1))
        let trimmed = lineContent.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
          contentLines = y - origin.y
          // ANSIエスケープを除いた実際の幅を計算
          let visibleWidth = stripANSI(lineContent).trimmingCharacters(in: .whitespaces).count
          maxWidth = max(maxWidth, visibleWidth)
        }
      }
    }
    
    // 最小サイズを確保
    if contentLines == 0 { contentLines = 1 }
    if maxWidth == 0 { maxWidth = 5 }  // 最小幅
    
    // 枠線を描画
    let horiz = String(repeating: "─", count: maxWidth + 2)  // +2 for padding
    
    bufferWrite(row: origin.y,
                col: origin.x,
                text: "┌" + horiz + "┐",
                into:&buf)
    
    bufferWrite(row: origin.y + contentLines + 1,
                col: origin.x,
                text: "└" + horiz + "┘",
                into:&buf)
    
    for yOff in 1...contentLines {
      bufferWrite(row: origin.y + yOff,
                  col: origin.x,
                  text: "│",
                  into:&buf)
      bufferWrite(row: origin.y + yOff,
                  col: origin.x + maxWidth + 3,
                  text: "│",
                  into:&buf)
    }
  }

  func render(into buffer: inout [String]) {}
}

// ANSIエスケープシーケンスを除去
private func stripANSI(_ str: String) -> String {
    var result = ""
    var inEscape = false
    
    for char in str {
        if char == "\u{1B}" {
            inEscape = true
        } else if inEscape && char == "m" {
            inEscape = false
        } else if !inEscape {
            result.append(char)
        }
    }
    
    return result
}

public extension LayoutView {
  func border() -> some LayoutView { BorderView(self) }
}