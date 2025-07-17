import yoga

/// サイズ制約を適用するLayoutView
internal struct FrameLayoutView: LayoutView {
  let width: Float?
  let height: Float?
  let alignment: Alignment
  let child: any LayoutView

  init(width: Float?, height: Float?, alignment: Alignment, child: any LayoutView) {
    self.width = width
    self.height = height
    self.alignment = alignment
    self.child = child
  }

  func makeNode() -> YogaNode {
    let node = YogaNode()

    // サイズ制約を設定
    if let w = width, let h = height {
      node.setSize(width: w, height: h)
    } else if let w = width {
      node.setSize(width: w, height: .nan)
    } else if let h = height {
      node.setSize(width: .nan, height: h)
    }

    // フレックスコンテナとして設定
    node.flexDirection(.column)

    // 子ノードを追加
    let childNode = child.makeNode()
    node.insert(child: childNode)

    return node
  }

  func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
    let node = makeNode()

    // レイアウト計算
    if let w = width {
      node.calculate(width: w)
    } else {
      node.calculate(width: 100)  // デフォルト幅
    }

    // 子ノードの位置を取得
    if let raw = YGNodeGetChild(node.rawPtr, 0) {
      let dx = Int(YGNodeLayoutGetLeft(raw))
      let dy = Int(YGNodeLayoutGetTop(raw))

      // フレームサイズを取得
      let frameWidth = Int(YGNodeLayoutGetWidth(node.rawPtr))
      let frameHeight = Int(YGNodeLayoutGetHeight(node.rawPtr))

      // fputs("DEBUG: FrameLayoutView painting child at (\(origin.x + dx), \(origin.y + dy)), frame size: \(frameWidth)x\(frameHeight)\n", stderr)

      // 子を描画
      child.paint(origin: (origin.x + dx, origin.y + dy), into: &buffer)

      // フレーム内の残りの部分をスペースで埋める（必要に応じて）
      if let h = height {
        let intHeight = Int(h)
        for y in 0..<intHeight {
          let row = origin.y + y
          if row >= buffer.count {
            buffer.append("")
          }

          // 行の長さを調整
          while buffer[row].count < origin.x + frameWidth {
            buffer[row].append(" ")
          }
        }
      }
    }
  }

  func render(into buffer: inout [String]) {
    child.render(into: &buffer)
  }
}
