import yoga

/// ┌─┐
/// │ │   の 1-pixel 枠を付けるデバッグ用ラッパー
/// └─┘
final class BorderView<Content: LayoutView>: LayoutView {

  private let child: Content
  
  init(_ c: Content) { 
    self.child = c 
  }

  // MARK: LayoutView ---------------------------------------------------
  func makeNode() -> YogaNode {
    let n = YogaNode()
    n.setPadding(1, .all)                // 枠線ぶんの余白
    n.insert(child: child.makeNode())
    return n
  }
  
  func paint(origin:(x:Int,y:Int), into buf:inout [String]) {
    let n = makeNode()  // 座標取得用（PaddingViewと同じパターン）
    
    // 子ビューレイアウトを取得
    if let raw = YGNodeGetChild(n.rawPtr, 0) {
      let dx = Int(YGNodeLayoutGetLeft(raw))
      let dy = Int(YGNodeLayoutGetTop(raw))
      let cw = Int(YGNodeLayoutGetWidth(raw))
      let ch = Int(YGNodeLayoutGetHeight(raw))
      
      // 子ビューを描画
      child.paint(origin:(origin.x+dx, origin.y+dy), into:&buf)
      
      
      // 枠線を描画
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
  }
  
  func render(into buffer: inout [String]) {}
}

// MARK: – SwiftUI-like modifier
public extension LayoutView {
  func border() -> some LayoutView { BorderView(self) }
}
