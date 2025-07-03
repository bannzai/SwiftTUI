import SwiftTUI

struct ColorDemo: View {
  func render(into buffer: inout [String]) {
    buffer.append("🎨  ANSI Styling Demo")
    buffer.append(
      HStack {
        Text("Red").color(.red).bold()
        Text("Green BG").background(.green).underline()
        Text("RGB").color(.rgb(r: 255, g: 128, b: 0))
      }
        .rendered()   // ← 後述ヘルパ（HStack → String）
    )
    buffer.append("")               // 空行
    buffer.append("Press q + Enter to quit")
  }
}

// HStack -> String 変換の簡易ヘルパ
private extension View {
  func rendered() -> String {
    var tmp: [String] = []
    render(into: &tmp)
    return tmp.joined()
  }
}

@main
struct ExampleApp {
  static func main() {
    RenderLoop.mount { ColorDemo() }
    while let line = readLine(strippingNewline: true) {
      if line.lowercased() == "q" { break }
    }
  }
}
