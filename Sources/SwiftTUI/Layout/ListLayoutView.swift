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
        
        let childNode = child.makeNode()
        
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
        let node = makeNode()
        
        // 各行を描画
        let childCount = Int(YGNodeGetChildCount(node.rawPtr))
        
        for i in 0..<childCount {
            guard let rowRaw = YGNodeGetChild(node.rawPtr, i) else { continue }
            
            let rowY = Int(YGNodeLayoutGetTop(rowRaw))
            let rowHeight = Int(YGNodeLayoutGetHeight(rowRaw))
            let rowWidth = Int(YGNodeLayoutGetWidth(node.rawPtr))
            
            // 行の内容を描画
            if let contentRaw = YGNodeGetChild(rowRaw, 0) {
                let contentX = Int(YGNodeLayoutGetLeft(contentRaw))
                let contentY = Int(YGNodeLayoutGetTop(contentRaw))
                
                // 実際のViewを取得して描画
                if child is TupleLayoutView,
                   let tupleChild = child as? TupleLayoutView,
                   i < tupleChild.views.count {
                    tupleChild.views[i].paint(
                        origin: (origin.x + contentX, origin.y + rowY + contentY),
                        into: &buffer
                    )
                } else if i == 0 {
                    child.paint(
                        origin: (origin.x + contentX, origin.y + rowY + contentY),
                        into: &buffer
                    )
                }
            }
            
            // セパレーターを描画（最後の行以外）
            if showSeparators && i < childCount - 1 {
                let separatorY = origin.y + rowY + rowHeight
                if separatorY >= 0 && separatorY < buffer.count {
                    let separatorLine = String(repeating: "─", count: rowWidth)
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

// ListLayoutViewのスタイル拡張
extension ListLayoutView {
    /// カスタムスタイルのList
    init(child: any LayoutView, rowSpacing: Float, showSeparators: Bool, separatorColor: Color) {
        self.child = child
        self.rowSpacing = rowSpacing
        self.showSeparators = showSeparators
        self.separatorColor = separatorColor
    }
}