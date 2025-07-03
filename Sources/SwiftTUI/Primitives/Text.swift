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
    // 固定幅 + 高さ1（全角は要調整）
    n.setSize(width: Float(max(content.count, 1)), height: 1)
    n.setMinHeight(1)
    return n
  }

  public func paint(origin: (x: Int, y: Int), into buf: inout [String]) {
    // 行確保
    while buf.count <= origin.y { buf.append("") }

    // 左側スペース確保
    if buf[origin.y].count < origin.x {
      buf[origin.y] += String(repeating: " ", count: origin.x - buf[origin.y].count)
    }

    let styled = buildStyledText()
    let line   = buf[origin.y]
    let prefix = line.prefix(origin.x)
    buf[origin.y] = prefix + styled
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
