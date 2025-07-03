import Foundation

/// 描画ループ（Yoga レイアウト → 行差分パッチ描画）
public enum RenderLoop {

  // MARK: – Public API ----------------------------------------------------
  public static func mount<V: View>(_ build: @escaping () -> V) {
    makeRoot = { AnyView(build()) }
    fullRedraw()
    startInputLoop()
  }

  // MARK: – Internal state -----------------------------------------------
  private static var makeRoot: (() -> AnyView)?
  private static var redrawPending = false
  private static let renderQueue = DispatchQueue(label: "SwiftTUI.RenderLoop")
  private static var prevBuffer: [String] = []

  private static let DEBUG = false          // ⇦ 必要なら true
}

// MARK: – @State から呼ばれる ------------------------------------------------
extension RenderLoop {
  static func scheduleRedraw() {
    guard redrawPending == false else { return }
    redrawPending = true
    renderQueue.async {
      incrementalRedraw()
      redrawPending = false
    }
  }
}

// MARK: – Frame builder (★ ここが新設) --------------------------------------
private extension RenderLoop {

  /// Yoga レイアウト → 各 View.paint() → 行バッファ
  static func buildFrame() -> [String] {
    guard let root = makeRoot?() else {
      return []
    }

    // ① LayoutView なら Yoga レイアウトさせる
    if let lv = root as? LayoutView {
      let n = lv.makeNode()
      n.calculate()                      // 幅・高さ指定なしで全計算

      var buf: [String] = []
      lv.paint(origin: (0, 0), into: &buf)
      return buf
    }

    // ② 後方互換：非 LayoutView は旧 render(into:)
    var fallback: [String] = []
    root.render(into: &fallback)
    return fallback
  }
}

// MARK: – Draw routines -----------------------------------------------------
private extension RenderLoop {

  static func fullRedraw() {
    print("\u{1B}[2J\u{1B}[H", terminator: "")
    prevBuffer = buildFrame()
    prevBuffer.forEach { print($0) }
    fflush(stdout)
  }

  static func incrementalRedraw() {
    let next = buildFrame()

    let common = min(prevBuffer.count, next.count)
    for row in 0..<common where prevBuffer[row] != next[row] {
      moveCursor(to: row); clearLine(); print(next[row], terminator: "")
    }

    if next.count > prevBuffer.count {
      for row in prevBuffer.count..<next.count {
        moveCursor(to: row); clearLine(); print(next[row], terminator: "")
      }
    } else if next.count < prevBuffer.count {
      for row in next.count..<prevBuffer.count {
        moveCursor(to: row); clearLine()
      }
    }

    moveCursor(to: next.count)
    prevBuffer = next
    fflush(stdout)
  }
}

// MARK: – ANSI helpers ------------------------------------------------------
private extension RenderLoop {
  static func moveCursor(to row: Int) { print("\u{1B}[\(row + 1);1H", terminator: "") }
  static func clearLine() { print("\u{1B}[2K", terminator: "") }
}

// MARK: – Input integration -------------------------------------------------
private extension RenderLoop {
  static func startInputLoop() {
    InputLoop.start { event in
      guard let makeRoot else { return }
      _ = makeRoot().handle(event: event)
    }
  }
}
