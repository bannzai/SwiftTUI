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
