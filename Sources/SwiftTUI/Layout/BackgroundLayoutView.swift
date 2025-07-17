import yoga

/// 背景色を適用するLayoutView
internal struct BackgroundLayoutView: LayoutView {
  let color: Color
  let child: any LayoutView

  init(color: Color, child: any LayoutView) {
    self.color = color
    self.child = child
  }

  func makeNode() -> YogaNode {
    // 子ノードのサイズをそのまま使用
    return child.makeNode()
  }

  func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
    // 子ビューのサイズを取得
    let node = makeNode()
    if YGNodeLayoutGetWidth(node.rawPtr) == 0 {
      node.calculate(width: 80)
    }
    let width = Int(YGNodeLayoutGetWidth(node.rawPtr))
    let height = Int(YGNodeLayoutGetHeight(node.rawPtr))

    // 背景色の開始と終了のエスケープシーケンス
    let bgStart = "\u{1B}[\(color.bg)m"
    let bgEnd = "\u{1B}[0m"

    // 各行に背景色を適用
    for row in 0..<height {
      let y = origin.y + row

      // 行を確保
      while buffer.count <= y {
        buffer.append("")
      }

      // 背景色付きのスペースを描画（幅分）
      let spaces = String(repeating: " ", count: width)
      bufferWrite(row: y, col: origin.x, text: bgStart + spaces + bgEnd, into: &buffer)
    }

    // その上に子ビューを描画（背景色付き）
    var tempBuffer: [String] = []
    child.paint(origin: (0, 0), into: &tempBuffer)

    // 子ビューの内容を背景色付きで本バッファに転写
    for (index, line) in tempBuffer.enumerated() {
      if index < height {
        let y = origin.y + index
        if y >= 0 && y < buffer.count {
          // 各文字を背景色付きで描画
          var x = origin.x
          for char in line {
            if char != " " {
              // 空白以外の文字は背景色付きで描画
              bufferWrite(row: y, col: x, text: bgStart + String(char) + bgEnd, into: &buffer)
            }
            x += 1
          }
        }
      }
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

// 文字列の表示長を計算（ANSIエスケープシーケンスを除く）
private func calculateVisibleLength(_ text: String) -> Int {
  var length = 0
  var inEscape = false

  for char in text {
    if char == "\u{1B}" {
      inEscape = true
    } else if inEscape && char == "m" {
      inEscape = false
    } else if !inEscape {
      length += 1
    }
  }

  return length
}
