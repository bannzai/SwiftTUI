import yoga

public struct Text: View {
  let content: String
  var fgColor: Color? = nil
  var bgColor: Color? = nil
  var style: TextStyle = []

  // MARK: Initialiser
  public init(_ content: String) { self.content = content }

  // ---------- SwiftUI-like modifiers ----------
  public func color(_ c: Color) -> Self {
    var copy = self; copy.fgColor = c; return copy
  }
  public func background(_ c: Color) -> Self {
    var copy = self; copy.bgColor = c; return copy
  }
  public func bold() -> Self {
    var copy = self; copy.style.insert(.bold); return copy
  }

  // ---------- Yoga ----------
  // LayoutView を採用
}

extension Text: LayoutView {
  public func makeNode() -> YogaNode {
    let n = YogaNode()
    // “幅 = 文字数, 高 = 1” を固定で与える
    n.setSize(width: Float(max(content.count, 1)), height: 1)
    n.setMinHeight(1)
    return n
  }

  public func paint(origin: (x: Int, y: Int), into buf: inout [String]) {

    // ── DEBUG ────────────────────────────────────────────
    print("[TXT] row:", origin.y,
          "col:", origin.x,
          "textLen:", content.count,
          "bufRows:", buf.count)
    // ────────────────────────────────────────────────────

    while buf.count <= origin.y { buf.append("") }

    var lineChars = Array(buf[origin.y])

    if lineChars.count < origin.x {
      let gap = origin.x - lineChars.count
      print("[TXT]   pad left gap:", gap)
      lineChars += Array(repeating: " ", count: gap)
    }

    let styled = Array(buildStyledText())
    let after  = origin.x + styled.count

    if lineChars.count < after {
      let gap = after - lineChars.count
      print("[TXT]   pad right gap:", gap)
      lineChars += Array(repeating: " ", count: gap)
    }

    for i in 0..<styled.count {
      lineChars[origin.x + i] = styled[i]
    }

    buf[origin.y] = String(lineChars)
  }


  // ---------- helpers ----------
  private func contentWidth() -> Int { content.count }

  private func buildStyledText() -> String {
    var codes: [String] = []
    if let fg = fgColor { codes.append(fg.fg) }
    if let bg = bgColor { codes.append(bg.bg) }
    codes.append(contentsOf: style.sgr())

    guard !codes.isEmpty else { return content }
    let prefix = "\u{1B}[" + codes.joined(separator: ";") + "m"
    let reset  = "\u{1B}[0m"
    return prefix + content + reset
  }

}
