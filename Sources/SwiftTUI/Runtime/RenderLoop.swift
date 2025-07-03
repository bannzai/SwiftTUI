import Foundation

enum RenderLoop {
  private static var makeRoot: (() -> AnyView)?

  static func mount<V: View>(_ build: @escaping () -> V) {
    makeRoot = { AnyView(build()) }
    redraw()                      // 初期描画
  }

  static func redraw() {
    guard let makeRoot else { return }

    print("\u{001B}[2J\u{001B}[H", terminator: "")

    var buffer: [String] = []
    makeRoot().render(into: &buffer)
    buffer.forEach { print($0) }
    fflush(stdout)
  }
}
