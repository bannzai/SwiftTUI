import yoga

/// 方向指定付きPaddingを適用するLayoutView
internal struct DirectionalPaddingLayoutView: LayoutView {
    let edges: Edge.Set
    let length: Float
    let child: any LayoutView
    
    init(edges: Edge.Set, length: Float, child: any LayoutView) {
        self.edges = edges
        self.length = length
        self.child = child
    }
    
    func makeNode() -> YogaNode {
        let node = YogaNode()
        
        // 各エッジに対してpaddingを設定
        if edges.contains(.top) {
            node.setPadding(length, .top)
        }
        if edges.contains(.leading) {
            node.setPadding(length, .left)
        }
        if edges.contains(.bottom) {
            node.setPadding(length, .bottom)
        }
        if edges.contains(.trailing) {
            node.setPadding(length, .right)
        }
        
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