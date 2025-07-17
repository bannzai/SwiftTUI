import yoga

/// Borderを適用するLayoutView
internal struct BorderLayoutView: LayoutView {
  let child: any LayoutView
  private let inset: Float = 1

  init(child: any LayoutView) {
    self.child = child
  }

  func makeNode() -> YogaNode {
    let node = YogaNode()
    node.setPadding(inset, .all)

    let childNode = child.makeNode()
    node.insert(child: childNode)

    return node
  }

  func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
    // 座標の妥当性チェック
    guard origin.x >= 0, origin.y >= 0 else { return }

    // 1. 子ビューを描画（padding分のオフセット付き）
    // fputs("DEBUG: BorderLayoutView painting child at (\(origin.x + 1), \(origin.y + 1))\n", stderr)
    child.paint(origin: (origin.x + 1, origin.y + 1), into: &buffer)

    // 2. 描画されたコンテンツのサイズを推定
    var maxWidth = 0
    var contentLines = 0

    // Range作成前に境界チェック
    let startY = origin.y + 1
    if startY < buffer.count {
      for y in startY..<buffer.count {
        let line = buffer[y]
        if line.count > origin.x + 1 {
          // この行に実際のコンテンツがあるかチェック
          let lineContent = String(line.dropFirst(origin.x + 1))
          let trimmed = lineContent.trimmingCharacters(in: .whitespaces)
          if !trimmed.isEmpty {
            contentLines = y - origin.y
            // ANSIエスケープを除いた実際の幅を計算
            let strippedContent = stripANSI(lineContent).trimmingCharacters(in: .whitespaces)
            let visibleWidth = displayWidth(strippedContent)
            // if y == origin.y + 1 {  // 最初の行をデバッグ
            //     fputs("DEBUG: BorderLayoutView y=\(y), line='\(line.replacingOccurrences(of: "\u{1B}", with: "\\e"))'\n", stderr)
            //     fputs("DEBUG: BorderLayoutView lineContent='\(lineContent.replacingOccurrences(of: "\u{1B}", with: "\\e"))'\n", stderr)
            //     fputs("DEBUG: BorderLayoutView stripped='\(strippedContent)', visibleWidth=\(visibleWidth)\n", stderr)
            // }
            maxWidth = max(maxWidth, visibleWidth)
          }
        }
      }
    }

    // 最小サイズを確保
    if contentLines == 0 { contentLines = 1 }
    if maxWidth == 0 { maxWidth = 5 }  // 最小幅

    // fputs("DEBUG: BorderLayoutView origin=(\(origin.x),\(origin.y)), maxWidth=\(maxWidth), contentLines=\(contentLines)\n", stderr)

    // 枠線を描画
    let horiz = String(repeating: "─", count: maxWidth + 2)  // +2 for padding

    bufferWrite(
      row: origin.y,
      col: origin.x,
      text: "┌" + horiz + "┐",
      into: &buffer)

    bufferWrite(
      row: origin.y + contentLines + 1,
      col: origin.x,
      text: "└" + horiz + "┘",
      into: &buffer)

    for yOff in 1...contentLines {
      let leftCol = origin.x
      let rightCol = origin.x + maxWidth + 3
      // fputs("DEBUG: BorderLayoutView drawing vertical lines at row=\(origin.y + yOff), leftCol=\(leftCol), rightCol=\(rightCol)\n", stderr)
      bufferWrite(
        row: origin.y + yOff,
        col: leftCol,
        text: "│",
        into: &buffer)
      bufferWrite(
        row: origin.y + yOff,
        col: rightCol,
        text: "│",
        into: &buffer)
    }
  }

  func render(into buffer: inout [String]) {
    child.render(into: &buffer)
  }
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

// 文字列の表示幅を計算（日本語文字は幅2）
private func displayWidth(_ str: String) -> Int {
  var width = 0
  for char in str {
    let scalar = char.unicodeScalars.first?.value ?? 0
    // 日本語文字（CJK統合漢字、ひらがな、カタカナなど）は幅2
    if scalar > 0x7F {
      width += 2
    } else {
      width += 1
    }
  }
  return width
}
