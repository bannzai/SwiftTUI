import yoga

/// 前景色を適用するLayoutView
internal struct ForegroundColorLayoutView: LayoutView {
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
    // 一時バッファに子を描画
    var tempBuffer = buffer
    child.paint(origin: origin, into: &tempBuffer)

    // 変更された部分に前景色を適用
    for (index, newLine) in tempBuffer.enumerated() {
      if index >= buffer.count || newLine != buffer[index] {
        // この行が変更された場合
        if index >= buffer.count {
          buffer.append(newLine)
        } else {
          // ANSIエスケープシーケンスで前景色を適用
          let colorCode = "\u{1B}[\(color.fg)m"
          let resetCode = "\u{1B}[0m"

          // 既存のエスケープシーケンスを保持しつつ、新しい色を適用
          var result = ""
          var i = 0
          while i < newLine.count {
            let char = newLine[newLine.index(newLine.startIndex, offsetBy: i)]

            // ESCシーケンスの開始を検出
            if char == "\u{1B}" && i + 1 < newLine.count {
              let nextChar = newLine[newLine.index(newLine.startIndex, offsetBy: i + 1)]
              if nextChar == "[" {
                // エスケープシーケンスをそのまま追加
                var escapeSeq = "\u{1B}["
                i += 2
                while i < newLine.count {
                  let c = newLine[newLine.index(newLine.startIndex, offsetBy: i)]
                  escapeSeq.append(c)
                  i += 1
                  if c == "m" {
                    break
                  }
                }
                result.append(escapeSeq)
                continue
              }
            }

            // 通常の文字の場合、色を適用
            if char != " " && i >= origin.x {
              // 最初の非空白文字の前に色コードを挿入
              if !result.contains(colorCode) {
                result.append(colorCode)
              }
            }

            result.append(char)
            i += 1
          }

          // 色コードが適用されていたらリセットコードを追加
          if result.contains(colorCode) && !result.contains(resetCode) {
            result.append(resetCode)
          }

          buffer[index] = result
        }
      }
    }
  }

  func render(into buffer: inout [String]) {
    child.render(into: &buffer)
  }
}
