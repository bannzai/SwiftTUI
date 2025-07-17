import yoga

/// Listのレイアウト実装
internal struct ListLayoutView: LayoutView {
  let child: any LayoutView

  // リストのスタイル設定
  private let rowSpacing: Float = 0
  private let showSeparators: Bool = true
  private let separatorColor: Color = .white

  init(child: any LayoutView) {
    self.child = child
  }

  func makeNode() -> YogaNode {
    let node = YogaNode()

    // リストは垂直方向に並べる
    node.flexDirection(.column)

    // 親のサイズに合わせる
    node.setFlexGrow(1.0)
    node.setFlexShrink(1.0)

    // 行間のスペーシング
    if rowSpacing > 0 {
      node.setGap(rowSpacing, .column)
    }

    // 子要素がTupleLayoutViewの場合、その子要素を直接追加
    if let tupleChild = child as? TupleLayoutView {
      for view in tupleChild.views {
        let rowNode = createRowNode(for: view)
        node.insert(child: rowNode)
      }
    } else {
      let rowNode = createRowNode(for: child)
      node.insert(child: rowNode)
    }

    return node
  }

  private func createRowNode(for view: any LayoutView) -> YogaNode {
    let rowNode = YogaNode()

    // 行は水平方向に広がる
    rowNode.setSize(width: .nan, height: .nan)
    rowNode.setFlexGrow(0)
    rowNode.setFlexShrink(0)

    let contentNode = view.makeNode()
    rowNode.insert(child: contentNode)

    return rowNode
  }

  func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
    // 座標の妥当性チェック
    guard origin.x >= 0, origin.y >= 0 else { return }

    let node = makeNode()

    // レイアウトを計算（デフォルトサイズを使用）
    let defaultWidth: Float = 80
    let defaultHeight: Float = 24
    node.calculate(width: defaultWidth, height: defaultHeight)

    // 安全なFloat→Int変換関数
    func safeInt(_ v: Float) -> Int {
      guard v.isFinite else { return 0 }
      return max(0, Int(v))  // 負の値を0にクランプ
    }

    // 各行を描画
    let childCount = Int(YGNodeGetChildCount(node.rawPtr))

    for i in 0..<childCount {
      guard let rowRaw = YGNodeGetChild(node.rawPtr, i) else { continue }

      let rowY = safeInt(YGNodeLayoutGetTop(rowRaw))
      let rowHeight = safeInt(YGNodeLayoutGetHeight(rowRaw))
      let rowWidth = safeInt(YGNodeLayoutGetWidth(node.rawPtr))

      // 描画位置が妥当かチェック
      let drawY = origin.y + rowY
      guard drawY >= 0 else { continue }

      // 行の内容を描画
      if let contentRaw = YGNodeGetChild(rowRaw, 0) {
        let contentX = safeInt(YGNodeLayoutGetLeft(contentRaw))
        let contentY = safeInt(YGNodeLayoutGetTop(contentRaw))

        let drawX = origin.x + contentX
        let finalY = drawY + contentY

        // 実際のViewを取得して描画
        if child is TupleLayoutView,
          let tupleChild = child as? TupleLayoutView,
          i < tupleChild.views.count
        {
          tupleChild.views[i].paint(
            origin: (drawX, finalY),
            into: &buffer
          )
        } else if i == 0 {
          child.paint(
            origin: (drawX, finalY),
            into: &buffer
          )
        }
      }

      // セパレーターを描画（最後の行以外）
      if showSeparators && i < childCount - 1 {
        let separatorY = drawY + rowHeight
        // rowWidthが0以下の場合はデフォルト幅を使用
        let effectiveWidth = rowWidth > 0 ? rowWidth : 40
        if separatorY >= 0 && separatorY < buffer.count && effectiveWidth > 0 {
          let separatorLine = String(repeating: "─", count: effectiveWidth)
          let coloredLine = "\u{1B}[\(separatorColor.fg)m\(separatorLine)\u{1B}[0m"
          bufferWrite(
            row: separatorY,
            col: origin.x,
            text: coloredLine,
            into: &buffer
          )
        }
      }
    }
  }

  func render(into buffer: inout [String]) {
    child.render(into: &buffer)
  }
}
