import yoga

/// Paddingを適用するLayoutView
internal struct PaddingLayoutView: LayoutView {
    let inset: Float
    let child: any LayoutView
    
    init(inset: Float, child: any LayoutView) {
        self.inset = inset
        self.child = child
    }
    
    func makeNode() -> YogaNode {
        let node = YogaNode()
        node.setPadding(inset, .all)
        
        let childNode = child.makeNode()
        node.insert(child: childNode)
        
        return node
    }
    
    func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
        let node = makeNode()
        
        // 子ノードの座標を取得
        if let raw = YGNodeGetChild(node.rawPtr, 0) {
            let dx = Int(YGNodeLayoutGetLeft(raw))
            let dy = Int(YGNodeLayoutGetTop(raw))
            child.paint(origin: (origin.x + dx, origin.y + dy), into: &buffer)
        }
    }
    
    func render(into buffer: inout [String]) {
        child.render(into: &buffer)
    }
}