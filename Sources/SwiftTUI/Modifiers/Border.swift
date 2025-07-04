import yoga

final class BorderView<Content: LayoutView>: LayoutView {

  private let inset: Float = 1
  private let child: Content
  init(_ c: Content) { child = c }

  func makeNode() -> YogaNode {
    let n = YogaNode()
    n.setPadding(inset, .all)
    n.insert(child: child.makeNode())
    return n
  }

  func paint(origin:(x:Int,y:Int), into buf:inout [String]) {
    // 1. 子ビューを描画（padding分のオフセット付き）
    child.paint(origin:(origin.x + 1, origin.y + 1), into:&buf)
    
    // 2. 子ビューの実際のサイズを取得するため、子ビューのノードを作成
    let childNode = child.makeNode()
    childNode.calculate()  // 幅を自動計算
    
    let width = childNode.frame.w
    let height = childNode.frame.h
    
    // 3. 枠線を描画
    let horiz = String(repeating: "─", count: width + 2)  // +2 for padding
    
    bufferWrite(row: origin.y,
                col: origin.x,
                text: "┌" + horiz + "┐",
                into:&buf)
    
    bufferWrite(row: origin.y + height + 2,  // +2 for top and bottom padding
                col: origin.x,
                text: "└" + horiz + "┘",
                into:&buf)
    
    for dy in 1...(height + 1) {  // +1 for bottom padding
      bufferWrite(row: origin.y + dy,
                  col: origin.x,
                  text: "│",
                  into:&buf)
      bufferWrite(row: origin.y + dy,
                  col: origin.x + width + 3,  // +3 for padding and borders
                  text: "│",
                  into:&buf)
    }
  }

  func render(into buffer: inout [String]) {}
}

public extension LayoutView {
  func border() -> some LayoutView { BorderView(self) }
}