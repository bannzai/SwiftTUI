/// 空のView（何も表示しない）
public struct EmptyView: View {
    public init() {}
    
    public typealias Body = Never
}

// EmptyViewの内部LayoutView実装
extension EmptyView {
    internal struct _LayoutView: LayoutView {
        func makeNode() -> YogaNode {
            let node = YogaNode()
            node.setSize(width: 0, height: 0)
            return node
        }
        
        func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
            // 何も描画しない
        }
        
        func render(into buffer: inout [String]) {}
    }
}