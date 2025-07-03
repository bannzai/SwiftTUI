// Sources/SwiftTUI/Runtime/RenderLoop.swift
import Foundation

/// 描画ループ管理（行差分パッチ描画 + キーボード入力監視）
public enum RenderLoop {

  // MARK: Public API
  /// アプリ起動時に 1 度だけ root View をマウント
  /// ```
  /// RenderLoop.mount { MyRootView() }
  /// ```
  public static func mount<V: View>(_ build: @escaping () -> V) {
    makeRoot = { AnyView(build()) }
    fullRedraw()
    startInputLoop()
  }

  // MARK: Internal state
  private static var makeRoot: (() -> AnyView)?
  private static var redrawPending = false
  private static let renderQueue = DispatchQueue(label: "SwiftTUI.RenderLoop")
  private static var prevBuffer: [String] = []
}

// MARK: - External hook used by @State
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

// MARK: - Draw routines
extension RenderLoop {
  private static func fullRedraw() {
    guard let makeRoot else { return }

    // 画面クリア (2J) + カーソルホーム (H)
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

    // ① 変化した行を更新
    let common = min(prevBuffer.count, next.count)
    for row in 0..<common where prevBuffer[row] != next[row] {
      moveCursor(to: row)
      clearLine()
      print(next[row], terminator: "")
    }

    // ② 行が増えた場合は追加描画
    if next.count > prevBuffer.count {
      for row in prevBuffer.count..<next.count {
        moveCursor(to: row)
        clearLine()
        print(next[row], terminator: "")
      }
    }

    // ③ 行が減った場合は余剰行をクリア
    if next.count < prevBuffer.count {
      for row in next.count..<prevBuffer.count {
        moveCursor(to: row)
        clearLine()
      }
    }

    // ④ カーソルを末尾へ
    moveCursor(to: next.count)

    prevBuffer = next
    fflush(stdout)
  }
}

// MARK: - ANSI helpers
extension RenderLoop {
  private static func moveCursor(to row: Int) {
    // row は 0-origin → 1-origin に補正
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

      // View ツリーにイベントを伝搬
      _ = makeRoot().handle(event: event)
      // @State セッターが内部で scheduleRedraw() を呼ぶのでここでは何もしない
    }
  }
}
