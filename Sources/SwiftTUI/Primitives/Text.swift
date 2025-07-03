import yoga

public struct Text: View {
  let content: String
  var fgColor: Color? = nil
  var bgColor: Color? = nil
  var style: TextStyle = []

  // MARK: Init
  public init(_ content: String) { self.content = content }

  // MARK: Modifiers
  public func color(_ c: Color) -> Self {
    var copy = self; copy.fgColor = c; return copy
  }
  public func background(_ c: Color) -> Self {
    var copy = self; copy.bgColor = c; return copy
  }
  public func bold() -> Self {
    var copy = self; copy.style.insert(.bold); return copy
  }
  public func underline() -> Self {
    var copy = self; copy.style.insert(.underline); return copy
  }

  // MARK: Render
  public func render(into buffer: inout [String]) {
    var codes: [String] = []
    if let fg = fgColor { codes.append(fg.fg) }
    if let bg = bgColor { codes.append(bg.bg) }
    codes.append(contentsOf: style.sgr())

    let prefix = codes.isEmpty ? "" : "\u{1B}[\(codes.joined(separator: ";"))m"
    let reset  = codes.isEmpty ? "" : "\u{1B}[0m"

    buffer.append(prefix + content + reset)
  }
}

extension Text: LayoutView {

  func makeNode() -> YogaNode {
    let node = YogaNode()

    // 1 行文字列の幅 = codeUnit 数 として計測
    node.setMeasure { _, _, _, _, _ in
      let w = Float(self.contentsWidth())
      return YGSize(width: w, height: 1)
    }
    return node
  }

  func paint(origin: (x: Int, y: Int), into buf: inout [String]) {
    assureLines(min: origin.y, in: &buf)
    var line = buf[origin.y]
    if line.count < origin.x {
      line += String(repeating: " ", count: origin.x - line.count)
    }
    let styled = buildStyledText()
    line.replaceSubrange(origin.x ..< origin.x + styled.count, with: styled)
    buf[origin.y] = line
  }

  private func assureLines(min: Int, in buf: inout [String]) {
    while buf.count <= min { buf.append("") }
  }

  private func contentsWidth() -> Int {
    // “全角幅” を正確に計測したいなら将来ここで wcwidth 相当を実装
    content.count
  }
}
