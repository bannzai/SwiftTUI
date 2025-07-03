//  Sources/SwiftTUI/Runtime/RenderLoop.swift
import Foundation
import yoga               // ←★ 追加：YGNodeGetChildCount などを使うため

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

  static func buildFrame() -> [String] {
    guard let root = makeRoot?() else { return [] }

    guard let lv = root as? LayoutView else {          // AnyView は必ず OK
      var b: [String] = []; root.render(into: &b)
      if DEBUG { dumpBuffer(b) }
      return b
    }

    let n = lv.makeNode()
    n.calculate()                                      // Yoga レイアウト

    var buf: [String] = []
    lv.paint(origin: (0, 0), into: &buf)

    if DEBUG {
      print("===== layout dump =====")
      dumpNode(n, indent: 0)
      dumpBuffer(buf)
    }
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
