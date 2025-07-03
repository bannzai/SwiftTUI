//  Sources/SwiftTUI/Runtime/RenderLoop.swift
import Foundation
import yoga               // ←★ 追加：YGNodeGetChildCount などを使うため
import Darwin   // ← ioctl 用

/// 描画ループ（Yoga → 行差分パッチ描画 + DEBUG ダンプ）
public enum RenderLoop {

  // ── Public ────────────────────────────────────────────────────────────
  public static func mount<V: View>(_ build: @escaping () -> V) {
    makeRoot = { AnyView(build()) }
    fullRedraw()
    startInputLoop()
  }

  // ── Internal state ───────────────────────────────────────────────────
  private static var makeRoot      : (() -> AnyView)?
  private static var redrawPending = false
  private static let renderQ       = DispatchQueue(label: "SwiftTUI.Render")
  private static var prevBuf       : [String] = []
}

// MARK: - @State から呼ばれる
extension RenderLoop {
  static func scheduleRedraw() {
    guard !redrawPending else { return }
    redrawPending = true
    renderQ.async {
      incrementalRedraw()
      redrawPending = false
    }
  }
}

// MARK: - Frame builder + DEBUG
private extension RenderLoop {

  private static func buildFrame() -> [String] {
    guard let root = makeRoot?() as? LayoutView else { return [] }

    let node = root.makeNode()

    // ① 現在のターミナル幅を取得
    var w = winsize(); ioctl(STDOUT_FILENO, TIOCGWINSZ, &w)
    let termWidth  = Float(w.ws_col > 0 ? w.ws_col : 80)

    // ② 幅だけ指定してレイアウト
    node.calculate(width: termWidth)

    var buf: [String] = []
    root.paint(origin: (0, 0), into: &buf)
    return buf
  }

  // ---- debug helpers ---------------------------------------------------
  static func dumpNode(_ n: YogaNode, indent: Int) {
    let f = n.frame
    print(String(repeating: " ", count: indent),
          "frame:(\(f.x),\(f.y),\(f.w),\(f.h))")
    let cnt = Int(YGNodeGetChildCount(n.rawPtr))       // ← yoga C-API
    for i in 0..<cnt {
      if let c = YGNodeGetChild(n.rawPtr, Int(i)) {
        dumpNode(YogaNode(raw: c), indent: indent + 2)
      }
    }
  }

  static func dumpBuffer(_ b: [String]) {
    print("===== buffer dump =====")
    for (i,l) in b.enumerated() { print(i, "[\(l)]") }
    print("-----------------------")
  }
}

// MARK: - Draw routines
private extension RenderLoop {

  static func fullRedraw() {
    print("\u{1B}[2J\u{1B}[H", terminator: "")
    prevBuf = buildFrame()
    prevBuf.forEach { print($0) }
    fflush(stdout)
  }

  static func incrementalRedraw() {
    let next = buildFrame()

    let common = min(prevBuf.count, next.count)
    for row in 0..<common where prevBuf[row] != next[row] {
      move(row); clear(); print(next[row], terminator: "")
    }
    if next.count > prevBuf.count {
      for r in prevBuf.count..<next.count { move(r); clear(); print(next[r], terminator:"") }
    } else if next.count < prevBuf.count {
      for r in next.count..<prevBuf.count { move(r); clear() }
    }
    move(next.count)
    prevBuf = next
    fflush(stdout)
  }
}

// MARK: - ANSI helpers
private extension RenderLoop {
  static func move(_ r: Int)  { print("\u{1B}[\(r+1);1H", terminator:"") }
  static func clear()         { print("\u{1B}[2K",       terminator:"") }
}

// MARK: - Input
private extension RenderLoop {
  static func startInputLoop() {
    InputLoop.start { ev in _ = makeRoot?().handle(event: ev) }
  }
}

extension RenderLoop {
  public static func shutdown() {
    InputLoop.stop()             // ← raw-mode を確実に解除
    move( prevBuf.count ); clear()
    fflush(stdout)
    exit(0)
  }
}
