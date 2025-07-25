import Darwin  // ← ioctl 用
import Darwin  // winsize, ioctl
//  Sources/SwiftTUI/Runtime/RenderLoop.swift
/// 描画ループ（Yoga → 行差分パッチ描画 + DEBUG ダンプ）
// Sources/SwiftTUI/Runtime/RenderLoop.swift
import Foundation
import yoga  // ←★ 追加：YGNodeGetChildCount などを使うため

// Darwin: macOS/iOS向けのシステムフレームワーク
// winsize構造体、ioctl、STDOUT_FILENO、fflush、exit等を提供

// winsize: ターミナルのサイズ情報を格納する構造体
// ioctl: I/O制御のシステムコール（端末サイズ取得など）

public enum RenderLoop {
  public static var DEBUG = false
  private static var makeRoot: (() -> LegacyAnyView)?
  private static var cachedRoot: LegacyAnyView?
  private static let rq = DispatchQueue(label: "SwiftTUI.Render")
  private static var prev: [String] = []
  private static var redrawPending = false

  public static func mount<V: LegacyView>(_ build: @escaping () -> V) {
    makeRoot = { LegacyAnyView(build()) }
    cachedRoot = makeRoot?()  // ルートビューをキャッシュ
    fullRedraw()
    startInput()
  }
  public static func scheduleRedraw() {
    guard !redrawPending else {
      return
    }
    redrawPending = true
    rq.async {
      incrementalRedraw()
      redrawPending = false
    }
  }

  // --- frame builder --------------------------------------------------
  private static func buildFrame() -> [String] {
    // レンダリング前にFocusManagerを準備
    FocusManager.shared.prepareForRerender()

    guard let root = cachedRoot else {
      return []
    }

    guard let lv = root as? LayoutView else {
      var b: [String] = []
      root.render(into: &b)
      return b
    }

    // ① 端末幅取得 (fallback 80)
    // winsize構造体とioctl呼び出しの詳細については
    // CellRenderLoop.swiftのコメントを参照
    var ws = winsize()
    ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws)
    let width = Float(ws.ws_col > 0 ? ws.ws_col : 80)

    let node = lv.makeNode()
    node.calculate(width: width)

    var buf: [String] = []
    lv.paint(origin: (0, 0), into: &buf)
    if DEBUG {
      dump(buf, node)
    }
    return buf
  }

  // --- draw routines --------------------------------------------------
  private static func fullRedraw() {
    print("\u{1B}[2J\u{1B}[H", terminator: "")
    prev = buildFrame()
    prev.forEach { print($0) }
    // fflush: 出力バッファを強制的にフラッシュ
    // TUIでは即座の画面更新が必要なため重要
    fflush(stdout)
  }
  private static func incrementalRedraw() {
    let next = buildFrame()
    let common = min(prev.count, next.count)
    for r in 0..<common where prev[r] != next[r] {
      mv(r)
      clr()
      print(next[r], terminator: "")
    }
    if next.count > prev.count {
      for r in prev.count..<next.count {
        mv(r)
        clr()
        print(next[r], terminator: "")
      }
    } else if next.count < prev.count {
      for r in next.count..<prev.count {
        mv(r)
        clr()
      }
    }
    mv(next.count)
    prev = next
    // 差分更新後も即座にフラッシュ（ちらつき防止）
    fflush(stdout)
  }

  // --- helpers --------------------------------------------------------
  private static func mv(_ r: Int) {
    print("\u{1B}[\(r + 1);1H", terminator: "")
  }

  private static func clr() {
    print("\u{1B}[2K", terminator: "")
  }

  private static func startInput() {
    InputLoop.start { ev in
      _ = cachedRoot?.handle(event: ev)
    }
  }

  // DEBUG
  private static func dump(_ buf: [String], _ n: YogaNode) {
    print("---- buffer ----")
    buf.enumerated().forEach { print($0, "[\($1)]") }
    print("-----------------")
  }
}

// MARK: - Frame builder + DEBUG
extension RenderLoop {
  // ---- debug helpers ---------------------------------------------------
  fileprivate static func dumpNode(_ n: YogaNode, indent: Int) {
    let f = n.frame
    print(
      String(repeating: " ", count: indent),
      "frame:(\(f.x),\(f.y),\(f.w),\(f.h))")
    let cnt = Int(YGNodeGetChildCount(n.rawPtr))  // ← yoga C-API
    for i in 0..<cnt {
      if let c = YGNodeGetChild(n.rawPtr, Int(i)) {
        dumpNode(YogaNode(raw: c), indent: indent + 2)
      }
    }
  }

  fileprivate static func dumpBuffer(_ b: [String]) {
    print("===== buffer dump =====")
    for (i, l) in b.enumerated() { print(i, "[\(l)]") }
    print("-----------------------")
  }
}

// MARK: - ANSI helpers
extension RenderLoop {
  fileprivate static func move(_ r: Int) { print("\u{1B}[\(r + 1);1H", terminator: "") }
  fileprivate static func clear() { print("\u{1B}[2K", terminator: "") }
}

extension RenderLoop {
  public static func shutdown() {
    InputLoop.stop()  // ← raw-mode を確実に解除
    move(prev.count)
    clear()
    // 最後の画面更新を確実に反映
    fflush(stdout)
    // プロセスを正常終了（詳細はCellRenderLoop.swiftのコメント参照）
    exit(0)
  }
}
