import Foundation

public enum RenderLoop {
  private static var makeRoot: (() -> AnyView)?

  public static func mount<V: View>(_ build: @escaping () -> V) {
    makeRoot = { AnyView(build()) }
    redraw()                      // 初期描画
  }

  internal static func redraw() {
    guard let makeRoot else { return }

    print("\u{001B}[2J\u{001B}[H", terminator: "")

    var buffer: [String] = []
    makeRoot().render(into: &buffer)
    buffer.forEach { print($0) }
    fflush(stdout)
  }
}
