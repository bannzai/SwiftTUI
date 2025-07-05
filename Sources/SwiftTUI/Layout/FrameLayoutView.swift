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
        if let w = width {
            node.setWidth(w)
        }
        if let h = height {
            node.setHeight(h)
        }
        
        // アライメントを設定
        switch alignment.horizontal {
        case .leading:
            node.justifyContent(.flexStart)
        case .center:
            node.justifyContent(.center)
        case .trailing:
            node.justifyContent(.flexEnd)
        }
        
        switch alignment.vertical {
        case .top:
            node.alignItems(.flexStart)
        case .center:
            node.alignItems(.center)
        case .bottom:
            node.alignItems(.flexEnd)
        }
        
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
            node.calculate(width: 100) // デフォルト幅
        }
        
        // 子ノードの位置を取得
        if let raw = YGNodeGetChild(node.rawPtr, 0) {
            let dx = Int(YGNodeLayoutGetLeft(raw))
            let dy = Int(YGNodeLayoutGetTop(raw))
            
            // フレームサイズを取得
            let frameWidth = Int(YGNodeLayoutGetWidth(node.rawPtr))
            let frameHeight = Int(YGNodeLayoutGetHeight(node.rawPtr))
            
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