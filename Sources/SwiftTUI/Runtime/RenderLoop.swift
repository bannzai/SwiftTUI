import Foundation

/// 描画ループ（行差分パッチ描画＋入力統合＋デバッグログ）
public enum RenderLoop {

  // MARK: Public API
  public static func mount<V: View>(_ build: @escaping () -> V) {
    makeRoot = { AnyView(build()) }
    fullRedraw()
    startInputLoop()
  }

  // MARK: - Internal state
  private static var makeRoot: (() -> AnyView)?
  private static var redrawPending = false
  private static let renderQueue = DispatchQueue(label: "SwiftTUI.RenderLoop")
  private static var prevBuffer: [String] = []
  private static let DEBUG = true
}

// MARK: - Called from @State
extension RenderLoop {
  static func scheduleRedraw() {
    guard redrawPending == false else { return }
    redrawPending = true

    if DEBUG {
      print("[DEBUG] redraw scheduled")
    }

    renderQueue.async {
      incrementalRedraw()
      redrawPending = false

      if DEBUG {
        print("[DEBUG] redraw finished")
      }
    }
  }
}

// MARK: - Draw routines
extension RenderLoop {

  private static func fullRedraw() {
    guard let makeRoot else { return }

    // clear screen + cursor home
    print("\u{1B}[2J\u{1B}[H", terminator: "")

    var buffer: [String] = []
    makeRoot().render(into: &buffer)
    buffer.forEach { print($0) }

    prevBuffer = buffer
    fflush(stdout)
  }

  private static func incrementalRedraw() {
    guard let makeRoot else { return }

    var next: [String] = []
    makeRoot().render(into: &next)

    let common = min(prevBuffer.count, next.count)
    for row in 0 ..< common where prevBuffer[row] != next[row] {
      moveCursor(to: row)
      clearLine()
      print(next[row], terminator: "")
    }

    if next.count > prevBuffer.count {
      for row in prevBuffer.count ..< next.count {
        moveCursor(to: row)
        clearLine()
        print(next[row], terminator: "")
      }
    }

    if next.count < prevBuffer.count {
      for row in next.count ..< prevBuffer.count {
        moveCursor(to: row)
        clearLine()
      }
    }

    moveCursor(to: next.count)
    prevBuffer = next
    fflush(stdout)
  }
}

// MARK: - ANSI helpers
extension RenderLoop {

  private static func moveCursor(to row: Int) {
    print("\u{1B}[\(row + 1);1H", terminator: "")
  }

  private static func clearLine() {
    print("\u{1B}[2K", terminator: "")
  }
}

// MARK: - Input integration
extension RenderLoop {

  private static func startInputLoop() {
    InputLoop.start { event in
      guard let makeRoot else { return }

      if DEBUG {
        print("[DEBUG] handle(event:) invoked with", event)
      }

      _ = makeRoot().handle(event: event)
      // @State 内の setter が scheduleRedraw() を呼ぶのでここでは描画を直接触らない
    }
  }
}
