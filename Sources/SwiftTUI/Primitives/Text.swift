// Sources/SwiftTUI/Primitives/Text.swift
import yoga

// ── 公開 API ───────────────────────────────────────────────
public struct Text: View {
  let content: String
  var fgColor: Color? = nil
  var bgColor: Color? = nil
  var style: TextStyle = []

  public init(_ content: String) { self.content = content }

  // SwiftUI-like modifiers
  public func color(_ c: Color)      -> Self { var s=self; s.fgColor=c; return s }
  public func background(_ c: Color) -> Self { var s=self; s.bgColor=c; return s }
  public func bold()                 -> Self { var s=self; s.style.insert(.bold); return s }
}

// ── LayoutView 適合 ───────────────────────────────────────
extension Text: LayoutView {

  // Yoga node  : 1 行・幅 = 印字セル数
  public func makeNode() -> YogaNode {
    let n = YogaNode()
    n.setSize(width: Float(displayWidth()), height: 1)
    n.setMinHeight(1)
    return n
  }

  public func paint(origin:(x:Int,y:Int), into buf:inout [String]) {
    bufferWrite(row: origin.y,
                col: origin.x,
                text: buildStyledText(),
                into: &buf)
  }

}

// ── 内部ヘルパ ────────────────────────────────────────────
private extension Text {

  /// 表示セル幅（全角=2, それ以外=1 の簡易版）
  func displayWidth() -> Int {
    content.unicodeScalars.reduce(0) { acc, scalar in
      acc + (scalar.value > 0xFF ? 2 : 1)
    }
  }

  /// ANSI エスケープ付き文字列生成
  func buildStyledText() -> String {
    var codes:[String]=[]
    if let fg=fgColor { codes.append(fg.fg) }
    if let bg=bgColor { codes.append(bg.bg) }
    codes.append(contentsOf: style.sgr())
    guard codes.isEmpty == false else { return content }
    return "\u{1B}[" + codes.joined(separator:";") + "m" + content + "\u{1B}[0m"
  }
}
