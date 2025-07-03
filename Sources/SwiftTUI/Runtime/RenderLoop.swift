import Foundation

public enum RenderLoop {
  private static var makeRoot: (() -> AnyView)?
  private static var redrawPending = false

  private static let renderQueue = DispatchQueue(label: "SwiftTUI.RenderLoop")

  public static func mount<V: View>(_ build: @escaping () -> V) {
    makeRoot = { AnyView(build()) }
    redraw()                      // 初期描画
  }


  internal static func scheduleRedraw() {
    guard !redrawPending else {
      return
    }
    redrawPending = true
    renderQueue.async {
      redraw()
      redrawPending = false
    }
  }

  internal static func redraw() {
    guard let makeRoot else {
      return
    }

    print("\u{001B}[2J\u{001B}[H", terminator: "")

    var buffer: [String] = []
    makeRoot().render(into: &buffer)
    buffer.forEach { print($0) }
    fflush(stdout)
  }
}
