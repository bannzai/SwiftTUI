import yoga

/// ┌─┐
/// │ │   の 1-pixel 枠を付けるデバッグ用ラッパー
/// └─┘
final class BorderView<Content: LayoutView>: LayoutView {

  private let child: Content
  init(_ c: Content) { child = c }

  // MARK: LayoutView ---------------------------------------------------
  func makeNode() -> YogaNode {
    let n = YogaNode()
    n.setPadding(1, .all)                // 枠線ぶんの余白
    n.insert(child: child.makeNode())
    return n
  }

  func paint(origin:(x:Int,y:Int), into buf:inout [String]) {

    let node = makeNode()

    // ── 子ビューレイアウトを取得 ───────────────────────
    guard let raw = YGNodeGetChild(node.rawPtr, 0) else { return }

    func f2i(_ v: Float) -> Int { v.isFinite ? Int(v) : 0 }   // ← ★ 追加

    let cw = f2i(YGNodeLayoutGetWidth (raw))   // child width  (safe)
    let ch = f2i(YGNodeLayoutGetHeight(raw))   // child height (safe)
    // ── 1) 子ビューを描画 ───────────────────────────────
    child.paint(origin:(origin.x+1, origin.y+1), into:&buf)

    // ── 2) 枠線を描画（bufferWrite だけ使用） ─────────
    let horiz = String(repeating: "─", count: cw)

    bufferWrite(row: origin.y,
                col: origin.x,
                text: "┌" + horiz + "┐",
                into:&buf)

    bufferWrite(row: origin.y + ch + 1,
                col: origin.x,
                text: "└" + horiz + "┘",
                into:&buf)

    if ch > 0 {
      for yOff in 1...ch {
        bufferWrite(row: origin.y + yOff,
                    col: origin.x,
                    text: "│",
                    into:&buf)
        bufferWrite(row: origin.y + yOff,
                    col: origin.x + cw + 1,
                    text: "│",
                    into:&buf)
      }
    }
  }

  // MARK: View 互換
  func render(into buffer: inout [String]) {}
}

// MARK: – SwiftUI-like modifier
public extension LayoutView {
  func border() -> some LayoutView { BorderView(self) }
}
