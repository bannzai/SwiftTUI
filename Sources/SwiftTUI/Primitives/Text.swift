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

  // 1行＝文字数、縦1 の寸法を Yoga に教える
  func makeNode() -> YogaNode {
    let node = YogaNode()
    node.setSize(width: Float(content.count), height: 1)
    return node  }

  // Yoga が決めた座標に描画
  public func paint(origin: (x: Int, y: Int), into buf: inout [String]) {

    // ① 行バッファを確保
    while buf.count <= origin.y { buf.append("") }

    var line = buf[origin.y]
    if line.count < origin.x {
      line += String(repeating: " ", count: origin.x - line.count)
    }

    let styled = buildStyledText()
    let prefix = line.prefix(origin.x)
    var suffix = ""
    if line.count > origin.x {
      // 既にあった文字列を塗り替えずに残す
      let start = line.index(line.startIndex, offsetBy: origin.x)
      suffix = String(line[start...])
    }

    buf[origin.y] = prefix + styled + suffix
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
